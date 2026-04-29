function [motionMask, motionBbox, stats] = frame_difference_detection(previousFrame, currentFrame, options)
% 使用帧间差分法检测运动前景区域。
% 输入:
%   previousFrame - 前一帧图像
%   currentFrame  - 当前帧图像
%   options       - 参数结构体，支持 threshold、minArea、useMorphology
% 输出:
%   motionMask - 二值前景掩膜
%   motionBbox - 运动区域边界框 [x, y, w, h]
%   stats      - 附加统计信息

if nargin < 3
    options = struct();
end

options = merge_detection_options(options, struct( ...
    'threshold', 25, ...
    'minArea', 25, ...
    'useMorphology', true, ...
    'diskRadius', 2));

previousGray = convert_to_grayscale(previousFrame);
currentGray = convert_to_grayscale(currentFrame);

differenceFrame = imabsdiff(currentGray, previousGray);
motionMask = differenceFrame >= options.threshold;
motionMask = postprocess_motion_mask(motionMask, options);
motionBbox = mask_to_bbox(motionMask, options.minArea);

stats = struct();
stats.changedPixelCount = nnz(motionMask);
stats.meanDifference = mean(double(differenceFrame(:)));
stats.threshold = options.threshold;
end
