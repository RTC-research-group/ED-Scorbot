function [ee_positions] = FK_fcn(joints_rad)

% ED_Scorbot_FK_fcn Summary of this function goes here
%  This function calculates the forward kinematics of the ED-Scorbot 
%  from a vector of joint positions.

%% Add folder path
addpath("urdf");

%% Load robot
%robot_urdf = 'scorbot_ER_VII.urdf'; % Ideal robot
robot_urdf = 'ED_Scorbot.urdf';      % Real robot
ee = 'end_effector_link';
robot = importrobot(robot_urdf);
robot.DataFormat = 'row';

%% 
n = size(joints_rad, 1);
ee_positions = zeros(n, 3);  

for i = 1:n
    config_ref = joints_rad(i, :);            % configuration in radians
    tform_ref = getTransform(robot, config_ref, ee);
    ee_positions(i, :) = tform_ref(1:3, 4)';  % extract Cartesian positions
end

end