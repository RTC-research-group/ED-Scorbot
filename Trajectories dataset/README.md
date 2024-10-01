# Trajectories dataset


The ED-Scorbot is being used for SNN training. For that we are collecting this trajectories dataset with the following useful information for each trajectory:

- PKL file with a list of captures during the trajectory execution with: commanded reference positions to the joints of the robot, actual position of the joints taken from counters feeded with the optical encoders, timestamp of the current capture.
- AEDAT file with internal spiking activity of the six SPID controllers with a sequence of AE and the timestamp of each capture. The AE has 6 bits: from bit 5 to bit 0 they are Source1-Source0-Joint2-Joint1-Joint0-Polarity, being Source1-Source0 meaning the source of the spike ("00" for the output of the spike generator that converts the digital spike-reference to spiking activity; "01" for the SPID output; "10" for the SPID input; and "11" for the integral of the spiking encoder activity. Joint2 − Joint0 encode the joint number; and bit0 for the polarity of the captured spike.
- MP4 videos for the X, Y and Z view of the robot while it performs the trajectory.


These trajectories can be downloaded from a link provided after contacting by email with the authors (alinares@us.es)

A recent collection with Lemniscate trajectories is available in this repo: https://github.com/RTC-research-group/LemniscateEDScobotDS 
