function detectorState = create_gmm_detector_state(options)
% 创建 GMM 检测器状态，不可用时退回均值背景模型。
% 输入:
%   options       - GMM 参数结构体
% 输出:
%   detectorState - 视觉前景检测器或回退状态结构体

if exist('vision.ForegroundDetector', 'class') == 8
    detectorState = vision.ForegroundDetector( ...
        'NumGaussians', options.numGaussians, ...
        'NumTrainingFrames', options.trainingFrames, ...
        'MinimumBackgroundRatio', options.minimumBackgroundRatio, ...
        'LearningRate', options.learningRate);
else
    detectorState = struct();
    detectorState.mode = 'fallback';
    detectorState.backgroundModel = [];
    detectorState.frameCount = 0;
end
end
