function [motionMask, detectorState, motionBbox, stats] = background_subtraction_gmm(frame, detectorState, options)
% 使用 GMM 背景模型检测运动区域，优先调用 MATLAB 官方视觉工具。
% 输入:
%   frame         - 当前帧图像
%   detectorState - GMM 检测器状态，可为空
%   options       - 参数结构体，支持 numGaussians、trainingFrames、minArea
% 输出:
%   motionMask    - 二值前景掩膜
%   detectorState - 更新后的检测器状态
%   motionBbox    - 运动区域边界框 [x, y, w, h]
%   stats         - 附加统计信息

if nargin < 3
    options = struct();
end

options = merge_detection_options(options, struct( ...
    'numGaussians', 3, ...
    'trainingFrames', 30, ...
    'minimumBackgroundRatio', 0.7, ...
    'learningRate', 0.005, ...
    'threshold', 20, ...
    'minArea', 25, ...
    'useMorphology', true, ...
    'diskRadius', 2));

grayFrame = convert_to_grayscale(frame);

if nargin < 2 || isempty(detectorState)
    detectorState = create_gmm_detector_state(options);
end

if isstruct(detectorState) && isfield(detectorState, 'mode') && strcmp(detectorState.mode, 'fallback')
    [motionMask, detectorState.backgroundModel, motionBbox, meanStats] = ...
        background_subtraction_mean(grayFrame, detectorState.backgroundModel, options);
    detectorState.frameCount = detectorState.frameCount + 1;
    stats = meanStats;
    stats.mode = detectorState.mode;
    return;
end

motionMask = step(detectorState, grayFrame);
motionMask = postprocess_motion_mask(logical(motionMask), options);
motionBbox = mask_to_bbox(motionMask, options.minArea);

stats = struct();
stats.changedPixelCount = nnz(motionMask);
stats.mode = 'vision.ForegroundDetector';
end
