function bbox = mask_to_bbox(motionMask, minArea)
% 从二值运动掩膜中提取主前景区域边界框。
% 输入:
%   motionMask - 二值前景掩膜
%   minArea    - 最小区域面积阈值
% 输出:
%   bbox       - 边界框 [x, y, w, h]，无目标时为 [0, 0, 0, 0]

if nargin < 2 || isempty(minArea)
    minArea = 1;
end

motionMask = logical(motionMask);
regionStats = regionprops(motionMask, 'Area', 'BoundingBox');

if isempty(regionStats)
    bbox = zeros(1, 4);
    return;
end

areas = [regionStats.Area];
[bestArea, bestIndex] = max(areas);
if bestArea < minArea
    bbox = zeros(1, 4);
    return;
end

bbox = regionStats(bestIndex).BoundingBox;
end
