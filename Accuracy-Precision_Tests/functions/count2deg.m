function angle = count2deg(joint, count)
    % This function converts counters to angles in degrees.
    % joint: joint number (1 to 4)
    % count: counter value or vector
    % angle: result in degrees
    switch joint
        case 1
            angle = ((1 / 125.5) * (32768 - count));
        case 2
            angle = ((1 / 131) * (32768 - count));
        case 3
            angle = ((1 / 132.5) * (32768 - count));
        case 4
            angle = (0.012391573729863692 * (32768 - count));
        otherwise
            error('Invalid joint number. Must be between 1 and 4');
    end
end
