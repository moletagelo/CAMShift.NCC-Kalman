function main_algorithm_comparison()
%MAIN_ALGORITHM_COMPARISON 杩愯 KCF 涓庢敼杩?CAMshift 瀵规瘮瀹為獙銆?
projectRoot = fileparts(mfilename('fullpath'));
addpath(projectRoot);
addpath(fullfile(projectRoot, 'utils'));
addpath(fullfile(projectRoot, 'classic_camshift'));
addpath(fullfile(projectRoot, 'kcf_tracking'));
addpath(fullfile(projectRoot, 'improved_camshift'));
addpath(fullfile(projectRoot, 'experiments_visualization'));

if ~local_has_football_dataset(projectRoot)
    disp('SKIP_DATASET');
    return;
end

config = get_default_config();
config.dataset.sequenceName = 'Football';
config.runtime.visualize = false;

validate_config(config);
comparison = run_comparison_experiment(config);

local_print_summary(comparison.summary);
local_save_comparison(projectRoot, comparison);
end

function tf = local_has_football_dataset(projectRoot)
datasetDir = fullfile(projectRoot, 'data', 'otb', 'Football');
imageDir = fullfile(datasetDir, 'img');
gtFile = fullfile(datasetDir, 'groundtruth_rect.txt');
tf = exist(datasetDir, 'dir') == 7 && ...
     exist(imageDir, 'dir') == 7 && ...
     exist(gtFile, 'file') == 2 && ...
     ~isempty(dir(fullfile(imageDir, '*.jpg')));
end

function local_print_summary(summary)
fprintf('Method                    Precision@20      AUC      MeanCLE      MeanIoU      FPS\n');
fprintf('Classic CAMshift       %12.4f  %7.4f  %10.4f  %11.4f  %8.2f\n', ...
    summary.classicCamshift.precisionAt20, summary.classicCamshift.auc, ...
    summary.classicCamshift.meanCLE, summary.classicCamshift.meanIoU, summary.classicCamshift.fps);
fprintf('KCF                    %12.4f  %7.4f  %10.4f  %11.4f  %8.2f\n', ...
    summary.kcf.precisionAt20, summary.kcf.auc, summary.kcf.meanCLE, summary.kcf.meanIoU, summary.kcf.fps);
fprintf('Improved CAMshift      %12.4f  %7.4f  %10.4f  %11.4f  %8.2f\n', ...
    summary.improvedCamshift.precisionAt20, summary.improvedCamshift.auc, ...
    summary.improvedCamshift.meanCLE, summary.improvedCamshift.meanIoU, summary.improvedCamshift.fps);
end

function local_save_comparison(projectRoot, comparison)
resultsDir = fullfile(projectRoot, 'results');
metricsDir = fullfile(resultsDir, 'metrics');
ensure_dir(resultsDir);
ensure_dir(metricsDir);
save(fullfile(resultsDir, 'algorithm_comparison_summary.mat'), 'comparison');

if exist('export_experiment_summary', 'file') == 2
    export_experiment_summary(comparison.classicCamshift, metricsDir, 'comparison_classic_camshift');
    export_experiment_summary(comparison.kcf, metricsDir, 'comparison_kcf');
    export_experiment_summary(comparison.improvedCamshift, metricsDir, 'comparison_improved_camshift');
end

curveEntries = [ ...
    struct('methodName', 'Classic CAMShift', 'centerErrors', comparison.classicCamshift.metrics.centerErrors, ...
           'successThresholds', comparison.classicCamshift.metrics.successThresholds, 'successRates', comparison.classicCamshift.metrics.successRates), ...
    struct('methodName', 'Improved CAMShift', 'centerErrors', comparison.improvedCamshift.metrics.centerErrors, ...
           'successThresholds', comparison.improvedCamshift.metrics.successThresholds, 'successRates', comparison.improvedCamshift.metrics.successRates), ...
    struct('methodName', 'KCF', 'centerErrors', comparison.kcf.metrics.centerErrors, ...
           'successThresholds', comparison.kcf.metrics.successThresholds, 'successRates', comparison.kcf.metrics.successRates)];

familyEntries = curveEntries(1:2);
plot_multi_precision_curve(familyEntries, fullfile(metricsDir, 'camshift_family_precision.png'), ...
    'Improved CAMShift vs Classic CAMShift Precision Plot');
plot_multi_success_curve(familyEntries, fullfile(metricsDir, 'camshift_family_success.png'), ...
    'Improved CAMShift vs Classic CAMShift Success Plot');
plot_multi_precision_curve(curveEntries, fullfile(metricsDir, 'all_trackers_precision.png'), ...
    'Classic CAMShift, Improved CAMShift, and KCF Precision Plot');
plot_multi_success_curve(curveEntries, fullfile(metricsDir, 'all_trackers_success.png'), ...
    'Classic CAMShift, Improved CAMShift, and KCF Success Plot');

summaryTable = table( ...
    ["Classic CAMShift"; "Improved CAMShift"; "KCF"], ...
    [comparison.classicCamshift.metrics.precisionAt20; comparison.improvedCamshift.metrics.precisionAt20; comparison.kcf.metrics.precisionAt20], ...
    [comparison.classicCamshift.metrics.auc; comparison.improvedCamshift.metrics.auc; comparison.kcf.metrics.auc], ...
    [comparison.classicCamshift.metrics.meanCLE; comparison.improvedCamshift.metrics.meanCLE; comparison.kcf.metrics.meanCLE], ...
    [comparison.classicCamshift.metrics.meanIoU; comparison.improvedCamshift.metrics.meanIoU; comparison.kcf.metrics.meanIoU], ...
    [comparison.classicCamshift.metrics.fps; comparison.improvedCamshift.metrics.fps; comparison.kcf.metrics.fps], ...
    'VariableNames', {'Method', 'PrecisionAt20', 'AUC', 'MeanCLE', 'MeanIoU', 'FPS'});
writetable(summaryTable, fullfile(metricsDir, 'comparison_summary_table.csv'));
end
