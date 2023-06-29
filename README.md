# ED-Scorbot
Event-based Scorbot ER-VII

CHIST-ERA SMALL project (2020-2023)

SMALL investigates options for learning in low-power unconventional hardware that is based on spiking neural networks (SNNs) 
implemented in analog neuromorphic hardware combined with nano-scale memristive synaptic devices. Hence, the envisioned computational 
paradigm combines the three most promising avenues for minimizing energy consumption in hardware: (1) analog neuromorphic computation, (2) spike-based communication, and (3) memristive analog memory. “In the field” applications often demand online adaptation of such systems, which often necessitates hardware-averse training procedure. To overcome this problem, we will investigate the applicability  of “learning to learn” (L2L) to spiking memristive neuromorphic hardware. In an initial optimization, the hardware is trained to become a good learner for the target application. Here, arbitrarily complex learning algorithms can be used on a host system with the hardware “in the loop”. In the application itself, simpler algorithms – that can be easily implemented in neuromorphic hardware – provide adaptation of the hardware RSNNs. In summary, the goal of this project is to build versatile and adaptive low-power small size neuromorphic AI machinery based on SNNs with memristive synapses using L2L. We will deliver an experimental system in a real-world robotics environment to provide a proof of concept.

This repo is devoted to that robotics environment. The ED-Scorbot is an event-driven controlled robotic arm. The robot has been adapted for being controlled through spike-based controllers. More info can be obtained at http://www.rtc.us.es/ed-scorbot 

For this project, a simulation scenario is being developed for ROS. In Simulator folder you can find two different implementations: one compatible to RDS (Robotic Development Studio, available throgh this link: http://www.rosject.io/l/11c04055/ ), and another that can be executed in your own Linux computer.

# 2. Software interfaces for the ED-Scorbot

# 2.1. The jAER interface for the ED-Scorbot
For the real ED-Scorbot a jAER filter has been programmed for sending joint references to the internal spike-based PID controllers implemented in the FPGAs. The jAER folder contains the java file, a screen-shot of the software interface and a demonstration video for a simple trajectory (https://github.com/RTC-research-group/ED-Scorbot/blob/master/jaer/video_and_3D_reconstruction_ScanAllMotors.mp4).  

# 2.2. The Python interface for the ED-Scorbot
We have upgraded the previous jAER interface with a Python code that supports both a GUI and an API library that can be used remotely for commanding the robot remotely or locally. More info can be found in this another repo: https://github.com/RTC-research-group/Py-EDScorbotTool

# 3. Trajectories dataset
The ED-Scorbot is being used for SNN training. For that we are collecting this trajectories dataset with the following useful information for each trajectory:
- PKL file with a list of captures during the trajectory execution with: commanded reference positions to the joints of the robot, actual position of the joints taken from counters feeded with the optical encoders, timestamp of the current capture.
- AEDAT file with internal spiking activity of the six SPID controllers with a sequence of AE and the timestamp of each capture. The AE has 6 bits: from bit 5 to bit 0 they are Source1-Source0-Joint2-Joint1-Joint0-Polarity, being Source1-Source0 meaning the source of the spike ("00" for the output of the spike generator that converts the digital spike-reference to spiking activity; "01" for the SPID output; "10" for the SPID input; and "11" for the integral of the spiking encoder activity. Joint2 − Joint0 encode the joint number; and bit0 for the polarity of the captured spike.
- MP4 videos for the X, Y and Z view of the robot while it performs the trajectory.

These trajectories can be downloaded from a link provided after contacting by email with the authors: {scanas, epinerof, alinares}@us.es

A recent collection with Lemniscate trajectories is available in this repo: https://github.com/RTC-research-group/LemniscateEDScobotDS 