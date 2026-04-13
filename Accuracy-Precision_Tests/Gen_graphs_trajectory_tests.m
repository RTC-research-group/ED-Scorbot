clear
clc

%{
 "This script is used to generate error graphs for the 
  TCP (Tool Center Point) and the joints, based on the joint positions 
  of the reference path and the actual path, with different 
  Command time interval (CTI).
  The joint positions were obtained from the counter values, which were 
  subsequently converted into angles." 
%} 

%% Settings
% Square
% traj_name = "square";  % Trajectory name
% axis_const = 'x';      % Rotation
% nPoints = 37;          % number of points
% step = 2.22;           % Point to Point distance (PTPD)

% Lemniscate
traj_name = "lemniscate"; % Trajectory name
axis_const = 'Rz60Rx-60'; % Rotation
nPoints = 50;             % number of points
step = 2.67;              % Point to Point distance (PTPD) in cm
traj_reps = 4;

% Command time interval (CTI)
ti1 = 1.000; %CTI 1
ti2 = 0.500; %CTI 2
ti3 = 0.250; %CTI 3

% Another settings
nJoints = 4;

%% Add folder path
addpath("urdf");
addpath("functions");

%% folders of data
folder_results = fullfile('utils','accuracy_and_precision_test_data', ...
                  sprintf('%s_%s_%d_%.2f_%d', traj_name,axis_const,nPoints, ...
                  step,traj_reps));

folder_traj = fullfile('utils','trajectories', ...
                  sprintf('%s_%s_%d_%.2f_%d', traj_name,axis_const,nPoints, ...
                  step,traj_reps));

%% Reference trajectory data
dir_traj = fullfile(folder_traj, 'trajectory.mat');
data = load(dir_traj);
trajectory_ref = squeeze(data.trajectory(:,1:end-1))';
x_ref = trajectory_ref(:,1);
y_ref = trajectory_ref(:,2);
z_ref = trajectory_ref(:,3);

% Joints references
joints_ref = IK_fcn(trajectory_ref'); % trajectory must be 3xN


%% Load data
ti = [ti1, ti2, ti3];
n = numel(ti);

% Variables
cmd_joints  = cell(1, n);
real_joints = cell(1, n);
joints_rad = cell(1, n);
time = cell(1,n);
x_m = cell(1,n); y_m = cell(1,n); z_m = cell(1,n);
tcp_vel = cell(1,n); tcp_acc = cell(1,n);
tcp_vel_mean = cell(1,n); tcp_acc_mean = cell(1,n);
tcp_ed = cell(1,n); tcp_rmse = cell(1,n);
joints_abs_err = cell(1,n); joints_rmse = cell(1,n);

for k = 1:n
    filename_SR = sprintf('SR_%.3f.csv', ti(k));

    filename_COUNT = sprintf('COUNT_%.3f.csv', ti(k));

    dir_SR    = fullfile(folder_results, filename_SR);
    dir_COUNT = fullfile(folder_results, filename_COUNT);

    cmd_joints{k}  = readtable(dir_SR);
    real_joints{k} = readtable(dir_COUNT);
    joints_count = real_joints{k}{1:end,1:4};
    q1_m = deg2rad(count2deg(1,joints_count(:, 1)));  
    q2_m = deg2rad(count2deg(2,joints_count(:, 2))); 
    q3_m = deg2rad(count2deg(3,joints_count(:, 3))); 
    q4_m = deg2rad(count2deg(4,joints_count(:, 4))); 
    q5_m = zeros(length(q1_m),1);
    q6_m = zeros(length(q1_m),1);
    q7_m = zeros(length(q1_m),1);
    joints_rad{k} = [q1_m, q2_m, q3_m, q4_m, q5_m, q6_m, q7_m];
    
    % Calculate forward kinematics
    ee_pos = (FK_fcn(joints_rad{k}));
    x_m{k} = ee_pos(:,1);
    y_m{k} = ee_pos(:,2);
    z_m{k} = ee_pos(:,3);
    
    % Create a vector with reference times
    N = size(joints_rad{k},1);
    time{k} = (0:N-1) * ti(k);

    % Calculate the TCP error for each CTI
    tcp_err = TCP_err_fcn(x_ref,y_ref,z_ref,x_m{k},y_m{k},z_m{k});
    tcp_ed{k} = tcp_err.ed;
    tcp_rmse{k} = tcp_err.rmse;

    % Calculate the RMSE for each joint for each CTI
    joints_err = joint_err_fcn(joints_ref,joints_rad{k});
    joints_abs_err{k} = joints_err.abs;
    joints_rmse{k} = joints_err.rmse;

end

%% TCP rmse
disp(' ===== TCP RMSE =====');
disp(['Time interval: ', num2str(ti(1)), 's', ' rmse: ', ...
                    num2str(round(tcp_rmse{1}*1000,3)),'mm',]);
disp(['Time interval: ', num2str(ti(2)), 's', ' rmse: ', ...
                    num2str(round(tcp_rmse{2}*1000,3)),'mm',]);
disp(['Time interval: ', num2str(ti(3)), 's', ' rmse: ', ...
                    num2str(round(tcp_rmse{3}*1000,3)),'mm',]);

%% Joints rmse
disp(' ===== JOINTS RMSE =====');
disp(['Time interval: ', num2str(ti(1)), 's', ' rmse: ', ...
                    num2str(round(rad2deg(joints_rmse{1}(1,1:4)),3)),' Degrees']);
disp(['Time interval: ', num2str(ti(2)), 's', ' rmse: ', ...
                    num2str(round(rad2deg(joints_rmse{2}(1,1:4)),3)),' Degrees']);
disp(['Time interval: ', num2str(ti(3)), 's', ' rmse: ', ...
                    num2str(round(rad2deg(joints_rmse{3}(1,1:4)),3)),' Degrees']);
 
%% EE Trajectory
figure;
hold on;  
plot3(x_ref, y_ref, z_ref, 'ko-', 'LineWidth', 2);  
plot3(x_m{1}, y_m{1}, z_m{1}, 'bo-', 'LineWidth', 2); 
plot3(x_m{2}, y_m{2}, z_m{2}, 'ro-', 'LineWidth', 2); 
plot3(x_m{3}, y_m{3}, z_m{3}, 'go-', 'LineWidth', 2); 
% Start point
plot3(x_ref(1), y_ref(1), z_ref(1), 'ko', 'MarkerSize', 10, ...
        'MarkerFaceColor', 'y');
hold off;
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
grid on;
view(3);  
rotate3d on;  
axis equal;
legend('TCP-reference position', 'TCP-position - CTI: ti1 s', ...
      'TCP-position - CTI: ti2 s','TCP-position - CTI: ti3 s','start point','FontSize', 20);
title(sprintf('TCP-ED-Scorbot position - PTPD: %.2f mm', step*10),'FontSize', 20,'FontWeight', 'bold');

%% TCP-Error graphics
figure;

% CTI: 1
subplot(3,2,1);
plot(time{1},(tcp_ed{1})*1000,'b','LineWidth', 2);
xlabel('time [s]');
ylabel('Error [mm]');
xlim([0 time{1}(end)]);
set(gca, 'FontSize', 14);
grid on;
grid minor        
ax = gca;
ax.XTick = 0:20:time{1}(end);  
ax.YTick = 0:10:30;
ax.GridColor = [0.5 0.5 0.5];
ax.MinorGridColor = [0.3 0.3 0.3];
ax.GridAlpha = 1;        
ax.MinorGridAlpha = 1;
ax.GridLineWidth = 1.0;
ax.MinorGridLineWidth = 0.5;
lgd1 = legend(sprintf('RMSE: %.2f mm', tcp_rmse{1}*1000), 'FontSize', 16);
lgd1.Location = "south";
lgd1.Orientation = "horizontal";
title(sprintf('TCP-Error - CTI: %.3f s', ti(1)), 'FontSize', 15);

% CTI: 2
subplot(3,2,3);
plot(time{2},(tcp_ed{2})*1000,'b','LineWidth', 2);
xlabel('time [s]');
ylabel('Error [mm]');
xlim([0 time{2}(end)])
set(gca, 'FontSize', 14);
grid on;
grid minor        
ax = gca;
ax.XTick = 0:10:time{2}(end);  
ax.YTick = 0:10:40;
ax.GridColor = [0.5 0.5 0.5];
ax.MinorGridColor = [0.3 0.3 0.3];
ax.GridAlpha = 1;        
ax.MinorGridAlpha = 1;
ax.GridLineWidth = 1.0;
ax.MinorGridLineWidth = 0.5;
lgd2 = legend(sprintf('RMSE: %.2f mm  ', tcp_rmse{2}*1000), 'FontSize', 16);
lgd2.Location = "south";
lgd2.Orientation = "horizontal";
title(sprintf('TCP-Error - CTI: %.3f s', ti(2)), 'FontSize', 15);

% CTI: 3
subplot(3,2,5);
plot(time{3},(tcp_ed{3})*1000,'b','LineWidth', 2);
xlabel('time [s]');
ylabel('Error [mm]');
xlim([0 time{3}(end)])
set(gca, 'FontSize', 14);
grid on;
grid minor        
ax = gca;
ax.XTick = 0:5:time{3}(end);  
ax.YTick = 0:10:50;
ax.GridColor = [0.5 0.5 0.5];
ax.MinorGridColor = [0.3 0.3 0.3];
ax.GridAlpha = 1;        
ax.MinorGridAlpha = 1;
ax.GridLineWidth = 1.0;
ax.MinorGridLineWidth = 0.5;
lgd3 = legend(sprintf('RMSE: %.2f mm', tcp_rmse{3}*1000), 'FontSize', 16);
lgd3.Location = "south";
lgd3.Orientation = "horizontal";
title(sprintf('TCP-Error - CTI: %.3f s', ti(3)), 'FontSize', 15);

%% Joints-Error graphics
% CTI: 1
subplot(3,2,2);
plot(time{1},rad2deg(joints_abs_err{1}(:,1)),'b','LineWidth', 2);
hold on;
plot(time{1},rad2deg(joints_abs_err{1}(:,2)),'r','LineWidth', 2);
plot(time{1},rad2deg(joints_abs_err{1}(:,3)),'m','LineWidth', 2);
plot(time{1},rad2deg(joints_abs_err{1}(:,4)),'g','LineWidth', 2);
hold off;
xlabel('time [s]');
ylabel('Joints error [Degrees]');
xlim([0 time{1}(end)])
set(gca, 'FontSize', 14);
grid on;
grid minor        
ax = gca;
ax.XTick = 0:20:time{1}(end);  
ax.YTick = 0:1:5;
ax.GridColor = [0.5 0.5 0.5];
ax.MinorGridColor = [0.3 0.3 0.3];
ax.GridAlpha = 1;        
ax.MinorGridAlpha = 1;
ax.GridLineWidth = 1.0;
ax.MinorGridLineWidth = 0.5;
labels = "J" + (1:nJoints) + ": " + ...
         round(rad2deg(joints_rmse{1}(1,1:nJoints)),3) + "°";
legend(labels, 'FontSize', 15);
title(sprintf('Error per joint - CTI: %.3f s', ti(1)), 'FontSize', 15);

% CTI: 2
subplot(3,2,4);
plot(time{2},rad2deg(joints_abs_err{2}(:,1)),'b','LineWidth', 2);
hold on;
plot(time{2},rad2deg(joints_abs_err{2}(:,2)),'r','LineWidth', 2);
plot(time{2},rad2deg(joints_abs_err{2}(:,3)),'m','LineWidth', 2);
plot(time{2},rad2deg(joints_abs_err{2}(:,4)),'g','LineWidth', 2);
hold off;
xlabel('time [s]');
ylabel('Joints error [Degrees]');
xlim([0 time{2}(end)])
set(gca, 'FontSize', 14);
grid on;
grid minor        
ax = gca;
ax.XTick = 0:10:time{2}(end);  
ax.YTick = 0:1:5;
ax.GridColor = [0.5 0.5 0.5];
ax.MinorGridColor = [0.3 0.3 0.3];
ax.GridAlpha = 1;        
ax.MinorGridAlpha = 1;
ax.GridLineWidth = 1.0;
ax.MinorGridLineWidth = 0.5;
labels = "J" + (1:nJoints) + ": " + ...
         round(rad2deg(joints_rmse{2}(1,1:nJoints)),3) + "°";
legend(labels, 'FontSize', 15);
title(sprintf('Error per joint - CTI: %.3f s', ti(2)), 'FontSize', 15);

% CTI: 3
subplot(3,2,6);
plot(time{3},rad2deg(joints_abs_err{3}(:,1)),'b','LineWidth', 2);
hold on;
plot(time{3},rad2deg(joints_abs_err{3}(:,2)),'r','LineWidth', 2);
plot(time{3},rad2deg(joints_abs_err{3}(:,3)),'m','LineWidth', 2);
plot(time{3},rad2deg(joints_abs_err{3}(:,4)),'g','LineWidth', 2);
hold off;
xlabel('time [s]');
ylabel('Joints error [Degrees]');
xlim([0 time{3}(end)])
set(gca, 'FontSize', 14);
grid on;
grid minor        
ax = gca;
ax.XTick = 0:5:time{3}(end);  
ax.YTick = 0:1:6;
ax.GridColor = [0.5 0.5 0.5];
ax.MinorGridColor = [0.3 0.3 0.3];
ax.GridAlpha = 1;        
ax.MinorGridAlpha = 1;
ax.GridLineWidth = 1.0;
ax.MinorGridLineWidth = 0.5;
labels = "J" + (1:nJoints) + ": " + ...
         round(rad2deg(joints_rmse{3}(1,1:nJoints)),3) + "°";
legend(labels, 'FontSize', 15);
title(sprintf('Error per joint - CTI: %.3f s', ti(3)), 'FontSize', 15);

sgtitle(sprintf(['TCP-error and joint error for a %s-type trajectory with ' ...
    'step of %.2fmm between points'], traj_name, step*10), 'FontSize', 20, ...
   'FontWeight', 'bold');



