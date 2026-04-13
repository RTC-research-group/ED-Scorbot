function angle = dsr2deg(joint, ref)
    % Convert digital spike reference to angle in degrees
    % joint: joint number (1-4)
    % angle: angle in degrees
    % Returns the corresponding reference

    switch joint
        case 1
            f_inv = @(x) x / 3.050640635;
        case 2
            f_inv = @(x) x / 9.532888465;
        case 3
            f_inv = @(x) x / 3.220611916;
        case 4
            f_inv = @(x) x / 17.66784452;
        otherwise
            error('Invalid joint number. Must be between 1 and 4');
    end

    angle = f_inv(ref);
end
