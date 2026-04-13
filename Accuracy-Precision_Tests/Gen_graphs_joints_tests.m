clear
clc

%{
 "This script is used to generate joint motion graphs based on individual 
  tests for each joint, using different Command Time Interval (CTI) and 
  steps settings. 
  The joint positions were obtained from the counter values, which were 
  subsequently converted into angles.
  *** If you wish to test different ranges of motion, we recommend creating 
  a new script of this type."  
%} 

%% Settings
joint_id = 1;
init_val = 0;
limit_val = 40;        % Change to -40 if it is joint 2
nReps = 4;             % Number of repetitions
time_interval = 0.500; % CTI

% Steps:
step1 = 1;  % 1°
step2 = 2;  % 2°
step3 = 5;  % 5°
step4 = 8;  % 8°
step5 = 10; % 10°

init_index = 1; 
ext_range = 5;

if limit_val >= 0
    sign = 1; % positive
elseif limit_val <= 0
    sign = -1; % negative
else
    disp(['Value = ', num2str(0)])
end
%% Add folder path
addpath("functions");

%% Load data
folder = fullfile('utils','accuracy_and_precision_test_data', ...
                  sprintf('joint_%d', joint_id));

steps = [step1, step2, step3, step4, step5];
n = numel(steps);

cmd_joints  = cell(1, n);
real_joints = cell(1, n);

for k = 1:n
    filename_SR = sprintf('SR_%d-%d-%d_%d_%.3f_%d.csv', ...
        init_val, limit_val, init_val, steps(k), time_interval, nReps);

    filename_COUNT = sprintf('COUNT_%d-%d-%d_%d_%.3f_%d.csv', ...
        init_val, limit_val, init_val, steps(k), time_interval, nReps);

    dir_SR    = fullfile(folder, filename_SR);
    dir_COUNT = fullfile(folder, filename_COUNT);

    cmd_joints{k}  = readtable(dir_SR);
    real_joints{k} = readtable(dir_COUNT);
end

%% =========================== Real Joints ============================= %
%% STEP: 1
% References
q_ref1 = ([init_val:step1*sign:limit_val limit_val-step1*sign:-step1*sign:init_val]);
time1 = 0:time_interval:length(q_ref1)*time_interval-time_interval;

% Extract data 
counts1 = real_joints{1}{init_index:end, joint_id};
ts_r1   = real_joints{1}{init_index:end, 7};

% Process time data
ts_r1_1 = ts_r1(1:length(q_ref1), 1);
ts_r1_2 = ts_r1(length(ts_r1_1):length(ts_r1_1)*2-1, 1);
ts_r1_3 = ts_r1(length(ts_r1_1)*2-1:length(ts_r1_1)*3-2, 1);
ts_r1_4 = ts_r1(length(ts_r1_1)*3-2:end, 1);
t1_1 = ts_r1_1;
t1_2 = ts_r1_2 - ts_r1_1(end);
t1_3 = ts_r1_3 - ts_r1_2(end);
t1_4 = ts_r1_4 - ts_r1_3(end);

% Convert from counters to angles (in degrees)
q_r1_1 = count2deg(joint_id,counts1(1:length(q_ref1), 1));   
q_r1_2 = count2deg(joint_id,counts1(length(q_r1_1):(length(q_r1_1))*2-1, 1));   
q_r1_3 = count2deg(joint_id,counts1(length(q_r1_1)*2-1:(length(q_r1_1)*3-2), 1));   
q_r1_4 = count2deg(joint_id,counts1(length(q_r1_1)*3-2:end, 1));   

%Error
rmse1_1 = sqrt(mean((q_ref1 - q_r1_1').^2));
rmse1_2 = sqrt(mean((q_ref1 - q_r1_2').^2));
rmse1_3 = sqrt(mean((q_ref1 - q_r1_3').^2));
rmse1_4 = sqrt(mean((q_ref1 - q_r1_4').^2));

% Mean error
rmse1 = (rmse1_1 + rmse1_2 + rmse1_3 + rmse1_4)/nReps;

%% STEP: 2
% References
q_ref2 = ([init_val:step2*sign:limit_val limit_val-step2*sign:-step2*sign:init_val]);
time2 = 0:time_interval:length(q_ref2)*time_interval-time_interval;

% Extract data 
counts2 = real_joints{2}{init_index:end, joint_id:4};
ts_r2   = real_joints{2}{init_index:end, 7};

% Process data
ts_r2_1 = ts_r2(1:length(q_ref2), 1);
ts_r2_2 = ts_r2(length(ts_r2_1):length(ts_r2_1)*2-1, 1);
ts_r2_3 = ts_r2(length(ts_r2_1)*2-1:length(ts_r2_1)*3-2, 1);
ts_r2_4 = ts_r2(length(ts_r2_1)*3-2:end, 1);
t2_1 = ts_r2_1;
t2_2 = ts_r2_2 - ts_r2_1(end);
t2_3 = ts_r2_3 - ts_r2_2(end);
t2_4 = ts_r2_4 - ts_r2_3(end);

% Convert from counters to angles (in degrees)
q_r2_1 = count2deg(joint_id,counts2(1:length(q_ref2), 1));   
q_r2_2 = count2deg(joint_id,counts2(length(q_r2_1):(length(q_r2_1))*2-1, 1));   
q_r2_3 = count2deg(joint_id,counts2(length(q_r2_1)*2-1:(length(q_r2_1)*3-2), 1));   
q_r2_4 = count2deg(joint_id,counts2(length(q_r2_1)*3-2:end, 1));   

%Error
rmse2_1 = sqrt(mean((q_ref2 - q_r2_1').^2));
rmse2_2 = sqrt(mean((q_ref2 - q_r2_2').^2));
rmse2_3 = sqrt(mean((q_ref2 - q_r2_3').^2));
rmse2_4 = sqrt(mean((q_ref2 - q_r2_4').^2));

% Mean error
rmse2 = (rmse2_1 + rmse2_2 + rmse2_3 + rmse2_4)/nReps;

%% STEP: 3
% References
q_ref3 = ([init_val:step3*sign:limit_val limit_val-step3*sign:-step3*sign:init_val]);
time3 = 0:time_interval:length(q_ref3)*time_interval-time_interval;

% Extract data 
counts3 = real_joints{3}{init_index:end, joint_id};
ts_r3   = real_joints{3}{init_index:end, 7};

% Process data
ts_r3_1 = ts_r3(1:length(q_ref3), 1);
ts_r3_2 = ts_r3(length(ts_r3_1):length(ts_r3_1)*2-1, 1);
ts_r3_3 = ts_r3(length(ts_r3_1)*2-1:length(ts_r3_1)*3-2, 1);
ts_r3_4 = ts_r3(length(ts_r3_1)*3-2:end, 1);
t3_1 = ts_r3_1;
t3_2 = ts_r3_2 - ts_r3_1(end);
t3_3 = ts_r3_3 - ts_r3_2(end);
t3_4 = ts_r3_4 - ts_r3_3(end);

% Convert from counters to angles (in degrees)
q_r3_1 = count2deg(joint_id,counts3(1:length(q_ref3), 1));   
q_r3_2 = count2deg(joint_id,counts3(length(q_r3_1):(length(q_r3_1))*2-1, 1));   
q_r3_3 = count2deg(joint_id,counts3(length(q_r3_1)*2-1:(length(q_r3_1)*3-2), 1));   
q_r3_4 = count2deg(joint_id,counts3(length(q_r3_1)*3-2:end, 1));   

% Error
rmse3_1 = sqrt(mean((q_ref3 - q_r3_1').^2));
rmse3_2 = sqrt(mean((q_ref3 - q_r3_2').^2));
rmse3_3 = sqrt(mean((q_ref3 - q_r3_3').^2));
rmse3_4 = sqrt(mean((q_ref3 - q_r3_4').^2));

% Mean error
rmse3 = (rmse3_1 + rmse3_2 + rmse3_3 + rmse3_4)/nReps;

%% STEP: 4
% References
q_ref4 = ([init_val:step4*sign:limit_val limit_val-step4*sign:-step4*sign:init_val]);
time4 = 0:time_interval:length(q_ref4)*time_interval-time_interval;

% Extract data 
counts4 = real_joints{4}{init_index:end, joint_id};
ts_r4   = real_joints{4}{init_index:end, 7};

% Process data
ts_r4_1 = ts_r4(1:length(q_ref4), 1);
ts_r4_2 = ts_r4(length(ts_r4_1):length(ts_r4_1)*2-1, 1);
ts_r4_3 = ts_r4(length(ts_r4_1)*2-1:length(ts_r4_1)*3-2, 1);
ts_r4_4 = ts_r4(length(ts_r4_1)*3-2:end, 1);
t4_1 = ts_r4_1;
t4_2 = ts_r4_2 - ts_r4_1(end);
t4_3 = ts_r4_3 - ts_r4_2(end);
t4_4 = ts_r4_4 - ts_r4_3(end);

% Convert from counters to angles (in degrees)
q_r4_1 = count2deg(joint_id,counts4(1:length(q_ref4), 1));   
q_r4_2 = count2deg(joint_id,counts4(length(q_r4_1):(length(q_r4_1))*2-1, 1));   
q_r4_3 = count2deg(joint_id,counts4(length(q_r4_1)*2-1:(length(q_r4_1)*3-2), 1));   
q_r4_4 = count2deg(joint_id,counts4(length(q_r4_1)*3-2:end, 1));   

%Error
rmse4_1 = sqrt(mean((q_ref4 - q_r4_1').^2));
rmse4_2 = sqrt(mean((q_ref4 - q_r4_2').^2));
rmse4_3 = sqrt(mean((q_ref4 - q_r4_3').^2));
rmse4_4 = sqrt(mean((q_ref4 - q_r4_4').^2));

% Mean error
rmse4 = (rmse4_1 + rmse4_2 + rmse4_3 + rmse4_4)/nReps;

%% STEP: 5
% References
q_ref5 = ([init_val:step5*sign:limit_val limit_val-step5*sign:-step5*sign:init_val]);
time5 = 0:time_interval:length(q_ref5)*time_interval-time_interval;

% Extract data 
counts5 = real_joints{5}{init_index:end, joint_id};
ts_r5   = real_joints{5}{init_index:end, 7};

% Process data
ts_r5_1 = ts_r5(1:length(q_ref5), 1);
ts_r5_2 = ts_r5(length(ts_r5_1):length(ts_r5_1)*2-1, 1);
ts_r5_3 = ts_r5(length(ts_r5_1)*2-1:length(ts_r5_1)*3-2, 1);
ts_r5_4 = ts_r5(length(ts_r5_1)*3-2:end, 1);
t5_1 = ts_r5_1;
t5_2 = ts_r5_2 - ts_r5_1(end);
t5_3 = ts_r5_3 - ts_r5_2(end);
t5_4 = ts_r5_4 - ts_r5_3(end);

% Convert from counters to angles (in degrees)
q_r5_1 = count2deg(joint_id,counts5(1:length(q_ref5), 1));   
q_r5_2 = count2deg(joint_id,counts5(length(q_r5_1):(length(q_r5_1))*2-1, 1));   
q_r5_3 = count2deg(joint_id,counts5(length(q_r5_1)*2-1:(length(q_r5_1)*3-2), 1));   
q_r5_4 = count2deg(joint_id,counts5(length(q_r5_1)*3-2:end, 1));   

%Error
rmse5_1 = sqrt(mean((q_ref5 - q_r5_1').^2));
rmse5_2 = sqrt(mean((q_ref5 - q_r5_2').^2));
rmse5_3 = sqrt(mean((q_ref5 - q_r5_3').^2));
rmse5_4 = sqrt(mean((q_ref5 - q_r5_4').^2));

% Mean error
rmse5 = (rmse5_1 + rmse5_2 + rmse5_3 + rmse5_4)/nReps;

%% Graphics
figure;

% STEP 1
subplot(3,2,1);
hold on;
plot(time1,q_ref1,'k','LineWidth',1.5);
plot(t1_1,q_r1_1,'b-','LineWidth',1.5);
plot(t1_2,q_r1_2,'r-','LineWidth',1.5);
plot(t1_3,q_r1_3,'m-','LineWidth',1.5);
plot(t1_4,q_r1_4,'g-','LineWidth',1.5);
%pbaspect([0.7 0.2 1])
hold off;
xlabel('time [s]', 'FontSize', 16);
ylabel('Angles [Degrees]', 'FontSize', 16);
xlim([0 time1(end)])
if limit_val >= 0
    ylim([0 limit_val + ext_range]);
else
    ylim([limit_val - ext_range 0]);  
end
set(gca, 'FontSize', 12);
grid on;
grid minor        
ax = gca;
ax.XTick = 0:2.5:time1(end);  
ax.YTick = floor(ax.YLim(1)):5:ceil(ax.YLim(2));
ax.GridColor = [0.8 0.8 0.8];
ax.MinorGridColor = [0.9 0.9 0.9];
ax.GridAlpha = 1;        
ax.MinorGridAlpha = 1;
ax.GridLineWidth = 1.0;
ax.MinorGridLineWidth = 0.5;
legend('q reference', 'q round 1', 'q round 2', 'q round 3', 'q round 4', 'FontSize', 8);
title(sprintf('Joint: %.f | Range: 0°- %.f°- 0° | %.f - degree step | RMSE: = %.3f°' ...
        , joint_id, limit_val, step1, rmse1));

% STEP 2
subplot(3,2,2);
hold on;
plot(time2,q_ref2,'k','LineWidth',1.5);
plot(t2_1,q_r2_1,'b-','LineWidth',1.5);
plot(t2_2,q_r2_2,'r-','LineWidth',1.5);
plot(t2_3,q_r2_3,'m-','LineWidth',1.5);
plot(t2_4,q_r2_4,'g-','LineWidth',1.5);
%pbaspect([1 0.2 1]);
hold off;
xlabel('time [s]', 'FontSize', 16);
ylabel('Angles [Degrees]', 'FontSize', 16);
xlim([0 time2(end)])
if limit_val >= 0
    ylim([0 limit_val + ext_range]);
else
    ylim([limit_val - ext_range 0]); 
end
set(gca, 'FontSize', 12);
grid on;
grid minor        
ax = gca;
ax.XTick = 0:1:time2(end);  
ax.YTick = floor(ax.YLim(1)):5:ceil(ax.YLim(2));
ax.GridColor = [0.8 0.8 0.8];
ax.MinorGridColor = [0.9 0.9 0.9];
ax.GridAlpha = 1;        
ax.MinorGridAlpha = 1;
ax.GridLineWidth = 1.0;
ax.MinorGridLineWidth = 0.5;
legend('q reference', 'q round 1', 'q round 2', 'q round 3', 'q round 4', 'FontSize', 6);
title(sprintf('Joint: %.f | Range: 0°- %.f°- 0° | %.f - degree step | RMSE: = %.3f°' ...
        , joint_id, limit_val, step2, rmse2));

% STEP 3
subplot(3,2,3);
hold on;
plot(time3,q_ref3,'k','LineWidth',1.5);
plot(t3_1,q_r3_1,'b-','LineWidth',1.5);
plot(t3_2,q_r3_2,'r-','LineWidth',1.5);
plot(t3_3,q_r3_3,'m-','LineWidth',1.5);
plot(t3_4,q_r3_4,'g-','LineWidth',1.5);
%pbaspect([1 0.2 1]);
hold off;
xlabel('time [s]', 'FontSize', 16);
ylabel('Angles [Degrees]', 'FontSize', 16);
xlim([0 time3(end)])
if limit_val >= 0
    ylim([0 limit_val + ext_range]);
else
    ylim([limit_val - ext_range 0]);
end
set(gca, 'FontSize', 12);
grid on;
grid minor        
ax = gca;
ax.XTick = 0:0.5:time3(end);  
ax.YTick = floor(ax.YLim(1)):5:ceil(ax.YLim(2));
ax.GridColor = [0.8 0.8 0.8];
ax.MinorGridColor = [0.9 0.9 0.9];
ax.GridAlpha = 1;        
ax.MinorGridAlpha = 1;
ax.GridLineWidth = 1.0;
ax.MinorGridLineWidth = 0.5;
legend('q reference', 'q round 1', 'q round 2', 'q round 3', 'q round 4', 'FontSize', 6);
title(sprintf('Joint: %.f | Range: 0°- %.f°- 0° | %.f - degree step | RMSE: = %.3f°' ...
        , joint_id, limit_val, step3, rmse3));

% STEP 4
subplot(3,2,4);
hold on;
plot(time4,q_ref4,'k','LineWidth',1.5);
plot(t4_1,q_r4_1,'b-','LineWidth',1.5);
plot(t4_2,q_r4_2,'r-','LineWidth',1.5);
plot(t4_3,q_r4_3,'m-','LineWidth',1.5);
plot(t4_4,q_r4_4,'g-','LineWidth',1.5);
%pbaspect([1 0.2 1]);
hold off;
xlabel('time [s]', 'FontSize', 16);
ylabel('Angles [Degrees]', 'FontSize', 16);
xlim([0 time4(end)])
if limit_val >= 0
    ylim([0 limit_val + ext_range]);
else
    ylim([limit_val - ext_range 0]); 
end
set(gca, 'FontSize', 12);
grid on;
grid minor        
ax = gca;
ax.XTick = 0:0.25:time4(end);  
ax.YTick = floor(ax.YLim(1)):5:ceil(ax.YLim(2));
ax.GridColor = [0.8 0.8 0.8];
ax.MinorGridColor = [0.9 0.9 0.9];
ax.GridAlpha = 1;        
ax.MinorGridAlpha = 1;
ax.GridLineWidth = 1.0;
ax.MinorGridLineWidth = 0.5;
legend('q reference', 'q round 1', 'q round 2', 'q round 3', 'q round 4', 'FontSize', 6);
title(sprintf('Joint: %.f | Range: 0°- %.f°- 0° | %.f - degree step | RMSE: = %.3f°' ...
        , joint_id, limit_val, step4, rmse4));

% STEP 5
subplot(3,2,5);
hold on;
plot(time5,q_ref5,'k','LineWidth',1.5);
plot(t5_1,q_r5_1,'b-','LineWidth',1.5);
plot(t5_2,q_r5_2,'r-','LineWidth',1.5);
plot(t5_3,q_r5_3,'m-','LineWidth',1.5);
plot(t5_4,q_r5_4,'g-','LineWidth',1.5);
%pbaspect([1 0.2 1]);
hold off;
xlabel('time [s]', 'FontSize', 16);
ylabel('Angles [Degrees]', 'FontSize', 16);
xlim([0 time5(end)])
if limit_val >= 0
    ylim([0 limit_val + ext_range]);
else
    ylim([limit_val - ext_range 0]); 
end
set(gca, 'FontSize', 12);
grid on;
grid minor        
ax = gca;
ax.XTick = 0:0.15:time5(end);  
ax.YTick = floor(ax.YLim(1)):5:ceil(ax.YLim(2));
ax.GridColor = [0.8 0.8 0.8];
ax.MinorGridColor = [0.9 0.9 0.9];
ax.GridAlpha = 1;        
ax.MinorGridAlpha = 1;
ax.GridLineWidth = 1.0;
ax.MinorGridLineWidth = 0.5;
legend('q reference', 'q round 1', 'q round 2', 'q round 3', 'q round 4', 'FontSize', 6);
title(sprintf('Joint: %.f | Range: 0°- %.f°- 0° | %.f - degree step | RMSE: = %.3f°' ...
        , joint_id, limit_val, step5, rmse5));

% General legend and title
lgd = legend('q reference', 'q round 1', 'q round 2', 'q round 3', 'q round 4');


