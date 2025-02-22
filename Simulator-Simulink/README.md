# Simulation of the ED-Scorbot by Simulink

**This repository is oriented to perform the simulation of the
EDScorbot with Matlab and Simulink.**

**To perform the simulation, follow the steps below:**

## 1. Load files in Matlab

   **There are two ways to perform the simulations and they are as follows:**

### a. Accessing to Matlab live with the following link:

       https://matlab.mathworks.com/open/github/v1?repo=RTC-research-group/ED-Scorbot&project=https://github.com/RTC-research-group/ED-Scorbot/tree/master/Simulator-Simulink 


When entering the link Matlab suggests saving the repository as
***/MATLAB Drive/Repositories/ED-Scorbot***. Save it that way.
Inside the ED-Scorbot repository in Matlab live, go to the path: ***/Simulator-Simulink/Simulation***. Here are all the files needed to run the simulations.

### b. Matlab is installed on the computer: 
 #### Step 1: Download the following folders from the repository ED-Scorbot/Simulator-Simulink:
   
   - **STL-files:** contains the parts of the EDScorbot in STL format.
  
   - **Simulation:** contains the files of Matlab and Simulink files.
 #### Step 2: Modify the following Simulink files:

   - #### EDScorbot_Arm.slx: 
       Inside this file you have to modify the following blocks: **base**, **body**, **upper_arm**, **forearm**, **flange**, **gripper_base_link**, **gripper_finger_right** and **gripper_finger_left**. Once inside the element, look for the block ***visual***; inside this block, put the path where the respective STL file is stored. Remember that these STL files are in the previously downloaded ***STL-files*** folder.
    
   - #### IJC_Control.slx:
      Inside this file, you must place the block called ***Scorbot***. Once inside this block, modify the path of the STL files corresponding to the elements of the robot, as was done in ***EDScorbot_Arm.slx***.
    
   - #### CTC_Control.slx:
      To avoid the same procedure as the previous file, replace the ***Scorbot*** block of this file (***CTC_Control.slx***) with the ***Scorbot*** block of the ***IJC_Control.slx*** file. 


## 2. Perform simulation:

#### Step 1: Execute the file ***Load_Robot_and_Points.m*** this file will load the robot in the workspace and the trajectories.

#### Step 2: Open the file corresponding to the controller: ***IJC_Control.slx*** or ***CTC_Control.slx***.
Once inside the selected file change the value of the ***Set*** block with **1** or **0**, this will allow it to activate one of the two trajectory generators. 

- To generate a square trajectory: ***Set*** = 1 and set 7.5s as simulation time.
- To generate a lemniscate trajectory: ***Set*** = 0 and set 10s as simulation time.

## 3. Result graphs:
After running the simulation, we proceed to go to the Matlab environment where we will execute the file corresponding to the simulation carried out with one of the two types of control. 
      
a. If the Simulink simulation was done with the ***IJC_Control.slx*** file, the ***IJC_Graphics.m*** file must be run. 
      
b. If the Simulink simulation was done with the ***CTC_Control.slx*** file, the ***CTC_Graphics.m*** file must be run.
      
These two Matlab files (***IJC_Graphics.m*** and ***CTC_Graphics.m*** ) will allow us to obtain: 
      
- The trajectories generated by the robot concerning the reference trajectory.
- The deviations of the x, y, and z components in time, concerning the reference Cartesian coordinates.
- An error graph between the points of the reference trajectory and the one generated by the robot and finally the **RMSE**. 

