function trackerState = initialize_point_tracker(referenceFrame, options)
% 初始化 Lucas-Kanade 稀疏点跟踪器状态。
% 输入:
%   referenceFrame - 参考灰度帧
%   options        - 光流参数结构体
% 输出:
%   trackerState   - 跟踪器状态结构体

cornerPoints = detectMinEigenFeatures(referenceFrame, ...
    'MinQuality', options.minQuality, ...
    'FilterSize', 5, ...
    'ROI', [1, 1, size(referenceFrame, 2), size(referenceFrame, 1)]);

selectedPoints = cornerPoints.Location;
if isempty(selectedPoints)
    selectedPoints = [size(referenceFrame, 2) / 2, size(referenceFrame, 1) / 2];
end

pointTracker = vision.PointTracker( ...
    'MaxBidirectionalError', options.maxBidirectionalError, ...
    'NumPyramidLevels', options.numPyramidLevels, ...
    'BlockSize', options.blockSize);

initialize(pointTracker, selectedPoints, referenceFrame);

trackerState = struct();
trackerState.pointTracker = pointTracker;
trackerState.points = selectedPoints;
end
