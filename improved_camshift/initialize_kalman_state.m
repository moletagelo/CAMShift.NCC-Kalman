function kalmanState = initialize_kalman_state(initialCenter, params)
% 初始化匀速模型卡尔曼滤波器状态。

initialCenter = double(initialCenter(:));
if numel(initialCenter) ~= 2
    error('initialize_kalman_state:InvalidCenter', 'Initial center must contain [row, col].');
end

kalmanState = struct();
kalmanState.state = [initialCenter(1); initialCenter(2); 0; 0];
kalmanState.covariance = double(params.initialCovariance);
end
