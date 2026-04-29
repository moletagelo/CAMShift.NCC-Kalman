function [motionMask, pointTracks, flowVectors, motionBbox, trackerState, stats] = lucas_kanade_motion_detection(previousFrame, currentFrame, trackerState, options)
% 使用稀疏 Lucas-Kanade 光流检测运动目标区域。
% 输入:
%   previousFrame - 前一帧图像
%   currentFrame  - 当前帧图像
%   trackerState  - 点跟踪器状态，可为空
%   options       - 参数结构体，支持 minQuality、maxBidirectionalError、minArea
% 输出:
%   motionMask    - 基于光流点聚合得到的二值掩膜
%   pointTracks   - 有效点轨迹 [xPrev, yPrev, xCurr, yCurr]
%   flowVectors   - 光流向量 [u, v]
%   motionBbox    - 运动区域边界框 [x, y, w, h]
%   trackerState  - 更新后的点跟踪器状态
%   stats         - 附加统计信息

if nargin < 4
    options = struct();
end

options = merge_detection_options(options, struct( ...
    'minQuality', 0.01, ...
    'maxBidirectionalError', 2.0, ...
    'blockSize', [15, 15], ...
    'numPyramidLevels', 3, ...
    'motionThreshold', 0.75, ...
    'minArea', 25));

previousGray = convert_to_grayscale(previousFrame);
currentGray = convert_to_grayscale(currentFrame);

if nargin < 3 || isempty(trackerState)
    trackerState = initialize_point_tracker(previousGray, options);
end

[currentPoints, pointValidity] = step(trackerState.pointTracker, currentGray);
previousPoints = trackerState.points(pointValidity, :);
currentPoints = currentPoints(pointValidity, :);

if isempty(currentPoints)
    release(trackerState.pointTracker);
    trackerState = initialize_point_tracker(currentGray, options);
    motionMask = false(size(currentGray));
    pointTracks = zeros(0, 4);
    flowVectors = zeros(0, 2);
    motionBbox = zeros(1, 4);
    stats = struct('numTrackedPoints', 0, 'meanMotionMagnitude', 0);
    return;
end

flowVectors = currentPoints - previousPoints;
motionMagnitude = hypot(flowVectors(:, 1), flowVectors(:, 2));
movingIndex = motionMagnitude >= options.motionThreshold;

pointTracks = [previousPoints(movingIndex, :), currentPoints(movingIndex, :)];
flowVectors = flowVectors(movingIndex, :);

motionMask = false(size(currentGray));
if ~isempty(pointTracks)
    motionMask = rasterize_motion_points(motionMask, pointTracks(:, 3:4));
    motionMask = imdilate(motionMask, strel('disk', 4, 0));
    motionMask = imfill(motionMask, 'holes');
end

motionBbox = mask_to_bbox(motionMask, options.minArea);

trackerState.points = currentPoints;
setPoints(trackerState.pointTracker, trackerState.points);

if size(trackerState.points, 1) < 10
    release(trackerState.pointTracker);
    trackerState = initialize_point_tracker(currentGray, options);
end

stats = struct();
stats.numTrackedPoints = size(pointTracks, 1);
stats.meanMotionMagnitude = mean_with_default(motionMagnitude(movingIndex), 0);
end
