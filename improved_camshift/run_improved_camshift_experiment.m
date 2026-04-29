function result = run_improved_camshift_experiment(config)
%RUN_IMPROVED_CAMSHIFT_EXPERIMENT 杩愯鏀硅繘 CAMshift 璺熻釜瀹為獙銆?
params = create_improved_camshift_parameters(config);
sequence = load_otb_sequence(config);
result = initialize_result_struct(params.methodName, sequence);

predictedBboxes = nan(sequence.numFrames, 4);
frameTimes = nan(sequence.numFrames, 1);
confidenceScores = nan(sequence.numFrames, 1);
stateHistory = nan(sequence.numFrames, 4);
peakRatios = nan(sequence.numFrames, 1);
consecutiveMisses = 0;

firstFrame = local_read_grayscale_frame(sequence.framePaths{1});
initialBbox = local_clamp_bbox(sequence.groundTruth(1, :), size(firstFrame));
[template, ~] = local_crop_patch(firstFrame, initialBbox);
initialCenterXY = local_bbox_to_center(initialBbox);
kalman = initialize_kalman_state([initialCenterXY(2), initialCenterXY(1)], params);

predictedBboxes(1, :) = initialBbox;
confidenceScores(1) = 1;
peakRatios(1) = inf;
stateHistory(1, :) = kalman.state.';

for frameIndex = 2:sequence.numFrames
    currentFrame = local_read_grayscale_frame(sequence.framePaths{frameIndex});
    frameStart = tic;

    [predictedState, predictedCovariance] = kalman_predict_step(kalman.state, kalman.covariance, params);
    predictedCenterRC = predictedState(1:2).';
    dynamicRadius = min(params.maxSearchRadius, ...
        params.searchRadius + consecutiveMisses * params.searchRadiusGrowthPerMiss);
    [response, measurement, bestScore, bestRatio, candidateTemplateSize] = ...
        local_find_best_measurement(currentFrame, predictedCenterRC, template, params, dynamicRadius);

    updateParams = params;
    if ~isempty(measurement)
        updateParams.measurementNoise = params.measurementNoise * ...
            local_measurement_noise_scale(bestScore, params.maxMeasurementNoiseScale);
        consecutiveMisses = 0;
    else
        consecutiveMisses = min(consecutiveMisses + 1, params.maxConsecutiveMisses);
    end

    [updatedState, updatedCovariance] = kalman_update_step(predictedState, predictedCovariance, measurement, updateParams);
    trackedCenterRC = updatedState(1:2).';
    trackedCenterXY = [trackedCenterRC(2), trackedCenterRC(1)];
    trackedBbox = local_center_to_bbox(trackedCenterXY, candidateTemplateSize);
    trackedBbox = local_clamp_bbox(trackedBbox, size(currentFrame));

    [candidateTemplate, candidateNearBorder] = local_crop_patch(currentFrame, trackedBbox);
    [template, ~] = update_adaptive_template(template, candidateTemplate, local_default_confidence(bestScore), ...
        candidateNearBorder, params);

    predictedBboxes(frameIndex, :) = trackedBbox;
    frameTimes(frameIndex) = toc(frameStart);
    confidenceScores(frameIndex) = bestScore;
    peakRatios(frameIndex) = bestRatio;
    stateHistory(frameIndex, :) = updatedState.';

    kalman.state = updatedState;
    kalman.covariance = updatedCovariance;

    if local_should_visualize(config)
        frameToShow = draw_tracking_frame(currentFrame, trackedBbox, params.methodName, [0, 255, 0]);
        imshow(frameToShow);
        drawnow limitrate;
    end
end

result.predictedBboxes = predictedBboxes;
result.centers = local_compute_centers(predictedBboxes);
result.scores = confidenceScores;
result.frameTimes = frameTimes;
result.stateHistory = stateHistory;
result.peakRatios = peakRatios;

[centerErrors, overlaps, meanCLE, meanIoU, precisionAt20, successThresholds, successRates, auc, fps] = ...
    evaluate_tracking_results(predictedBboxes, sequence.groundTruth, frameTimes);
result.metrics = struct( ...
    'centerErrors', centerErrors, ...
    'overlaps', overlaps, ...
    'meanCLE', meanCLE, ...
    'meanIoU', meanIoU, ...
    'precisionAt20', precisionAt20, ...
    'successThresholds', successThresholds, ...
    'successRates', successRates, ...
    'auc', auc, ...
    'fps', fps);

fileStem = sprintf('improved_camshift_%s', local_sequence_name(sequence));
export_experiment_summary(result, config.project.metricsDir, fileStem);
end

function grayFrame = local_read_grayscale_frame(framePath)
frame = imread(framePath);
if ndims(frame) == 3
    grayFrame = rgb2gray(frame);
else
    grayFrame = frame;
end
end

function bbox = local_clamp_bbox(bbox, imageSize)
if exist('clamp_bbox', 'file') == 2
    bbox = clamp_bbox(bbox, imageSize);
else
    height = imageSize(1);
    width = imageSize(2);
    bbox = double(bbox);
    bbox(1) = min(max(bbox(1), 1), width);
    bbox(2) = min(max(bbox(2), 1), height);
    bbox(3) = max(1, min(bbox(3), width - bbox(1) + 1));
    bbox(4) = max(1, min(bbox(4), height - bbox(2) + 1));
end
end

function center = local_bbox_to_center(bbox)
center = bbox_to_center(bbox);
end

function bbox = local_center_to_bbox(centerXY, sizeWH)
bbox = center_to_bbox(centerXY, sizeWH);
end

function [patch, isNearBorder] = local_crop_patch(frame, bbox)
frameHeight = size(frame, 1);
frameWidth = size(frame, 2);
x1 = floor(bbox(1));
y1 = floor(bbox(2));
w = round(bbox(3));
h = round(bbox(4));
x2 = x1 + w - 1;
y2 = y1 + h - 1;
clampedX1 = max(1, x1);
clampedY1 = max(1, y1);
clampedX2 = min(frameWidth, x2);
clampedY2 = min(frameHeight, y2);
isNearBorder = any([clampedX1 ~= x1, clampedY1 ~= y1, clampedX2 ~= x2, clampedY2 ~= y2]);
patch = frame(clampedY1:clampedY2, clampedX1:clampedX2);
if size(patch, 1) ~= h || size(patch, 2) ~= w
    patch = imresize(patch, [h, w]);
end
end

function confidence = local_default_confidence(value)
confidence = value;
if isempty(confidence) || ~isfinite(confidence)
    confidence = -Inf;
end
end

function tf = local_should_visualize(config)
tf = isfield(config, 'runtime') && isfield(config.runtime, 'visualize') && logical(config.runtime.visualize);
end

function centers = local_compute_centers(bboxes)
centers = nan(size(bboxes, 1), 2);
for rowIndex = 1:size(bboxes, 1)
    centers(rowIndex, :) = bbox_to_center(bboxes(rowIndex, :));
end
end

function name = local_sequence_name(sequence)
if isfield(sequence, 'sequenceDir')
    [~, name] = fileparts(sequence.sequenceDir);
else
    name = 'sequence';
end
end

function [bestResponse, bestMeasurement, bestScore, bestRatio, bestTemplateSizeWH] = ...
        local_find_best_measurement(currentFrame, predictedCenterRC, template, params, dynamicRadius)
    bestResponse = struct('isValid', false, 'bestScore', -Inf, 'peakRatio', 0, 'bestLocation', []);
    bestMeasurement = [];
    bestScore = nan;
    bestRatio = 0;
    bestTemplateSizeWH = [size(template, 1), size(template, 2)];

    for scaleValue = params.templateScales
        scaledTemplate = imresize(template, scaleValue);
        if min(size(scaledTemplate)) < 8
            continue;
        end

        tempParams = params;
        tempParams.searchRadius = dynamicRadius;
        searchInfo = extract_search_window(currentFrame, predictedCenterRC, size(scaledTemplate), tempParams);
        response = compute_ncc_response(searchInfo.patch, scaledTemplate);
        if ~response.isValid
            continue;
        end

        if response.bestScore > bestResponse.bestScore
            bestResponse = response;
            bestScore = response.bestScore;
            bestRatio = response.peakRatio;
            matchedTopLeft = searchInfo.topLeft + response.bestLocation - 1;
            templateSizeRC = [size(scaledTemplate, 1); size(scaledTemplate, 2)];
            bestMeasurement = matchedTopLeft(:) + (templateSizeRC - 1) / 2;
            bestTemplateSizeWH = [size(scaledTemplate, 1), size(scaledTemplate, 2)];
        end
    end

    if isempty(bestMeasurement) || bestScore < params.minDetectionConfidence
        bestMeasurement = [];
    end
end

function scaleValue = local_measurement_noise_scale(bestScore, maxScale)
    boundedScore = min(max(bestScore, 0), 1);
    scaleValue = 1 + (1 - boundedScore) * (maxScale - 1);
end
