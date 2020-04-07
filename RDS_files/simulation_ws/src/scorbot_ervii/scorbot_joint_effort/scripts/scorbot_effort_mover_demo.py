#!/usr/bin/env python

import math
import rospy
from sensor_msgs.msg import JointState
from std_msgs.msg import Float64
import roslib  #; roslib.load_manifest('scorbot_joint')

# Topics to send commands:
pub_base = rospy.Publisher('/scorbot/base_effort_controller/command', Float64, queue_size=10)
pub_shoulder = rospy.Publisher('/scorbot/shoulder_effort_controller/command', Float64, queue_size=10)
pub_elbow = rospy.Publisher('/scorbot/elbow_effort_controller/command', Float64, queue_size=10)
pub_pitch = rospy.Publisher('/scorbot/pitch_effort_controller/command', Float64, queue_size=10)
pub_roll = rospy.Publisher('/scorbot/roll_effort_controller/command', Float64, queue_size=10)
pub_gripper_finger_left = rospy.Publisher('/scorbot/gripper_finger_left_effort_controller/command', Float64, queue_size=10)
pub_gripper_finger_right = rospy.Publisher('/scorbot/gripper_finger_right_effort_controller/command', Float64, queue_size=10)

# Home positions:
home_base = 0
home_shoulder = 0
home_elbow = 0
home_pitch = 0
home_roll = 0
home_gripper_finger_left = 0
home_gripper_finger_right = 0

# Global variables:
current_position = []
printJointStates = False


#callback function: when a joint_states message arrives, save it
def joint_states_callback(data):
    global current_position 
    global printJointStates
    current_position = data
    if printJointStates:
        print current_position.position
        print


# Demo function: moves the robot between two positions. 
# Every 5 seconds starts moving to next position.
def mover():

    # Rate = 1 means 1 second, and 0.2 means 5 seconds
    rate = rospy.Rate(0.2)
    while not rospy.is_shutdown():

        pub_base.publish (home_base)
        pub_shoulder.publish (home_shoulder)
        pub_elbow.publish (home_elbow)
        pub_pitch.publish (home_pitch)
        pub_roll.publish (home_roll)
        pub_gripper_finger_left.publish (home_gripper_finger_left)
        pub_gripper_finger_right.publish (home_gripper_finger_right)

        rate.sleep()

        pub_base.publish (2)
        pub_shoulder.publish (-2)
        pub_elbow.publish (-1)
        pub_pitch.publish (-1)
        pub_roll.publish (2)
        pub_gripper_finger_left.publish (-2)
        pub_gripper_finger_right.publish (-2)

        rate.sleep()



if __name__ == '__main__':
    try:
        rospy.init_node('scorbot_effort_mover_demo')
        # The "joint_states_callback" prints joint positions (for debugging if necessary).
        # To avoid/allow printing position messages just set global variable "printJointStates" to "False/True".
        rospy.Subscriber('/scorbot/joint_states', JointState, joint_states_callback)
        mover()
        # rospy.spin()
    except rospy.ROSInterruptException:
        pass

