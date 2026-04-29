function [predictedState, predictedCovariance] = kalman_predict_step(state, covariance, params)
% 执行卡尔曼滤波预测步骤。

transitionMatrix = double(params.transitionMatrix);
processNoise = double(params.processNoise);

predictedState = transitionMatrix * double(state);
predictedCovariance = transitionMatrix * double(covariance) * transitionMatrix' + processNoise;
end
