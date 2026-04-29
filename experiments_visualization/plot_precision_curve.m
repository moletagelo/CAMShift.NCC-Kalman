function outputFile = plot_precision_curve(centerErrors, methodName, outputFile, thresholds)
%PLOT_PRECISION_CURVE 绘制并保存精度曲线 PNG 图像。
% 输入：centerErrors，逐帧中心误差；methodName，算法名称；outputFile，PNG 路径；thresholds，可选阈值。
% 输出：outputFile，实际保存的 PNG 路径。

    if nargin < 4 || isempty(thresholds)
        thresholds = 0:50;
    end

    thresholds = thresholds(:);
    precisionRates = arrayfun(@(threshold) mean(centerErrors <= threshold, 'omitnan'), thresholds);

    outputDir = fileparts(outputFile);
    if strlength(string(outputDir)) > 0
        ensure_dir(outputDir);
    end

    fig = figure('Visible', 'off', 'Color', 'w');
    plot(thresholds, precisionRates, 'LineWidth', 2);
    grid on;
    xlabel('Center error threshold (pixels)');
    ylabel('Precision');
    title(sprintf('%s Precision Plot', char(string(methodName))));
    xlim([thresholds(1), thresholds(end)]);
    ylim([0, 1]);
    saveas(fig, outputFile);
    close(fig);
end
