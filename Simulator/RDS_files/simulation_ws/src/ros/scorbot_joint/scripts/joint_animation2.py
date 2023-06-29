#!/usr/bin/env python

import roslib; 
roslib.load_manifest('scorbot_joint')

import rospy, actionlib
from trajectory_msgs.msg import *
from pr2_controllers_msgs.msg import *


if __name__ == '__main__':
    try:
        rospy.init_node('joint_control', anonymous=True)
        client = actionlib.SimpleActionClient('/scorbot/trajectory_controller/follow_joint_trajectory/goal', JointTrajectoryAction)
        client.wait_for_server()

        goal = pr2_controllers_msgs.msg.JointTrajectoryGoal()
        goal.trajectory.joint_names.append("base")
        goal.trajectory.joint_names.append("shoulder")
        goal.trajectory.joint_names.append("elbow")
        goal.trajectory.joint_names.append("pitch")
        goal.trajectory.joint_names.append("roll")
        print goal.trajectory.joint_names

        point1 = trajectory_msgs.msg.JointTrajectoryPoint()
        point2 = trajectory_msgs.msg.JointTrajectoryPoint()
        point1.positions = [0.0, 0.0, 0.0,  0.0, 0.0]
        point2.positions = [1.5, 1.0, 0.5,  1.0, 1.5]

        goal.trajectory.points = [point1, point2]

        goal.trajectory.points[0].time_from_start = rospy.Duration(2.0)
        goal.trajectory.points[1].time_from_start = rospy.Duration(4.0)

        goal.trajectory.header.stamp = rospy.Time.now()+rospy.Duration(1.0)

        client.send_goal(goal)
        print client.wait_for_result()
    except rospy.ROSInterruptException: pass