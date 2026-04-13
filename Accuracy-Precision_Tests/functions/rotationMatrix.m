function [R] = rotationMatrix(alpha,phi,theta)

%% Rotation matrixes
        %alpha = pi/3;  
        %phi = pi/6;
        %theta = -pi/3;
        %theta = pi/4; % 

        R_x = [1      0               0;
               0 cos(alpha) -sin(alpha);
               0 sin(alpha)  cos(alpha)];

        R_y = [cos(phi)  0 sin(phi);
                    0    1        0;
               -sin(phi) 0 cos(phi)];

        R_z = [cos(theta) -sin(theta) 0;
               sin(theta)  cos(theta) 0;
               0             0        1];

        R = R_z*R_y*R_x; 
end