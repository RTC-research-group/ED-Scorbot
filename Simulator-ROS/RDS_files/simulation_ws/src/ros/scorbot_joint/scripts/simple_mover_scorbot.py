#!/usr/bin/env python

import math
import rospy
from std_msgs.msg import Float64
import roslib; roslib.load_manifest('scorbot_joint')

def mover():
    pub_base = rospy.Publisher('/scorbot/base_position_controller/command', Float64, queue_size=10)
    pub_shoulder = rospy.Publisher('/scorbot/shoulder_position_controller/command', Float64, queue_size=10)
    pub_elbow = rospy.Publisher('/scorbot/elbow_position_controller/command', Float64, queue_size=10)
    pub_pitch = rospy.Publisher('/scorbot/pitch_position_controller/command', Float64, queue_size=10)
    pub_roll = rospy.Publisher('/scorbot/roll_position_controller/command', Float64, queue_size=10)

    # pub = rospy.Publisher('/scorbot/trajectory_controller/command', JointTrajectory, queue_size=10)

    rospy.init_node('simple_mover_scorbot')
    rate = rospy.Rate(1)
    start_time = 0

    while not start_time:
        start_time = rospy.Time.now().to_sec()

    while not rospy.is_shutdown():
        elapsed = rospy.Time.now().to_sec() - start_time

        pub_base.publish (math.sin(2*math.pi*0.1*elapsed)*(math.pi/2))
        pub_shoulder.publish (math.sin(2*math.pi*0.1*elapsed)*(math.pi/2))
        pub_elbow.publish (math.sin(2*math.pi*0.1*elapsed)*(math.pi/2))
        pub_pitch.publish (math.sin(2*math.pi*0.1*elapsed)*(math.pi/2))
        pub_roll.publish (math.sin(2*math.pi*0.1*elapsed)*(math.pi/2))

        rate.sleep()

if __name__ == '__main__':
    try:
        mover()
    except rospy.ROSInterruptException:
        pass
