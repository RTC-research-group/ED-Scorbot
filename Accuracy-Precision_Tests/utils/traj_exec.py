import socket
import struct
import time
import numpy as np
import os
import json

# =====================================================
# ANGLES REFERENCES
# =====================================================
traj_name = "square" 
axis_const = 'x'
step = 30            # steps in cm. 
nPoints = 9
reps = 1               # Number of repetitions
SEND_INTERVAL = 1.000  # 1.000, 0.750, 0.500, 0.250, 0.200, 0.150, 0.100

# =====================================================
# READ .JSON FILE WITH REFERENCES
# =====================================================
json_path = os.path.join("trajectories", 
                         f"{traj_name}_{axis_const}_{nPoints}_{step:.2f}_{reps}", 
                         "joints_dsr.json")

with open(json_path, "r") as f:
    data = json.load(f)

# Convertir a array NumPy
q = np.array(data)   

# Extraer joints individuales
q1_dsr = q[:, 0]
q2_dsr = q[:, 1]
q3_dsr = q[:, 2]
q4_dsr = q[:, 3]

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
    f"{traj_name}_{axis_const}_{nPoints}_{step:.2f}_{reps}"
)
os.makedirs(save_dir, exist_ok=True)

# ==============================
# PRINT SPIKES REFERENCES
# ==============================

print(f"Digital SR Joint1: {q1_dsr}")
print(f"Digital SR Joint2: {q2_dsr}")
print(f"Digital SR Joint3: {q3_dsr}")
print(f"Digital SR Joint4: {q4_dsr}")

q = list(zip(q1_dsr, q2_dsr, q3_dsr, q4_dsr))
reference_list = list(zip(q1_dsr, q2_dsr, q3_dsr, q4_dsr))

# =====================================================
# MAIN LOOP
# =====================================================
def control_loop():
    print("Starting reference sequence...")
    ref_count = 0
    round_of = 1
    i = 0

    for ref in reference_list:

        # Send references
        send_sock.sendto(struct.pack('4f', *ref), (SEND_IP, SEND_PORT))
        print(f"Round #: {round_of}, Spikes refs: {ref}")
        ref_count += 1

        if i >= ((len(q1_dsr)/reps)-2):
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
                file_path = os.path.join(save_dir, f"SR_{SEND_INTERVAL:.3f}.csv")
            else:
                file_path = os.path.join(save_dir, f"COUNT_{SEND_INTERVAL:.3f}.csv")

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


