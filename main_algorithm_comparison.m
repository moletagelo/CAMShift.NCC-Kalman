function main_algorithm_comparison()
%MAIN_ALGORITHM_COMPARISON 杩愯 KCF 涓庢敼杩?CAMshift 瀵规瘮瀹為獙銆?
projectRoot = fileparts(mfilename('fullpath'));
addpath(projectRoot);
addpath(fullfile(projectRoot, 'utils'));
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
fprintf('KCF                    %12.4f  %7.4f  %10.4f  %11.4f  %8.2f\n', ...
    summary.kcf.precisionAt20, summary.kcf.auc, summary.kcf.meanCLE, summary.kcf.meanIoU, summary.kcf.fps);
fprintf('Improved CAMshift      %12.4f  %7.4f  %10.4f  %11.4f  %8.2f\n', ...
    summary.camshift.precisionAt20, summary.camshift.auc, summary.camshift.meanCLE, summary.camshift.meanIoU, summary.camshift.fps);
end

function local_save_comparison(projectRoot, comparison)
resultsDir = fullfile(projectRoot, 'results');
metricsDir = fullfile(resultsDir, 'metrics');
ensure_dir(resultsDir);
ensure_dir(metricsDir);
save(fullfile(resultsDir, 'algorithm_comparison_summary.mat'), 'comparison');

if exist('export_experiment_summary', 'file') == 2
    export_experiment_summary(comparison.kcf, metricsDir, 'comparison_kcf');
    export_experiment_summary(comparison.camshift, metricsDir, 'comparison_improved_camshift');
end
end
