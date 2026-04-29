function [centerErrors, overlaps, meanCLE, meanIoU, precisionAt20, ...
        successThresholds, successRates, auc, fps] = ...
        evaluate_tracking_results(predBboxes, gtBboxes, frameTimes)
%EVALUATE_TRACKING_RESULTS 计算跟踪精度、成功率、AUC 与帧率指标。
% 输入：predBboxes、gtBboxes 为 N×4；frameTimes 为 N×1 或空数组。
% 输出：逐帧误差、逐帧 IoU、均值指标、20 像素精度、成功率曲线、AUC 和 FPS。

    if nargin < 3 || isempty(frameTimes)
        frameTimes = nan(size(predBboxes, 1), 1);
    end

    [centerErrors, meanCLE] = compute_cle(predBboxes, gtBboxes);
    [overlaps, meanIoU] = compute_iou(predBboxes, gtBboxes);

    precisionAt20 = mean(centerErrors <= 20, 'omitnan');

    successThresholds = (0:0.05:1).';
    successRates = nan(size(successThresholds));
    for idx = 1:numel(successThresholds)
        successRates(idx) = mean(overlaps >= successThresholds(idx), 'omitnan');
    end

    auc = trapz(successThresholds, successRates);

    frameTimes = frameTimes(:);
    validFrameTimes = frameTimes(isfinite(frameTimes) & frameTimes > 0);
    if isempty(validFrameTimes)
        fps = NaN;
    else
        fps = 1 / mean(validFrameTimes);
    end
end
