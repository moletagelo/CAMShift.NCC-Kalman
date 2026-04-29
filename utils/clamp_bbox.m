function bbox = clamp_bbox(bbox, imageSize)
%CLAMP_BBOX 将矩形框裁剪到图像边界范围内。
% 输入：bbox，1×4 或 N×4 的 [x, y, width, height]；imageSize，图像尺寸。
% 输出：bbox，裁剪后的矩形框矩阵。

    validateattributes(bbox, {'numeric'}, {'ncols', 4}, mfilename, 'bbox');
    validateattributes(imageSize, {'numeric'}, {'vector', 'numel', 2}, mfilename, 'imageSize');

    imageHeight = imageSize(1);
    imageWidth = imageSize(2);

    bbox(:, 1) = min(max(bbox(:, 1), 1), imageWidth);
    bbox(:, 2) = min(max(bbox(:, 2), 1), imageHeight);

    maxWidth = max(1, imageWidth - bbox(:, 1) + 1);
    maxHeight = max(1, imageHeight - bbox(:, 2) + 1);

    bbox(:, 3) = min(max(bbox(:, 3), 1), maxWidth);
    bbox(:, 4) = min(max(bbox(:, 4), 1), maxHeight);
end
