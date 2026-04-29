function result = run_basic_detection_experiment(config)
% 运行基础预处理与经典运动检测实验，并汇总各方法输出。
% 输入:
%   config - 实验配置结构体，依赖共享数据加载接口
% 输出:
%   result - 实验结果结构体，包含各检测方法输出与示例帧

validateattributes(config, {'struct'}, {'nonempty'}, mfilename, 'config', 1);

config = ensure_detection_config(config);
sequence = load_otb_sequence(config);

framePaths = sequence.framePaths;
groundTruth = [];
if isfield(sequence, 'groundTruth')
    groundTruth = sequence.groundTruth;
end

numFrames = numel(framePaths);
if numFrames < 2
    error('run_basic_detection_experiment:InsufficientFrames', ...
        'At least two frames are required for motion detection.');
end

methodNames = config.basicDetection.methods;
methodOutputs = struct();
methodStates = struct();
sampleFrameData = repmat(struct('frameIndex', [], 'framePath', "", 'renderedFrames', struct()), 0, 1);
sampleFrameSet = unique(max(2, min(numFrames, round(linspace(2, numFrames, min(5, numFrames - 1))))));

previousProcessed = preprocess_frame(imread(framePaths{1}), config);

for methodIndex = 1:numel(methodNames)
    methodName = methodNames{methodIndex};
    methodOutputs.(methodName) = initialize_method_output(numFrames - 1);
    methodStates.(methodName) = [];
end

for frameIndex = 2:numFrames
    rawFrame = imread(framePaths{frameIndex});
    currentProcessed = preprocess_frame(rawFrame, config);

    for methodIndex = 1:numel(methodNames)
        methodName = methodNames{methodIndex};
        [mask, bbox, stats, updatedState] = run_detection_method( ...
            methodName, previousProcessed, currentProcessed, methodStates.(methodName), config.basicDetection);

        entryIndex = frameIndex - 1;
        methodOutputs.(methodName).masks{entryIndex, 1} = logical(mask);
        methodOutputs.(methodName).bboxes(entryIndex, :) = bbox;
        methodOutputs.(methodName).scores(entryIndex, 1) = extract_detection_score(mask, stats);
        methodOutputs.(methodName).stats{entryIndex, 1} = stats;
        methodOutputs.(methodName).frameIndices(entryIndex, 1) = frameIndex;
        methodStates.(methodName) = updatedState;
    end

    if any(sampleFrameSet == frameIndex)
        sampleEntry = struct();
        sampleEntry.frameIndex = frameIndex;
        sampleEntry.framePath = string(framePaths{frameIndex});
        renderedFrames = struct();
        for methodIndex = 1:numel(methodNames)
            methodName = methodNames{methodIndex};
            bbox = methodOutputs.(methodName).bboxes(frameIndex - 1, :);
            color = get_method_color(methodName);
            renderedFrames.(methodName) = draw_tracking_frame(rawFrame, bbox, methodName, color);
        end
        sampleEntry.renderedFrames = renderedFrames;
        sampleFrameData(end + 1, 1) = sampleEntry; %#ok<AGROW>
    end

    previousProcessed = currentProcessed;
end

result = struct();
result.experimentName = 'basic_detection';
result.sequenceName = get_nested_value(config, {'dataset', 'sequenceName'}, "unknown");
result.frameCount = numFrames;
result.processedFrameCount = numFrames - 1;
result.framePaths = framePaths;
result.groundTruth = groundTruth;
result.methodOutputs = methodOutputs;
result.sampleFrames = sampleFrameData;
result.config = config;
end

function config = ensure_detection_config(config)
% 补齐基础检测实验所需的默认配置字段。

if ~isfield(config, 'runtime') || ~isstruct(config.runtime)
    config.runtime = struct();
end

if ~isfield(config.runtime, 'visualize')
    config.runtime.visualize = false;
end

if ~isfield(config.runtime, 'saveVideo')
    config.runtime.saveVideo = false;
end

if ~isfield(config.runtime, 'outputPrefix') || isempty(config.runtime.outputPrefix)
    config.runtime.outputPrefix = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
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

preprocessingDefaults = struct( ...
    'convertToGray', true, ...
    'gaussianSigma', 1.0, ...
    'gaussianKernelSize', [], ...
    'histogramMode', 'none');
config.basicDetection.preprocessing = merge_detection_options(config.basicDetection.preprocessing, preprocessingDefaults);

methodDefaults = struct( ...
    'frameDifference', struct('threshold', 25, 'minArea', 25, 'useMorphology', true, 'diskRadius', 2), ...
    'backgroundMean', struct('threshold', 20, 'learningRate', 0.05, 'minArea', 25, 'useMorphology', true, 'diskRadius', 2), ...
    'backgroundGMM', struct('numGaussians', 3, 'trainingFrames', 30, 'minimumBackgroundRatio', 0.7, 'learningRate', 0.005, 'threshold', 20, 'minArea', 25, 'useMorphology', true, 'diskRadius', 2), ...
    'lucasKanade', struct('minQuality', 0.01, 'maxBidirectionalError', 2.0, 'blockSize', [15, 15], 'numPyramidLevels', 3, 'motionThreshold', 0.75, 'minArea', 25));

for fieldCell = fieldnames(methodDefaults)'
    fieldName = fieldCell{1};
    if ~isfield(config.basicDetection, fieldName) || ~isstruct(config.basicDetection.(fieldName))
        config.basicDetection.(fieldName) = struct();
    end
    config.basicDetection.(fieldName) = merge_detection_options(config.basicDetection.(fieldName), methodDefaults.(fieldName));
end
end

function processedFrame = preprocess_frame(frame, config)
% 根据配置顺序执行预处理流水线。

processedFrame = frame;
preprocessingConfig = config.basicDetection.preprocessing;

if preprocessingConfig.convertToGray
    processedFrame = convert_to_grayscale(processedFrame);
end

if ~isempty(preprocessingConfig.gaussianSigma) && preprocessingConfig.gaussianSigma > 0
    processedFrame = apply_gaussian_filter( ...
        processedFrame, preprocessingConfig.gaussianSigma, preprocessingConfig.gaussianKernelSize);
end

histogramMode = string(preprocessingConfig.histogramMode);
if ~strcmpi(histogramMode, "none")
    processedFrame = apply_histogram_equalization(processedFrame, histogramMode);
end
end

function methodOutput = initialize_method_output(numEntries)
% 初始化单个检测方法的输出缓存。

methodOutput = struct();
methodOutput.masks = cell(numEntries, 1);
methodOutput.bboxes = zeros(numEntries, 4);
methodOutput.scores = zeros(numEntries, 1);
methodOutput.stats = cell(numEntries, 1);
methodOutput.frameIndices = zeros(numEntries, 1);
end

function [mask, bbox, stats, updatedState] = run_detection_method(methodName, previousFrame, currentFrame, currentState, basicDetectionConfig)
% 调度不同运动检测方法并返回统一结果格式。

switch methodName
    case 'frameDifference'
        [mask, bbox, stats] = frame_difference_detection(previousFrame, currentFrame, basicDetectionConfig.frameDifference);
        updatedState = [];
    case 'backgroundMean'
        [mask, updatedState, bbox, stats] = background_subtraction_mean(currentFrame, currentState, basicDetectionConfig.backgroundMean);
    case 'backgroundGMM'
        [mask, updatedState, bbox, stats] = background_subtraction_gmm(currentFrame, currentState, basicDetectionConfig.backgroundGMM);
    case 'lucasKanade'
        [mask, ~, ~, bbox, updatedState, stats] = ...
            lucas_kanade_motion_detection(previousFrame, currentFrame, currentState, basicDetectionConfig.lucasKanade);
    otherwise
        error('run_basic_detection_experiment:UnsupportedMethod', ...
            'Unsupported detection method: %s', methodName);
end
end

function score = extract_detection_score(mask, stats)
% 提取统一的检测强度分数，便于后续导出和排序。

score = nnz(mask);
if isstruct(stats)
    if isfield(stats, 'meanDifference')
        score = stats.meanDifference;
    elseif isfield(stats, 'meanMotionMagnitude')
        score = stats.meanMotionMagnitude;
    end
end
end

function color = get_method_color(methodName)
% 为不同方法分配稳定的可视化颜色。

switch methodName
    case 'frameDifference'
        color = [255, 196, 0];
    case 'backgroundMean'
        color = [0, 176, 80];
    case 'backgroundGMM'
        color = [0, 112, 192];
    case 'lucasKanade'
        color = [192, 0, 0];
    otherwise
        color = [255, 255, 255];
end
end

function value = get_nested_value(structValue, fieldPath, defaultValue)
% 从嵌套结构体中安全读取字段，不存在时返回默认值。

value = defaultValue;
currentValue = structValue;
for pathIndex = 1:numel(fieldPath)
    fieldName = fieldPath{pathIndex};
    if ~isstruct(currentValue) || ~isfield(currentValue, fieldName)
        return;
    end
    currentValue = currentValue.(fieldName);
end
value = currentValue;
end
