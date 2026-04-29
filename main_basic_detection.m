function main_basic_detection()
%MAIN_BASIC_DETECTION 杩愯鍩虹棰勫鐞嗕笌杩愬姩妫€娴嬪疄楠屻€?
rootDir = fileparts(mfilename('fullpath'));
addpath(rootDir);
addpath(fullfile(rootDir, 'utils'));
addpath(fullfile(rootDir, 'preprocessing_detection'));
addpath(fullfile(rootDir, 'experiments_visualization'));

datasetDir = fullfile(rootDir, 'data', 'otb', 'Football');
if ~exist(datasetDir, 'dir')
    fprintf('SKIP_DATASET\n');
    return;
end

config = get_default_config();
config = apply_basic_detection_defaults(config, rootDir);
validate_config(config);

result = run_basic_detection_experiment(config);

resultsDir = fullfile(rootDir, 'results', 'metrics');
ensure_dir(resultsDir);

outputPrefix = char(config.runtime.outputPrefix);
resultFile = fullfile(resultsDir, sprintf('%s_basic_detection_result.mat', outputPrefix));
summaryStem = sprintf('%s_basic_detection_summary', outputPrefix);

save_result_struct(result, resultFile);
if exist('export_experiment_summary', 'file') == 2
    try
        export_experiment_summary(result, resultsDir, summaryStem);
    catch
        write_plaintext_summary(result, fullfile(resultsDir, [summaryStem '.txt']));
    end
else
    write_plaintext_summary(result, fullfile(resultsDir, [summaryStem '.txt']));
end

fprintf('Basic detection finished: %s\n', resultFile);
end

function config = apply_basic_detection_defaults(config, rootDir)
if ~isfield(config, 'project') || ~isstruct(config.project)
    config.project = struct();
end
config.project.root = rootDir;

if ~isfield(config, 'runtime') || ~isstruct(config.runtime)
    config.runtime = struct();
end
config.runtime.mode = 'basic_detection';
if ~isfield(config.runtime, 'visualize')
    config.runtime.visualize = false;
end
if ~isfield(config.runtime, 'saveVideo')
    config.runtime.saveVideo = false;
end
if ~isfield(config.runtime, 'outputPrefix') || isempty(config.runtime.outputPrefix)
    config.runtime.outputPrefix = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
end

if ~isfield(config, 'dataset') || ~isstruct(config.dataset)
    config.dataset = struct();
end
config.dataset.rootDir = fullfile(rootDir, 'data', 'otb');
config.dataset.sequenceName = 'Football';
if ~isfield(config.dataset, 'imageExtension') || isempty(config.dataset.imageExtension)
    config.dataset.imageExtension = '.jpg';
end
if ~isfield(config.dataset, 'groundTruthFile') || isempty(config.dataset.groundTruthFile)
    config.dataset.groundTruthFile = 'groundtruth_rect.txt';
end
if ~isfield(config.dataset, 'frameLimit') || isempty(config.dataset.frameLimit)
    config.dataset.frameLimit = inf;
end

if ~isfield(config, 'basicDetection') || ~isstruct(config.basicDetection)
    config.basicDetection = struct();
end
if ~isfield(config.basicDetection, 'methods') || isempty(config.basicDetection.methods)
    config.basicDetection.methods = {'frameDifference', 'backgroundMean', 'backgroundGMM', 'lucasKanade'};
end
if ~isfield(config.basicDetection, 'preprocessing') || ~isstruct(config.basicDetection.preprocessing)
    config.basicDetection.preprocessing = struct();
end
if ~isfield(config.basicDetection.preprocessing, 'convertToGray')
    config.basicDetection.preprocessing.convertToGray = true;
end
if ~isfield(config.basicDetection.preprocessing, 'gaussianSigma')
    config.basicDetection.preprocessing.gaussianSigma = 1.0;
end
if ~isfield(config.basicDetection.preprocessing, 'gaussianKernelSize')
    config.basicDetection.preprocessing.gaussianKernelSize = [];
end
if ~isfield(config.basicDetection.preprocessing, 'histogramMode')
    config.basicDetection.preprocessing.histogramMode = 'none';
end
end

function write_plaintext_summary(result, summaryFile)
fileId = fopen(summaryFile, 'w');
if fileId < 0
    warning('main_basic_detection:SummaryWriteFailed', ...
        'Unable to write summary file: %s', summaryFile);
    return;
end
cleanupObj = onCleanup(@() fclose(fileId));
fprintf(fileId, 'Experiment: %s\n', result.experimentName);
fprintf(fileId, 'Sequence: %s\n', result.sequenceName);
fprintf(fileId, 'Processed frames: %d\n', result.processedFrameCount);
methodNames = fieldnames(result.methodOutputs);
for methodIndex = 1:numel(methodNames)
    methodName = methodNames{methodIndex};
    scores = result.methodOutputs.(methodName).scores;
    fprintf(fileId, '%s mean score: %.4f\n', methodName, mean(scores));
end
clear cleanupObj;
end
