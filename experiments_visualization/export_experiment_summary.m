function export_experiment_summary(resultStruct, outputDir, fileStem)
%EXPORT_EXPERIMENT_SUMMARY 导出结果结构、CSV 表格及指标曲线图。
% 输入：resultStruct，实验结果结构体；outputDir，输出目录；fileStem，文件名前缀。
% 输出：无。

    if nargin < 2 || isempty(outputDir)
        project = bootstrap_project();
        outputDir = project.metricsDir;
    end
    if nargin < 3 || isempty(fileStem)
        fileStem = lower(regexprep(resultStruct.methodName, '\s+', '_'));
    end

    ensure_dir(outputDir);

    matFile = fullfile(outputDir, [fileStem, '.mat']);
    bboxCsvFile = fullfile(outputDir, [fileStem, '_bboxes.csv']);
    metricsCsvFile = fullfile(outputDir, [fileStem, '_metrics.csv']);
    precisionPngFile = fullfile(outputDir, [fileStem, '_precision.png']);
    successPngFile = fullfile(outputDir, [fileStem, '_success.png']);

    save_result_struct(resultStruct, matFile);

    bboxTable = table( ...
        resultStruct.predictedBboxes(:, 1), ...
        resultStruct.predictedBboxes(:, 2), ...
        resultStruct.predictedBboxes(:, 3), ...
        resultStruct.predictedBboxes(:, 4), ...
        resultStruct.centers(:, 1), ...
        resultStruct.centers(:, 2), ...
        resultStruct.scores(:), ...
        resultStruct.frameTimes(:), ...
        'VariableNames', {'x', 'y', 'width', 'height', 'centerX', 'centerY', 'score', 'frameTime'});
    writetable(bboxTable, bboxCsvFile);

    metricsStruct = collect_metrics(resultStruct);
    save_metrics_table(metricsStruct, metricsCsvFile);

    if isfield(metricsStruct, 'centerErrors') && ~isempty(metricsStruct.centerErrors)
        plot_precision_curve(metricsStruct.centerErrors, resultStruct.methodName, precisionPngFile);
    end

    if isfield(metricsStruct, 'successThresholds') && isfield(metricsStruct, 'successRates') ...
            && ~isempty(metricsStruct.successThresholds) && ~isempty(metricsStruct.successRates)
        plot_success_curve( ...
            metricsStruct.successThresholds, metricsStruct.successRates, ...
            resultStruct.methodName, successPngFile);
    end
end

function metricsStruct = collect_metrics(resultStruct)
    metricsStruct = struct();

    if isfield(resultStruct, 'metrics') && isstruct(resultStruct.metrics)
        metricsStruct = resultStruct.metrics;
    end

    metricFields = {'centerErrors', 'overlaps', 'meanCLE', 'meanIoU', ...
        'precisionAt20', 'successThresholds', 'successRates', 'auc', 'fps'};
    for idx = 1:numel(metricFields)
        fieldName = metricFields{idx};
        if isfield(resultStruct, fieldName)
            metricsStruct.(fieldName) = resultStruct.(fieldName);
        end
    end

    metricsStruct.methodName = resultStruct.methodName;
    if isfield(resultStruct, 'sequenceName')
        metricsStruct.sequenceName = resultStruct.sequenceName;
    end
end
