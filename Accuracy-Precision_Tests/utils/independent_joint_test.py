import socket
import struct
import time
import numpy as np
import os

# =====================================================
# ANGLES REFERENCES
# =====================================================
joint = 2
SEND_INTERVAL = 1.000  # 1.000, 0.750, 0.500, 0.250, 0.200, 0.150, 0.100
step = 1               # steps in Degrees. Step shuld be integer (1, 2, 5, 8, 10)
init_val = 0          
limit_val = -40         # 40, 80
reps = 4              # Number of repetitions

if limit_val > 0:
    sign = 1  # positives
elif limit_val < 0:
    sign = -1 # negative
else:
    print("Zero (0)")

# Test using only one joint
# round trip
angles = (list(range(init_val, limit_val+1*sign, step*sign)) \
    + list(range(limit_val-step*sign, init_val, -step*sign)))*reps
angles.append(angles[0]) 
# The last position is repeated in order to save the previous position. 
angles.append(angles[-1]) 
print(angles)

if joint == 1:
    angles1 = angles
    angles2 = np.zeros(len(angles1))
    angles3 = np.zeros(len(angles1))
    angles4 = np.zeros(len(angles1))
elif joint == 2:
    angles2 = angles
    angles1 = np.zeros(len(angles2))
    angles3 = np.zeros(len(angles2))
    angles4 = np.zeros(len(angles2))
elif joint == 3:
    angles3 = angles
    angles1 = np.zeros(len(angles3))
    angles2 = np.zeros(len(angles3))
    angles4 = np.zeros(len(angles3))
elif joint == 4:
    angles4 = angles
    angles1 = np.zeros(len(angles4))
    angles2 = np.zeros(len(angles4))
    angles3 = np.zeros(len(angles4))
else:
    print("Error in joint number")

# =====================================================
# CONFIG
# =====================================================
SEND_IP = "192.168.1.115"      # FPGA IP (25000)
SEND_PORT = 25000              # Send references to FPGA

# =====================================================
# SETUP UDP SOCKETS
# =====================================================
send_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# ==============================
# TCP SERVER SETTINGS
# ==============================
LISTEN_IP = "0.0.0.0"
LISTEN_PORT = 8888
save_dir = os.path.join(
    "accuracy_and_precision_test_data",
    f"joint_{joint}"
)
os.makedirs(save_dir, exist_ok=True)

file_count = 0
# =====================================================
# FUNCTIONS
# =====================================================

def angleToRef(joint, angle):
    if joint == 1:
        return int(round(3.050640635 * angle))
    if joint == 2:
        return int(round(9.532888465 * angle))
    if joint == 3:
        return int(round(3.220611916 * angle))
    if joint == 4:
        return int(round(17.66784452 * angle))

refs1 = [angleToRef(1, a) for a in angles1]
refs2 = [angleToRef(2, a) for a in angles2]
refs3 = [angleToRef(3, a) for a in angles3]
refs4 = [angleToRef(4, a) for a in angles4]

print(f"Digital SR Joint1: {refs1}")
print(f"Digital SR Joint2: {refs2}")
print(f"Digital SR Joint3: {refs3}")
print(f"Digital SR Joint4: {refs4}")

angles_list = list(zip(angles1, angles2, angles3, angles4))
reference_list = list(zip(refs1, refs2, refs3, refs4))

# =====================================================
# MAIN LOOP
# =====================================================
def control_loop():
    print("Starting reference sequence...")
    ref_count = 0
    round_of = 1
    i = 0

    for ref in reference_list:

        # send reference
        send_sock.sendto(struct.pack('4f', *ref), (SEND_IP, SEND_PORT))
        print(f"Round #: {round_of}, Angles: {angles_list[ref_count]}, Spikes refs: {ref}")
        ref_count += 1
        if i >= ((len(angles)/reps)-2):
            round_of += 1
            i = 0
        else:
            i += 1
        # Apply delay only after the first 2 points
        if ref_count >= 2:
            time.sleep(SEND_INTERVAL)

# =====================================================
# Function to receive files from FPGA
# =====================================================
def tcp_server():
    
    file_count = 0
    server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)  
    server_sock.bind((LISTEN_IP, LISTEN_PORT))
    server_sock.listen(2)
    print(f"[TCP Server] Waiting for connections in {LISTEN_IP}:{LISTEN_PORT}...")

    try:
        while True:
            conn, addr = server_sock.accept()
            print(f"[TCP Server] Connection accepted from {addr}")

            if file_count == 0:
                file_path = os.path.join(save_dir, f"SR_{init_val}-{limit_val}-{init_val}_{step}_{SEND_INTERVAL:.3f}_{reps}.csv")
            else:
                file_path = os.path.join(save_dir, f"COUNT_{init_val}-{limit_val}-{init_val}_{step}_{SEND_INTERVAL:.3f}_{reps}.csv")

            with open(file_path, "wb") as f:
                while True:
                    data = conn.recv(4096)
                    if not data:
                        break
                    f.write(data)

            print(f"[TCP Server] File received and saved as {file_path}")
            file_count += 1
            conn.close()

    except Exception as e:
        print(f"[TCP Server] Error: {e}")
    finally:
        server_sock.close()
        print("[TCP Server] Closed")
        
# =========================================
# START UDP CONTROL AND SERVER
# =========================================
control_loop()
tcp_server()
send_sock.close()


