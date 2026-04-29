function outputFile = plot_multi_success_curve(curveEntries, outputFile, plotTitle)
%PLOT_MULTI_SUCCESS_CURVE 绘制多算法成功率对比曲线。
    ensure_dir(fileparts(outputFile));
    fig = figure('Visible', 'off', 'Color', 'w');
    hold on;
    colors = lines(numel(curveEntries));
    for idx = 1:numel(curveEntries)
        plot(curveEntries(idx).successThresholds(:), curveEntries(idx).successRates(:), ...
            'LineWidth', 2, 'Color', colors(idx, :), 'DisplayName', curveEntries(idx).methodName);
    end
    hold off;
    grid on;
    xlabel('Overlap threshold');
    ylabel('Success rate');
    title(plotTitle);
    xlim([0, 1]);
    ylim([0, 1]);
    legend('Location', 'southwest');
    saveas(fig, outputFile);
    close(fig);
end
