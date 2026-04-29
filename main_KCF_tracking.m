function result = main_KCF_tracking()
%MAIN_KCF_TRACKING 标准KCF跟踪实验入口脚本。
% 输入:
%   无。
% 输出:
%   result - 实验结果结构体；数据集缺失时返回空。

projectRoot = fileparts(mfilename('fullpath'));
addpath(projectRoot);
addpath(fullfile(projectRoot, 'utils'));
addpath(fullfile(projectRoot, 'kcf_tracking'));
addpath(fullfile(projectRoot, 'experiments_visualization'));

if exist('get_default_config', 'file') == 2
    config = get_default_config();
else
    config = local_get_default_config(projectRoot);
end

config = ensure_minimal_runtime_defaults(config, projectRoot);

if ~has_football_dataset(config)
    disp('SKIP_DATASET');
    result = [];
    return;
end

if exist('validate_config', 'file') == 2
    validate_config(config);
end

result = run_kcf_tracking_experiment(config);

if isfield(result, 'metrics')
    fprintf('KCF meanCLE: %.4f\n', result.metrics.meanCLE);
    fprintf('KCF meanIoU: %.4f\n', result.metrics.meanIoU);
    fprintf('KCF precisionAt20: %.4f\n', result.metrics.precisionAt20);
    fprintf('KCF auc: %.4f\n', result.metrics.auc);
end
if isfield(result, 'outputPaths')
    disp(result.outputPaths);
end
end

function config = local_get_default_config(projectRoot)
%LOCAL_GET_DEFAULT_CONFIG 在共享配置函数缺失时构建本地配置。
% 输入:
%   projectRoot - 项目根目录。
% 输出:
%   config - 本地配置结构体。

config = struct();
config.project.root = projectRoot;
config.project.resultsDir = fullfile(projectRoot, 'results');
config.dataset.rootDir = fullfile(projectRoot, 'data', 'otb');
config.dataset.sequenceName = 'Football';
config.dataset.imageExtension = '.jpg';
config.dataset.groundTruthFile = 'groundtruth_rect.txt';
config.dataset.frameLimit = inf;
config.runtime.visualize = false;
config.runtime.saveVideo = false;
config.runtime.outputPrefix = timestamp_string();
end

function config = ensure_minimal_runtime_defaults(config, projectRoot)
%ENSURE_MINIMAL_RUNTIME_DEFAULTS 补齐运行KCF入口所需最小配置。
% 输入:
%   config - 原始配置结构体。
%   projectRoot - 项目根目录。
% 输出:
%   config - 补齐后的配置结构体。

if ~isfield(config, 'project') || ~isstruct(config.project)
    config.project = struct();
end
if ~isfield(config.project, 'root') || isempty(config.project.root)
    config.project.root = projectRoot;
end
if ~isfield(config.project, 'resultsDir') || isempty(config.project.resultsDir)
    config.project.resultsDir = fullfile(projectRoot, 'results');
end
if ~isfield(config, 'dataset') || ~isstruct(config.dataset)
    config.dataset = struct();
end
if ~isfield(config.dataset, 'rootDir') || isempty(config.dataset.rootDir)
    config.dataset.rootDir = fullfile(projectRoot, 'data', 'otb');
end
if ~isfield(config.dataset, 'sequenceName') || isempty(config.dataset.sequenceName)
    config.dataset.sequenceName = 'Football';
end
if ~isfield(config.dataset, 'imageExtension') || isempty(config.dataset.imageExtension)
    config.dataset.imageExtension = '.jpg';
end
if ~isfield(config.dataset, 'groundTruthFile') || isempty(config.dataset.groundTruthFile)
    config.dataset.groundTruthFile = 'groundtruth_rect.txt';
end
if ~isfield(config.dataset, 'frameLimit') || isempty(config.dataset.frameLimit)
    config.dataset.frameLimit = inf;
end
if ~isfield(config, 'runtime') || ~isstruct(config.runtime)
    config.runtime = struct();
end
if ~isfield(config.runtime, 'visualize') || isempty(config.runtime.visualize)
    config.runtime.visualize = false;
end
if ~isfield(config.runtime, 'saveVideo') || isempty(config.runtime.saveVideo)
    config.runtime.saveVideo = false;
end
if ~isfield(config.runtime, 'outputPrefix') || isempty(config.runtime.outputPrefix)
    config.runtime.outputPrefix = timestamp_string();
end
end

function tf = has_football_dataset(config)
%HAS_FOOTBALL_DATASET 判断Football数据集是否完整可运行。
% 输入:
%   config - 项目配置结构体。
% 输出:
%   tf - 布尔值，表示是否存在完整数据集。

sequenceDir = fullfile(config.dataset.rootDir, config.dataset.sequenceName);
imgDir = fullfile(sequenceDir, 'img');
gtPath = fullfile(sequenceDir, config.dataset.groundTruthFile);

if ~exist(imgDir, 'dir')
    tf = false;
    return;
end
if ~exist(gtPath, 'file')
    tf = false;
    return;
end

frameListing = dir(fullfile(imgDir, ['*' config.dataset.imageExtension]));
tf = ~isempty(frameListing);
end

function value = timestamp_string()
%TIMESTAMP_STRING 生成结果文件使用的时间戳字符串。
% 输入:
%   无。
% 输出:
%   value - 时间戳字符串。

value = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
end
