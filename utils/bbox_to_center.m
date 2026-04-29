function center = bbox_to_center(bbox)
%BBOX_TO_CENTER 将矩形框转换为中心点坐标。
% 输入：bbox，1×4 或 N×4 的 [x, y, width, height] 矩阵。
% 输出：center，1×2 或 N×2 的 [centerX, centerY] 矩阵。

    validateattributes(bbox, {'numeric'}, {'ncols', 4}, mfilename, 'bbox');

    centerX = bbox(:, 1) + bbox(:, 3) ./ 2;
    centerY = bbox(:, 2) + bbox(:, 4) ./ 2;
    center = [centerX, centerY];
end
