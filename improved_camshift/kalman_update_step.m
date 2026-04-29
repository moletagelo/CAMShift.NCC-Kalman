function [updatedState, updatedCovariance] = kalman_update_step(state, covariance, observation, params)
% 执行卡尔曼滤波更新步骤。

if nargin < 3 || isempty(observation)
    updatedState = state;
    updatedCovariance = covariance;
    return;
end

observationMatrix = double(params.observationMatrix);
measurementNoise = double(params.measurementNoise);
observation = double(observation(:));

innovation = observation - observationMatrix * double(state);
innovationCovariance = observationMatrix * double(covariance) * observationMatrix' + measurementNoise;
kalmanGain = double(covariance) * observationMatrix' / innovationCovariance;

updatedState = double(state) + kalmanGain * innovation;
identityMatrix = eye(size(covariance));
updatedCovariance = (identityMatrix - kalmanGain * observationMatrix) * double(covariance);
updatedCovariance = (updatedCovariance + updatedCovariance') / 2;
end
