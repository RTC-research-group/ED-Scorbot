clear
clc

%% Add folder path
addpath("urdf");
%% Robotic arm parameters
%robot_urdf = 'scorbot_ER_VII.urdf'; % Ideal robot
robot_urdf = 'ED_Scorbot.urdf';      % Real robot
ee = 'end_effector_link';

%% Load and display robot
robot = importrobot(robot_urdf);
homeConfig = homeConfiguration(robot);

for i = 1:length(homeConfig)
    jointName = homeConfig(i).JointName;
    jointPosition = rad2deg(homeConfig(i).JointPosition); 
    fprintf('%s: %.2f deg\n', jointName, jointPosition);
end

%% Show real ED-Scorbot(virtual) home
figure
show(robot, homeConfig, 'Frames','off');
axis equal;
view(3);
grid off;
axis([-0.5 1.0 -0.4 0.5 0 0.8]);
title('Real ED-Scorbot home');
view(20, 20);
grid on;

%% Calculate the FK at home position
q1 = 0; q2 = 0; q3 = 0; q4 = 0; q5 = 0; q6 = 0; q7 = 0;

joints_rad = [q1,q2,q3,q4,q5,q6,q7];

n = size(joints_rad, 1);
ee_positions = zeros(n, 3); 
robot.DataFormat = 'row';

for i = 1:n
    config_ref = joints_rad(i, :);            % configuration in radians
    tform_ref = getTransform(robot, config_ref, ee);
    ee_positions(i, :) = tform_ref(1:3, 4)';  % extract Cartesian positions
end

x_pos = ee_positions(1,1);
y_pos = ee_positions(1,2);
z_pos = ee_positions(1,3);
disp(['x position: ', num2str(x_pos), ' m']);
disp(['y position: ', num2str(y_pos), ' m']);
disp(['z position: ', num2str(z_pos), ' m']);