function [motionMask, backgroundModel, motionBbox, stats] = background_subtraction_mean(frame, backgroundModel, options)
% 使用均值背景模型执行背景减除与在线更新。
% 输入:
%   frame           - 当前帧图像
%   backgroundModel - 背景模型，可为空
%   options         - 参数结构体，支持 threshold、learningRate、minArea
% 输出:
%   motionMask      - 二值前景掩膜
%   backgroundModel - 更新后的背景模型
%   motionBbox      - 运动区域边界框 [x, y, w, h]
%   stats           - 附加统计信息

if nargin < 3
    options = struct();
end

options = merge_detection_options(options, struct( ...
    'threshold', 20, ...
    'learningRate', 0.05, ...
    'minArea', 25, ...
    'useMorphology', true, ...
    'diskRadius', 2));

currentGray = double(convert_to_grayscale(frame));
if nargin < 2 || isempty(backgroundModel)
    backgroundModel = currentGray;
end

validateattributes(backgroundModel, {'numeric'}, {'size', size(currentGray)}, mfilename, 'backgroundModel', 2);

differenceFrame = abs(currentGray - backgroundModel);
motionMask = differenceFrame >= options.threshold;
motionMask = postprocess_motion_mask(motionMask, options);
motionBbox = mask_to_bbox(motionMask, options.minArea);

backgroundModel = (1 - options.learningRate) * backgroundModel + options.learningRate * currentGray;

stats = struct();
stats.changedPixelCount = nnz(motionMask);
stats.meanDifference = mean(differenceFrame(:));
stats.learningRate = options.learningRate;
end
