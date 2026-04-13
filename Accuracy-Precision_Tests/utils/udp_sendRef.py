# =========================================
# SEND SCRIPT TO FPGA
# =========================================
# scp udp_sendRef.py root@192.168.1.115:/home/root/

import json
import paho.mqtt.client as mqtt
import time
import threading
import subprocess
import csv
import os
import socket
import struct
import signal
import sys

# =========================================
# CONFIG 
# =========================================
# IP PC
TCP_DEST_IP = "192.168.1.105"
TCP_PORT = 8888

# MQTT
broker_address = "192.168.1.104"
topic = "EDScorbot/trajectory"

# UDP
# Create UDP sockets
udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
RECEIVE_PORT = 25000 # <-- The data is received on the Zynq from Simulink
BUFFER_SIZE = 16     # <-- 4 floats
SEND_PORT = 26000    # <-- The data is sent from the Zynq to Simulink
UDP_IP = "0.0.0.0" 
#udp_send_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
#udp_send_socket.bind((UDP_IP, SEND_PORT))

# Path to save files
dir_path = "/home/root/trajectories_Diogenes"
os.makedirs(dir_path, exist_ok=True)

command_csv_path = os.path.join(dir_path, "ref_log.csv")
real_csv_path = os.path.join(dir_path, "real_log.csv")

# =========================================
# VARIABLES
# =========================================
latest_real_data = None
start_time = None
lock = threading.Lock()
running = True

# List of Threads:
# Thread MQTT (on_message)
# Thread UDP (udp_listener_command)
# Main thread
# They all access the same shared variable: latest_real_data
# lock: is a mutex used to protect data shared between threads.

# =========================================
# FUNCTIONS
# =========================================
def sendRef(ref, joint):
    """
    executes the sendRef function which is responsible for 
    sending the joint to a specific position.

    :param ref: digital spike reference value
    :param joint: number of the joint

    """
    try:
        cmd = ['./sendRef', str(joint), str(int(ref))]
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error run sendRef: {e}")

def sendRefParallel(joints):
    """
    Create 4 threads, one for each axis.
    Each thread executes a separate command sendRef:
    
    :param joints: list of Digitals Spikes references

    """
    threads = []
    for ref, joint in zip(joints, [1,2,3,4]):
        t = threading.Thread(target=sendRef, args=(ref, joint))
        t.start()
        threads.append(t)
    for t in threads:
        t.join()

def udp_listener_command():
    """
    Receive commands from Simulink, send commands to the robot,
    and save data including the counter values.
    """
    global start_time
    # Create socket for data reception
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((UDP_IP, RECEIVE_PORT))
    sock.settimeout(0.5)
    print(f"[UDP-25000] Waiting for data in {UDP_IP}:{RECEIVE_PORT}...")

    first_packet = True  # <-- Flag

    with open(command_csv_path, "w", newline='') as f_cmd, \
         open(real_csv_path, "w", newline='') as f_real:

        w_cmd = csv.writer(f_cmd)
        w_real = csv.writer(f_real)

        w_cmd.writerow(["m1", "m2", "m3", "m4", "elapsed_1", "elapsed_2", "exec_time"])
        w_real.writerow(["m1", "m2", "m3", "m4", "m5", "m6", "timestamp"])

        while running:
            try:
                data, addr = sock.recvfrom(BUFFER_SIZE)
            except socket.timeout:
                continue
            except socket.error as e:
                print(f"Error UDP-25000: {e}")
                break
            
            # Current time
            now = time.time()

            if first_packet:
                start_time = now
                first_packet = False
                print("[UDP] First packet received → start_time initialized")
                continue   # <-- Skip rest of loop

            # Timestamp when command arrives
            elapsed_1 = now - start_time

            # Check that at least one MQTT message has arrived and that the variable 
            # contains valid data.
            with lock:
                if latest_real_data is not None:
                    elapsed_counter = now - start_time
                    # Save current real joint counters
                    row = [int(v) for v in latest_real_data[:6]] + [round(elapsed_counter, 5)]
                    w_real.writerow(row)
                    f_real.flush()

            # Unpack command
            q1, q2, q3, q4 = struct.unpack('4f', data)
            joints = [q1, q2, q3, q4]

            # Execute SPIDs
            t_exec0 = time.time()
            sendRefParallel(joints)
            exec_time = time.time() - t_exec0

            elapsed_2 = time.time() - start_time

            # Save control command
            w_cmd.writerow([
                int(q1), int(q2), int(q3), int(q4),
                round(elapsed_1, 5),
                round(elapsed_2, 5),
                round(exec_time, 5)
            ])
            f_cmd.flush()

    sock.close()

# CALLBACK MQTT
def on_message(client, userdata, message): 
    """
    It subscribes to the mqtt topic to receive meter readings 
    and then sends its values to Simulink via UDP.

    """
    global latest_real_data, running

    if not running:
        return  # Avoid using the closed socket.

    try:
        payload = message.payload.decode('utf-8')
        data = json.loads(payload)

        if isinstance(data, list):
            with lock:
                latest_real_data = data[:6]
                counts = data[:4]

            # Send only if running is True
            if running:
                udp_payload = struct.pack('4f', *counts)
                #print(f"Sending UDP to {TCP_DEST_IP}:{SEND_PORT} -> {counts}")
                udp_socket.sendto(udp_payload, (TCP_DEST_IP, SEND_PORT))

    except Exception as e:
        print(f"Error on_message: {e}")


# SEND FILES FROM FPGA TO PC 
def send_file_via_tcp(filepath):
    """
    Send a file to the PC via TCP without blocking forever.
    If the PC is not listening, timeout cleanly.
    """
    try:
        with open(filepath, "rb") as f:
            data = f.read()

        sock = socket.socket()
        sock.settimeout(3.0)  # <-- prevent infinite block

        try:
            sock.connect((TCP_DEST_IP, TCP_PORT))
        except socket.timeout:
            print(f"[TCP] Timeout: There is no response in {TCP_DEST_IP}:{TCP_PORT}")
            sock.close()
            return
        except Exception as e:
            print(f"[TCP] Cannot connect to PC: {e}")
            sock.close()
            return

        try:
            sock.sendall(data)
        except socket.timeout:
            print("[TCP] Timeout while sending file.")
        except Exception as e:
            print(f"[TCP] Error sending: {e}")

        sock.close()
        print(f"[TCP] Sent file: {filepath}")

    except Exception as e:
        print(f"Error {filepath}: {e}")


def cleanup_and_exit(sig=None, frame=None):
    """
    Orderly closure of threads and file transfer.
    
    """
    global running
    running = False   
    print("\n[EXIT] Interrupt received. Closing sockets...")
    time.sleep(1)

    try:
        udp_socket.close()
    except:
        pass

    print("[EXIT] UDP socket closed.")

    # Try to stop MQTT
    try:
        client.loop_stop()
        client.disconnect()
        print("[EXIT] MQTT disconnected.")
    except:
        pass

    print("[EXIT] Sending CSV files (non-blocking)...")

    # Send files with timeout protection
    send_file_via_tcp(command_csv_path)
    send_file_via_tcp(real_csv_path)

    print("[EXIT] Done. Exiting now.")
    sys.exit(0)


# =========================================
# MQTT SETUP
# =========================================
client = mqtt.Client("subscriber_client")
client.on_message = on_message

try:
    client.connect(broker_address)
    client.subscribe(topic)
except Exception as e:
    print(f"Error to MQTT: {e}")
    sys.exit(1)

# =========================================
# THROW TREADS
# =========================================
threading.Thread(target=udp_listener_command, daemon=True).start()
client.loop_start()

signal.signal(signal.SIGINT, lambda sig, frame: cleanup_and_exit())

while True:
    time.sleep(0.5)
