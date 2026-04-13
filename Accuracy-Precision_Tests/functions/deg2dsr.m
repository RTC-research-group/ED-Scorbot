function ref = deg2dsr(joint, angle)
    % Convert angle to digital spike reference
    % joint: joint number (1-4)
    % ref: reference value
    % Returns a corresponding digital spike value

    switch joint
        case 1
            f = @(x) 3.050640635 * x;

        case 2
            f = @(x) 9.532888465 * x;

        case 3
            f = @(x) 3.220611916 * x;

        case 4
            f = @(x) 17.66784452 * x;
            
        otherwise
            error('Invalid joint number. Must be between 1 and 4');
    end

    ref = f(angle);
end
