#!/usr/bin/env python

import roslib #; roslib.load_manifest('scorbot_gazebo')
import rospy, math, time

from trajectory_msgs.msg import JointTrajectory, JointTrajectoryPoint

def jointTrajectoryCommand():
    
    pub = rospy.Publisher('/scorbot/trajectory_controller/command', JointTrajectory, queue_size=10)
    rospy.init_node('joint_control')
    rate = rospy.Rate(1) # 10hz
    M_PI = 3.14159265359
    DEG2RAD = M_PI/180
    seq = 0.0
    base_init = 125
    shoulder_init = 85
    elbow_init = 112
    roll_init = 180
    pitch_init = 90
    base_angle = base_init
    shoulder_angle = shoulder_init
    elbow_angle = elbow_init
    roll_angle = roll_init
    pitch_angle = pitch_init
    while not rospy.is_shutdown():
        jt = JointTrajectory()
        jt.header.stamp.nsecs = 0
        jt.header.stamp.secs = 0
        jt.header.seq = seq
        jt.header.frame_id = ""
        seq = seq + 1

        jt.joint_names.append("base")
        jt.joint_names.append("shoulder")
        jt.joint_names.append("elbow")
        jt.joint_names.append("pitch")
        jt.joint_names.append("roll")


        p = JointTrajectoryPoint()
        p.positions.append(base_angle * DEG2RAD)
        p.positions.append(shoulder_angle * DEG2RAD)
        p.positions.append(elbow_angle * DEG2RAD)
        p.positions.append(pitch_angle * DEG2RAD)
        p.positions.append(roll_angle * DEG2RAD)
        p.time_from_start.secs = 0
        p.time_from_start.nsecs = 10
        p.velocities = []
        p.accelerations = []
        p.effort = []
        jt.points.append(p)
        print (jt)
        print ("----------------------")
        print ("\n")
        pub.publish(jt)
        base_angle = base_angle - 10
        if (base_angle < -125): 
            base_angle = base_init
        shoulder_angle = shoulder_angle - 10
        if (shoulder_angle < -85):
            shoulder_angle = shoulder_init
        elbow_angle = elbow_angle - 10
        if (elbow_angle < -110):
            elbow_angle = elbow_init
        roll_angle = roll_angle - 10
        if (roll_angle < -180):
            roll_angle = roll_init
        pitch_angle = pitch_angle - 10
        if (pitch_angle < -90):
            pitch_angle = pitch_init
        rate.sleep()

if __name__ == '__main__':
    try:
        jointTrajectoryCommand()
    except rospy.ROSInterruptException: pass

