%clc
%clear

%{
 “This script is used to obtain the forward kinematic equations 
  for the ED-Scorbot, with the objective of calculating the Cartesian 
  positions of the end-effector in the workspace.” 
%} 

addpath("functions");
syms q1 q2 q3 q4 alpha1 alpha2 alpha3 alpha4 d1 d2 d3 d4 a1 a2 a3 a4;

%% 1. Forward kinematics model
% Transformation matrix A01
A01=simplify(MDH(q1,d1,a1,alpha1));
%display(A01);

A12=simplify(MDH(q2,d2,a2,alpha2));
%display(A12);

A23=simplify(MDH(q3,d3,a3,alpha3));
%display(A23);

A34=simplify(MDH(q4,d4,a4,alpha4));
%display(A34);

%% Homogeneous Transformation Matrix
T = simplify(A01*A12*A23*A34);

%% Kinematic equations
Px = T(1,4);
Py = T(2,4);
Pz = T(3,4);
disp(Px);
disp(Py);
disp(Pz);

%% Denavit-Hartenberg (D-H) parameters
% ideal home position 
% q1= 0; q2=0; q3=0; q4=0;
% ED-Scorbot home position
q1= 0.411898; q2=-0.383972; q3=0.20944; q4=0;

alpha1=-pi/2;          alpha2=0;         alpha3=0;          alpha4=0;
d1=0.3585;             d2=-0.098;        d3=0.065;          d4=0;
a1=0.05;               a2=0.3;           a3=0.25;           a4=0.22;  

x = double(eval(T(1,4)));
y = double(eval(T(2,4)));
z = double(eval(T(3,4)));

%% View position of end effector at home
disp(['x position: ', num2str(x),' m']);
disp(['y position: ', num2str(y),' m']);
disp(['z position: ', num2str(z),' m']);

