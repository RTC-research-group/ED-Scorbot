%% Load Data
% Measured trajectory
x_m = out.m_2DOF.Data(:, 1);
y_m = out.m_2DOF.Data(:, 2);    
z_m = out.m_2DOF.Data(:, 3); 

% Reference Trayectory
x_ref = reshape(out.ref_2DOF.Data(1,:), [], 1);
y_ref = reshape(out.ref_2DOF.Data(2,:), [], 1);
z_ref = reshape(out.ref_2DOF.Data(3,:), [], 1);

% Time
time = out.tout;
%% Display only the points of the trajectory from time 2 seconds onwards
% X Graphics
t1 = 2;
init_index = find(time >= t1, 1);  
time_2s = time(init_index:end);
n1_2DOF = length(time_2s) - 1;
% Ref points
x_ref_2s = x_ref(end-n1_2DOF:end);
y_ref_2s = y_ref(end-n1_2DOF:end);
z_ref_2s = z_ref(end-n1_2DOF:end);
% Mesure points
x_m_2s = x_m(end-n1_2DOF:end);
y_m_2s = y_m(end-n1_2DOF:end);
z_m_2s = z_m(end-n1_2DOF:end);

%% Trajectory graph 
figure;
hold on; 
plot3(x_ref_2s, y_ref_2s, z_ref_2s, 'k', 'LineWidth', 1.5);  
plot3(x_m_2s, y_m_2s, z_m_2s, 'b', 'LineWidth', 1.5);  
hold off;
xlabel('x (m)');
ylabel('Y (m)');
zlabel('Z (m)');
grid on;
axis equal; 
legend('Reference trajectory', 'IJC-2DOF PID');
view(3); 
rotate3d on;  
%% x, y, z graphs starting from 2 seconds
% depending on the trajectory you can change the "xlim" to see all 
% generated points. For square trajectory use a maximum "xlim" of 7.5. 
% For lemniscate trajectory use a maximum "xlim" of 10.
% X Graphics
figure;
subplot(3,1,1);
plot(time_2s, x_ref_2s, 'k', 'LineWidth', 2);    
hold on;
plot(time_2s, x_m_2s, 'b','LineWidth', 2);   
hold off;
xlim([2 7.5]);
ylabel('x (m)');
grid on;
legend('reference', 'IJC-2DOF PID');
% Y Graphics
subplot(3,1,2);
plot(time_2s, y_ref_2s, 'k', 'LineWidth', 2);    
hold on;
plot(time_2s, y_m_2s, 'b','LineWidth', 2);   
hold off;
xlim([2 7.5]); 
ylabel('y (m)');
grid on;
legend('reference', 'IJC-2DOF PID');
% Z Graphics
subplot(3,1,3);
plot(time_2s, z_ref_2s, 'k', 'LineWidth', 2);   
hold on;
plot(time_2s, z_m_2s, 'b','LineWidth', 2);    
hold off;
xlim([2 7.5]);
ylabel('z (m)');
grid on;
legend('reference', 'IJC-2DOF PID');

%% Eucledian distance
eucledian_distance = sqrt((x_ref_2s - x_m_2s).^2 + (y_ref_2s - y_m_2s).^2 + (z_ref_2s - z_m_2s).^2);
figure;
semilogy(time_2s, eucledian_distance, 'b', 'LineWidth', 2);
hold on;
%hold off;
xlim([2 7.5]);
xlabel('Time (s)');
ylabel('Error (m)');
grid on;
legend('Error');
%% RMSE
rmse = sqrt(mean(eucledian_distance.^2));
display(rmse);