function outputFile = plot_multi_precision_curve(curveEntries, outputFile, plotTitle, thresholds)
%PLOT_MULTI_PRECISION_CURVE 绘制多算法精度对比曲线。
    if nargin < 4 || isempty(thresholds)
        thresholds = 0:50;
    end
    thresholds = thresholds(:);
    ensure_dir(fileparts(outputFile));

    fig = figure('Visible', 'off', 'Color', 'w');
    hold on;
    colors = lines(numel(curveEntries));
    for idx = 1:numel(curveEntries)
        precisionRates = arrayfun(@(threshold) mean(curveEntries(idx).centerErrors <= threshold, 'omitnan'), thresholds);
        plot(thresholds, precisionRates, 'LineWidth', 2, 'Color', colors(idx, :), ...
            'DisplayName', curveEntries(idx).methodName);
    end
    hold off;
    grid on;
    xlabel('Center error threshold (pixels)');
    ylabel('Precision');
    title(plotTitle);
    xlim([thresholds(1), thresholds(end)]);
    ylim([0, 1]);
    legend('Location', 'southeast');
    saveas(fig, outputFile);
    close(fig);
end
