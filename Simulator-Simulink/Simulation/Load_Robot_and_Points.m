%% LOAD ROBOT
EDScorbot = importrobot('EDScorbot_Arm_2.slx');

%% SQUARE POINTS
% This is the set of points of a square path
sqr = [0.472 0.35 0.25 0.25 0.25 0.4 0.4 0.25; 
    0.033 0.25 0.25 0.4 0.4 0.4 0.25 0.25; 
    0.6585 0.35 0.3 0.3 0.3 0.3 0.3 0.3];

%% LEMNISCATE POINTS
a = 0.2;          
n = 100;
t = linspace(0, 10, n);

% Lemniscate equations
y_lemn = 0.033 + (a * cos(t)) ./ (1 + sin(t).^2); 
x_lemn = 0.05 + (a * sin(t) .* cos(t)) ./ (1 + sin(t).^2);
z = 0.35 * ones(size(t));

% Centring points of the lemniscate
P_inicio = [0.4, 0.033];  
P_final = [0.4, 0.033];   

center = (P_inicio + P_final) / 2;
dist = norm(P_final - P_inicio);

x = x_lemn + center(1);
y = y_lemn + center(2);

xyz_points = [x', y', z']';
time_lemniscate = t;

% Points of the trajectory from the rest position to the starting 
% point of the lemniscate.
lemniscate = [0.45 0.45 0.45; 
    0.2660 0.2660 0.2660; 
    0.35 0.35 0.35];

% This is the set of points of a Lemniscate path
lemniscate = [lemniscate, xyz_points];

% Time matrix expasion
matrix_time_1 = [0.01 0.02 0.03];
time_lemniscate = [time_lemniscate, zeros(1, 3)];
time_lemniscate(:, 5:end) = time_lemniscate(:, 2:end-3);  
time_lemniscate(:, 2:4) = matrix_time_1;

