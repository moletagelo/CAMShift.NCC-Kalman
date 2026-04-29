function [centerErrors, meanCLE] = compute_cle(predBboxes, gtBboxes)
%COMPUTE_CLE 计算逐帧中心位置误差及其均值。
% 输入：predBboxes 和 gtBboxes，均为 N×4 的 [x, y, width, height]。
% 输出：centerErrors，逐帧欧氏距离；meanCLE，忽略 NaN 后的平均值。

    validate_bbox_pair(predBboxes, gtBboxes);

    predCenters = bbox_to_center(predBboxes);
    gtCenters = bbox_to_center(gtBboxes);

    centerErrors = sqrt(sum((predCenters - gtCenters) .^ 2, 2));
    invalidMask = any(isnan(predBboxes), 2) | any(isnan(gtBboxes), 2);
    centerErrors(invalidMask) = NaN;
    meanCLE = mean(centerErrors, 'omitnan');
end

function validate_bbox_pair(predBboxes, gtBboxes)
    validateattributes(predBboxes, {'numeric'}, {'ncols', 4}, mfilename, 'predBboxes');
    validateattributes(gtBboxes, {'numeric'}, {'ncols', 4}, mfilename, 'gtBboxes');
    if size(predBboxes, 1) ~= size(gtBboxes, 1)
        error('compute_cle:SizeMismatch', ...
            'predBboxes and gtBboxes must have the same number of rows.');
    end
end
