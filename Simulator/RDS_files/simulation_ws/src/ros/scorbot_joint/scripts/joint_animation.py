#!/usr/bin/env python

import roslib; roslib.load_manifest('scorbot_joint')
import rospy, math, time

from trajectory_msgs.msg import JointTrajectory, JointTrajectoryPoint

def jointTrajectoryCommand():
    # Initialize the node
    rospy.init_node('joint_control')

    print rospy.get_rostime().to_sec()
    while rospy.get_rostime().to_sec() == 0.0:
        time.sleep(0.1)
        print rospy.get_rostime().to_sec()

    pub = rospy.Publisher('/scorbot/trajectory_controller/command', JointTrajectory, queue_size=10)
    jt = JointTrajectory()

    jt.header.stamp.nsecs = 0 # = rospy.Time.now()
    jt.header.stamp.secs = 0
    jt.header.seq = 0
    jt.header.frame_id = ""

#    jt.joint_names = "[base, shoulder, elbow, pitch, roll]"
    jt.joint_names.append("base")
    jt.joint_names.append("shoulder")
    jt.joint_names.append("elbow")
    jt.joint_names.append("pitch")
    jt.joint_names.append("roll")

    #print jt.joint_names 

    n = 1
    dt = 0
    rps = 0.05
    for i in range (n):
        p = JointTrajectoryPoint()
        """
        theta = rps*2.0*math.pi*i*dt
        x1 = -20*math.sin(2*theta)
        x2 =  20*math.sin(1*theta)
        """
        
        #p.positions = [x1, x2, x2, x2, x2]
        p.positions = [0, 0, 0, 0, 0]
        p.time_from_start.secs = dt
        p.time_from_start.nsecs = 10
        #print p 
        jt.points.append(p)
        """        
        p.positions = [10, -10, -10, -5, 1]
        p.time_from_start.secs = dt
        p.time_from_start.nsecs = 10
        #print p 
        jt.points.append(p)
        """       
        rospy.loginfo("test: iteration[%d]",i)

    pub.publish(jt)
    print jt
    rospy.spin()

if __name__ == '__main__':
    try:
        jointTrajectoryCommand()
    except rospy.ROSInterruptException: pass
