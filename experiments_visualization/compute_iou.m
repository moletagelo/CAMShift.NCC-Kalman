function [overlaps, meanIoU] = compute_iou(predBboxes, gtBboxes)
%COMPUTE_IOU 计算逐帧交并比及其均值。
% 输入：predBboxes 和 gtBboxes，均为 N×4 的 [x, y, width, height]。
% 输出：overlaps，逐帧 IoU；meanIoU，忽略 NaN 后的平均值。

    validate_bbox_pair(predBboxes, gtBboxes);

    predLeft = predBboxes(:, 1);
    predTop = predBboxes(:, 2);
    predRight = predBboxes(:, 1) + predBboxes(:, 3);
    predBottom = predBboxes(:, 2) + predBboxes(:, 4);

    gtLeft = gtBboxes(:, 1);
    gtTop = gtBboxes(:, 2);
    gtRight = gtBboxes(:, 1) + gtBboxes(:, 3);
    gtBottom = gtBboxes(:, 2) + gtBboxes(:, 4);

    interLeft = max(predLeft, gtLeft);
    interTop = max(predTop, gtTop);
    interRight = min(predRight, gtRight);
    interBottom = min(predBottom, gtBottom);

    interWidth = max(0, interRight - interLeft);
    interHeight = max(0, interBottom - interTop);
    interArea = interWidth .* interHeight;

    predArea = max(predBboxes(:, 3), 0) .* max(predBboxes(:, 4), 0);
    gtArea = max(gtBboxes(:, 3), 0) .* max(gtBboxes(:, 4), 0);
    unionArea = predArea + gtArea - interArea;

    overlaps = interArea ./ unionArea;
    overlaps(unionArea <= 0) = NaN;
    invalidMask = any(isnan(predBboxes), 2) | any(isnan(gtBboxes), 2);
    overlaps(invalidMask) = NaN;
    meanIoU = mean(overlaps, 'omitnan');
end

function validate_bbox_pair(predBboxes, gtBboxes)
    validateattributes(predBboxes, {'numeric'}, {'ncols', 4}, mfilename, 'predBboxes');
    validateattributes(gtBboxes, {'numeric'}, {'ncols', 4}, mfilename, 'gtBboxes');
    if size(predBboxes, 1) ~= size(gtBboxes, 1)
        error('compute_iou:SizeMismatch', ...
            'predBboxes and gtBboxes must have the same number of rows.');
    end
end
