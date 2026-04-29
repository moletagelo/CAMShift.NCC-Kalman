function outputFile = plot_success_curve(successThresholds, successRates, methodName, outputFile)
%PLOT_SUCCESS_CURVE 绘制并保存成功率曲线 PNG 图像。
% 输入：successThresholds，IoU 阈值；successRates，成功率；methodName，算法名称；outputFile，PNG 路径。
% 输出：outputFile，实际保存的 PNG 路径。

    successThresholds = successThresholds(:);
    successRates = successRates(:);

    outputDir = fileparts(outputFile);
    if strlength(string(outputDir)) > 0
        ensure_dir(outputDir);
    end

    fig = figure('Visible', 'off', 'Color', 'w');
    plot(successThresholds, successRates, 'LineWidth', 2);
    grid on;
    xlabel('Overlap threshold');
    ylabel('Success rate');
    title(sprintf('%s Success Plot', char(string(methodName))));
    xlim([successThresholds(1), successThresholds(end)]);
    ylim([0, 1]);
    saveas(fig, outputFile);
    close(fig);
end
