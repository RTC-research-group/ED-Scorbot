function [q] = IK_fcn(trajectory)

%% Add folder path
addpath("urdf");

%% Load robot
%robot_urdf = 'ED_Scorbot.urdf';
robot_urdf = 'ED_Scorbot.urdf';
ee = 'end_effector_link';
robot = importrobot(robot_urdf);
%robot.DataFormat = 'row';

%% Inverse Kinematics
q  = zeros(size(trajectory,1), 7);
ik = inverseKinematics('RigidBodyTree', robot);
ik.SolverParameters.AllowRandomRestart = false;
weights = [0 0 0 1 1 1]; % weights: [orientation(3), position(3)]
currentRobotJConfig = homeConfiguration(robot);
initialGuess = currentRobotJConfig;

for idx = 1:size(trajectory',1)
    tform = trvec2tform(trajectory(:,idx)');
    [configSol, ~] = ik(ee, tform, weights, initialGuess);
    q(idx,:) = [configSol(1:7).JointPosition]; 
    initialGuess = configSol;
end