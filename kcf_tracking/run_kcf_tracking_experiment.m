function result = run_kcf_tracking_experiment(config)
%RUN_KCF_TRACKING_EXPERIMENT 杩愯鏍囧噯 KCF 璺熻釜瀹為獙骞惰繑鍥炵粨鏋溿€?
if nargin < 1 || isempty(config)
    config = get_default_config();
end

sequence = load_otb_sequence(config);
params = create_kcf_parameters(config);
result = initialize_result_struct('KCF', sequence);
result.config = config;
result.parameters = params;

firstFrame = imread(sequence.framePaths{1});
initialBBox = double(sequence.groundTruth(1, :));
tracker = initialize_kcf_tracker(firstFrame, initialBBox, params);

result.predictedBboxes(1, :) = initialBBox;
result.centers(1, :) = bbox_to_center(initialBBox);
result.scores(1) = NaN;
result.frameTimes(1) = NaN;

for frameIdx = 2:sequence.numFrames
    frame = imread(sequence.framePaths{frameIdx});
    frameStart = tic;
    [tracker, prediction, diagnostics] = update_kcf_tracker(tracker, frame);
    result.frameTimes(frameIdx) = toc(frameStart);
    result.predictedBboxes(frameIdx, :) = prediction;
    result.centers(frameIdx, :) = bbox_to_center(prediction);
    result.scores(frameIdx) = diagnostics.peakValue;

    if isfield(config.runtime, 'visualize') && logical(config.runtime.visualize)
        frameOut = draw_tracking_frame(frame, prediction, 'KCF', [255, 0, 0]);
        imshow(frameOut);
        drawnow limitrate;
    end
end

[centerErrors, overlaps, meanCLE, meanIoU, precisionAt20, successThresholds, successRates, auc, fps] = ...
    evaluate_tracking_results(result.predictedBboxes, sequence.groundTruth, result.frameTimes);

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

fileStem = sprintf('%s_%s_KCF', char(config.runtime.outputPrefix), sequence_name(sequence));
export_experiment_summary(result, config.project.metricsDir, fileStem);
result.outputPaths = struct( ...
    'mat', fullfile(config.project.metricsDir, [fileStem '.mat']), ...
    'summaryCsv', fullfile(config.project.metricsDir, [fileStem '_metrics.csv']));
end

function name = sequence_name(sequence)
if isfield(sequence, 'sequenceDir')
    [~, name] = fileparts(sequence.sequenceDir);
else
    name = 'Sequence';
end
end
