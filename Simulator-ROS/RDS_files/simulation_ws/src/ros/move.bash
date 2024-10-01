#!/bin/bash

# To stop control+C
trap "echo Exited!; exit;" SIGINT SIGTERM

# Loop indefinitely
while true; do
# First go to one limit of arm right 3
echo "Move to home"
  rostopic pub /scorbot/trajectory_controller/command trajectory_msgs/JointTrajectory "header:
  seq: 0
  stamp:
    secs: 0
    nsecs: 0
  frame_id: ''
joint_names: [base, shoulder, elbow, pitch, roll]
points:
  -
    positions: [0, 0, 0, 0, 0]
    velocities: []
    accelerations: []
    effort: []
    time_from_start:
      secs: 0
      nsecs: 990099009" --once

echo "Move to limit1"
  rostopic pub /scorbot/trajectory_controller/command trajectory_msgs/JointTrajectory "header:
  seq: 0
  stamp:
    secs: 0
    nsecs: 0
  frame_id: ''
joint_names: [base, shoulder, elbow, pitch, roll]
points:
  -
    positions: [-2.18166156499, -1.48352986419, -1.96349540849, -1.57079632679, -3.14159265358]
    velocities: []
    accelerations: []
    effort: []
    time_from_start:
      secs: 0
      nsecs: 990099009" --once
#      nsecs: 990099009" --once

echo "Move to home"
  rostopic pub /scorbot/trajectory_controller/command trajectory_msgs/JointTrajectory "header:
  seq: 0
  stamp:
    secs: 0
    nsecs: 0
  frame_id: ''
joint_names: [base, shoulder, elbow, pitch, roll]
points:
  -
    positions: [0, 0, 0, 0, 0]
    velocities: []
    accelerations: []
    effort: []
    time_from_start:
      secs: 0
      nsecs: 990099009" --once


echo "Move to half limit2"
rostopic pub /scorbot/trajectory_controller/command trajectory_msgs/JointTrajectory "header:
  seq: 0
  stamp:
    secs: 0
    nsecs: 0
  frame_id: ''
joint_names: [base, shoulder, elbow, pitch, roll]
points:
  -
    positions: [1.18166156499, 0.48352986419, 0.96349540849, 0.57079632679, 3.14159265358]
    velocities: []
    accelerations: []
    effort: []
    time_from_start:
      secs: 0
      nsecs: 990099009" --once 

done