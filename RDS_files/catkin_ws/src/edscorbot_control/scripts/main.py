#!/usr/bin/env python
# license removed for brevity
import rospy
from std_msgs.msg import Float64
import math

def talker():
    pub1 = rospy.Publisher('/rrbot/joint1_position_controller/command', Float64, queue_size=10)
    pub2 = rospy.Publisher('/rrbot/joint2_position_controller/command', Float64, queue_size=10)
    rospy.init_node('rrbot_talker', anonymous=True)
    rate = rospy.Rate(10) # 10hz
    i = 0
    while not rospy.is_shutdown():
        #hello_str = "hello world %s" % rospy.get_time()
        position = math.sin(i) #radians, not degrees
        rospy.loginfo(position)
        pub1.publish(position)
        pub2.publish(position)
        rate.sleep()
        i += 0.01

if __name__ == '__main__':
    try:
        talker()
    except rospy.ROSInterruptException:
        pass