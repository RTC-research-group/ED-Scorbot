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
    secs: 1
    nsecs: 1
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
      nsecs: 1
points:
  -
    positions: [-2.18166156499, -1.48352986419, -1.96349540849, -1.57079632679, -3.14159265358]
    velocities: []
    accelerations: []
    effort: []
    time_from_start:
      secs: 2
      nsecs: 1
points:
  -
    positions: [-1.18166156499, -0.48352986419, -0.96349540849, -0.57079632679, -2.14159265358]
    velocities: []
    accelerations: []
    effort: []
    time_from_start:
      secs: 3
      nsecs: 1
points:
  -
    positions: [0, 0, 0, 0, 0]
    velocities: []
    accelerations: []
    effort: []
    time_from_start:
      secs: 4
      nsecs: 1
points:
  -
    positions: [1.18166156499, 0.48352986419, 0.96349540849, 0.57079632679, 3.14159265358]
    velocities: []
    accelerations: []
    effort: []
    time_from_start:
      secs: 5
      nsecs: 1
points:
  -
    positions: [2.18166156499, 1.48352986419, 1.96349540849, 1.57079632679, 3.14159265358]
    velocities: []
    accelerations: []
    effort: []
    time_from_start:
      secs: 6
      nsecs: 1" --once
done