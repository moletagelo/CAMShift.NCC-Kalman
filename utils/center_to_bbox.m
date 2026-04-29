function bbox = center_to_bbox(center, sizeHW)
%CENTER_TO_BBOX 根据中心点和尺寸恢复矩形框。
% 输入：center，1×2 或 N×2 的中心点；sizeHW，1×2 的 [height, width]。
% 输出：bbox，N×4 的 [x, y, width, height] 矩阵。

    validateattributes(center, {'numeric'}, {'ncols', 2}, mfilename, 'center');
    validateattributes(sizeHW, {'numeric'}, {'vector', 'numel', 2}, mfilename, 'sizeHW');

    height = sizeHW(1);
    width = sizeHW(2);
    bboxX = center(:, 1) - width ./ 2;
    bboxY = center(:, 2) - height ./ 2;
    bbox = [bboxX, bboxY, repmat(width, size(center, 1), 1), repmat(height, size(center, 1), 1)];
end
