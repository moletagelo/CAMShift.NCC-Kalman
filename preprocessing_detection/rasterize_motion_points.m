function motionMask = rasterize_motion_points(motionMask, pointLocations)
% 将运动点位置栅格化为二值掩膜。
% 输入:
%   motionMask     - 预分配二值掩膜
%   pointLocations - 点位置数组 [x, y]
% 输出:
%   motionMask     - 更新后的二值掩膜

for pointIndex = 1:size(pointLocations, 1)
    xCoord = max(1, min(size(motionMask, 2), round(pointLocations(pointIndex, 1))));
    yCoord = max(1, min(size(motionMask, 1), round(pointLocations(pointIndex, 2))));
    motionMask(yCoord, xCoord) = true;
end
end
