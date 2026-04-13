function err = TCP_err_fcn(x_ref, y_ref, z_ref, x, y, z)
%ERROR_FCN Euclidean error and RMSE

% Column vectors
x_ref = x_ref(:); y_ref = y_ref(:); z_ref = z_ref(:);
x     = x(:);     y     = y(:);     z     = z(:);

% Euclidean distance
err.ed = sqrt((x_ref - x).^2 + ...
              (y_ref - y).^2 + ...
              (z_ref - z).^2);

% RMSE
err.rmse = sqrt(mean(err.ed.^2));

end