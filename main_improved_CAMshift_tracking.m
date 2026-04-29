function main_improved_CAMshift_tracking()
%MAIN_IMPROVED_CAMSHIFT_TRACKING 杩愯鏀硅繘 CAMshift 璺熻釜瀹為獙銆?
projectRoot = fileparts(mfilename('fullpath'));
addpath(projectRoot);
addpath(fullfile(projectRoot, 'utils'));
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
result = run_improved_camshift_experiment(config);

fprintf('Improved CAMshift Precision@20: %.4f\n', local_get_metric(result.metrics, 'precisionAt20'));
fprintf('Improved CAMshift AUC: %.4f\n', local_get_metric(result.metrics, 'auc'));
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

function value = local_get_metric(metrics, fieldName)
if isfield(metrics, fieldName)
    value = metrics.(fieldName);
else
    value = NaN;
end
end
