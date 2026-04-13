function err = joint_err_fcn(joints_ref, joints_m)
%JOINT_ERROR_FCN  Instantaneous absolute error and RMSE per joint
%   joints_ref  : NxJ reference joint positions
%   joints_m : NxJ measured joint positions
%
%   err.abs   : NxJ absolute error (instantaneous)
%   err.rmse  : 1xJ RMSE per joint

% Check dimensions
if ~isequal(size(joints_ref), size(joints_m))
    error('q_ref and q_meas must have the same size');
end

% Instantaneous absolute error
err.abs = abs(joints_ref - joints_m);   % NxJ

% RMSE per joint
err.rmse = sqrt(mean((joints_ref - joints_m).^2, 1));

end
