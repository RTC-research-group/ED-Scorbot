clear
clc

%{
 "This script is used to generate trajectories and obtain joint positions 
  using inverse kinematics. It is also used to configure all the parameters 
  required for accuracy and precision tests." 
%} 

%% Add folder path
addpath("urdf");
addpath("functions");

%% Trajectory conditions
% square or lemniscate
trajectory_name = 'lemniscate';

% Square settings
axis_const = 'x';             % rotation: "x", "y" or "z"
pts_step = 8;                 % points between base points

% Lemniscate settings
nPointsLem = 100;              % points of the lemniscate
a = 0.25;                     % Lemniscata scale
rot_select = 4;               % select 1,2,3 or 4 to rotate mode

% Save or no save the trajectory data
save_select = false;          % save the trajectory in a .json file
trajReps = 1;                 % number of repetitions of the trajectory

%% Load robotic arm 
robot_urdf = 'ED_Scorbot.urdf';
ee = 'end_effector_link';

%% Load and display robot
robot = importrobot(robot_urdf);
robot2 = copy(robot);
robot2.Gravity = [0 0 -9.80665];

% Configuration with the offsets already applied
currentRobotJConfig = homeConfiguration(robot);

%% Types of trajectories

switch trajectory_name

    case 'square'

        % Base points
        x1 = 0.2; x2 = 0;
        x3 = 0.4; x4 = 0.6;
        y1 = 0.2; y2 = 0;
        z1 = 0.5; z2 = 0.7;

        switch axis_const
            case 'x'
                const = 0.5;
                y_ = [y1 y1 y2 y2 y1];
                z_ = [z1 z2 z2 z1 z1];
                x_ = ones(size(y_)) * const;
            
            case 'y'
                const = 0.5;
                x_ = [x1 x1 x2 x2 x1];
                z_ = [z1 z2 z2 z1 z1];
                y_ = ones(size(x_)) * const;

            case 'z'
                const = 0.45;
                x_ = [x3 x3 x4 x4 x3];
                y_ = [y2 y1 y1 y2 y2];
                z_ = ones(size(y_)) * const;
        end
    
        nSeg = length(x_) - 1;
        pts_per_seg = pts_step + 2;
        nTotal = nSeg * (pts_per_seg - 1) + 1;
    
        x = zeros(1, nTotal);
        y = zeros(1, nTotal);
        z = zeros(1, nTotal);
    
        idx = 1;
    
        for i = 1:nSeg
            xi = linspace(x_(i), x_(i+1), pts_per_seg);
            yi = linspace(y_(i), y_(i+1), pts_per_seg);
            zi = linspace(z_(i), z_(i+1), pts_per_seg);
    
            if i < nSeg
                xi(end) = [];
                yi(end) = [];
                zi(end) = [];
            end
    
            n = length(xi);
            x(idx:idx+n-1) = xi;
            y(idx:idx+n-1) = yi;
            z(idx:idx+n-1) = zi;
    
            idx = idx + n;
        end
    
        trajectory = [x; y; z];
    
        % ---- Distance between consecutive points ----
        switch axis_const
            case 'x'
                step = abs(z(2) - z(1)) * 100;  % cm
            case 'y'
                step = abs(z(2) - z(1)) * 100;  % cm
            case 'z'
                step = abs(y(2) - y(1)) * 100;  % cm
        end


    case 'lemniscate'

        % ---- Parameters ----
        t = linspace(0, 2*pi, nPointsLem);
    
        % ---- Translation offset ----
        x_init = 0.4;
        y_init = -0.0384;
        z_init = 0.35;
    
        % ---- Lemniscate in XY plane ----
        x_ = (a * sin(t) .* cos(t)) ./ (1 + cos(t).^2);
        y_ = (a * sin(t)) ./ (1 + cos(t).^2);
        z_ = zeros(size(t));  % flat in XY
    
        % ---- Combine points ----
        points = [x_; y_; z_];  % 3 x N
    
        % ---- Apply rotation ----
        switch rot_select
            case 1
                alpha = 0; phi = 0; theta = 0;
                axis_const = 'z';
            case 2
                alpha = 0; phi = pi/2; theta = 0;
                axis_const = 'Ry90';
            case 3
                alpha = pi/2; phi = 0; theta = pi/2;
                axis_const = 'Rz90Rx90';
            case 4
                alpha = pi/3; phi = 0; theta = -pi/3;
                axis_const = 'Rz60Rx-60';
        end
    
        R = rotationMatrix(alpha, phi, theta);
        rotated = R * points;
    
        % ---- Apply translation ----
        x = x_init + rotated(1, :);
        y = y_init + rotated(2, :);
        z = z_init + rotated(3, :);
    
        % ---- Final trajectory ----
        trajectory = [x; y; z];
    
        % ---- Step ----
        % Not uniform like a square, optional: 
        % calculate the average between points
        step = mean(sqrt(diff(x).^2 + diff(y).^2 + diff(z).^2)) * 100;  % cm
end

%% Inverse Kinematics
q = IK_fcn(trajectory);

%% Access values by joint:
q1 = q(:,1)';
q2 = q(:,2)';
q3 = q(:,3)';
q4 = q(:,4)';
q5 = zeros(length(q1),1)';
q6 = q5;
q7 = q5;

traj_joints = [q1; q2; q3; q4; q5; q6; q7];
traj_joints = repmat(traj_joints, 1, trajReps);
trajectory = repmat(trajectory, 1, trajReps);

% Duplicate the last value in order to save the previous 
% value when sending data via UDP.
traj_joints = [traj_joints, traj_joints(:,end)];
trajectory = [trajectory, trajectory(:,end)];
joints_degrees = rad2deg(traj_joints);

% Convert to digital Spikes references
q1_dsr = int32(deg2dsr(1,joints_degrees(1,:)));
q2_dsr = int32(deg2dsr(2,joints_degrees(2,:)));
q3_dsr = int32(deg2dsr(3,joints_degrees(3,:)));
q4_dsr = int32(deg2dsr(4,joints_degrees(4,:)));
q5_dsr = int32(zeros(length(q1_dsr),1))';
q6_dsr = q5_dsr;
dsr_joints = [q1_dsr; q2_dsr; q3_dsr; q4_dsr; q5_dsr; q6_dsr];

% Simulation variables
jointsPos = traj_joints';
ee_pos = trajectory';

%% Save jointsReferences in .json
% Important: The format of the saved file name is as follows: 
% trajectory-name_rotation_number-points_trajRep

% Data to save
data.joints_degrees = joints_degrees';
data.joints_dsr     = dsr_joints';

if save_select == true
    % Folder
    folder_name = sprintf('%s_%s_%d_%.2f_%d', ...
        trajectory_name, axis_const, (length(trajectory)-1)/trajReps, step, trajReps);
    
    save_folder = fullfile('utils', 'trajectories', folder_name);
    if ~exist(save_folder, 'dir')
        mkdir(save_folder);
    end
    
    % Save each field as JSON
    fields = fieldnames(data);
    
    for i = 1:numel(fields)
        name = fields{i};
        jsonText = jsonencode(data.(name), 'PrettyPrint', true);
    
        filename = fullfile(save_folder, name + ".json");
        fid = fopen(filename, 'w');
        fwrite(fid, jsonText, 'char');
        fclose(fid);
    end
    
    save(fullfile(save_folder, 'trajectory.mat'), 'trajectory');
end

%% Visualization and simulation
robot.DataFormat = 'row'; 
dt = 0.00005;      % pause between points
figure;
hold on;
axis equal;
view(3);
grid on;
axis([-0.5 0.8 -0.4 0.5 0 0.8]);
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Trajectory simulation');
show(robot, jointsPos(1,:), 'PreservePlot', false, 'Frames', 'on');
view(125, 30);
trajectoryPlot = animatedline('Color', 'r', 'LineWidth', 1);
trajDots = gobjects(length(trajectory), 1);  

for i = 1:(length(trajectory))
    config = jointsPos(i,:);
    show(robot, config, 'PreservePlot', false, 'Frames', 'off');
    tform = getTransform(robot, config, ee); 
    pos = tform2trvec(tform);
    ee_pos(i,:) = pos;
    addpoints(trajectoryPlot, pos(1), pos(2), pos(3));
    trajDots(i) = plot3(pos(1), pos(2), pos(3), 'ro', 'MarkerSize', 3, ...
        'MarkerFaceColor', 'b');
    drawnow;
    pause(dt);
end

rotate3d on;
hold off;

disp('----- CONDITIONS -----');
disp(['number of points in the trajectory: ', num2str(length(trajectory)-1)/trajReps]);
disp(['Distance between points: ', num2str(step), ' cm']);
