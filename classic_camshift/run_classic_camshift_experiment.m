function result = run_classic_camshift_experiment(config)
%RUN_CLASSIC_CAMSHIFT_EXPERIMENT 运行经典 CAMShift 基线实验。
    params = create_classic_camshift_parameters(config);
    sequence = load_otb_sequence(config);
    result = initialize_result_struct(params.methodName, sequence);

    firstFrame = imread(sequence.framePaths{1});
    initialBbox = double(sequence.groundTruth(1, :));
    tracker = initialize_classic_camshift_tracker(firstFrame, initialBbox, params);

    result.predictedBboxes(1, :) = initialBbox;
    result.centers(1, :) = bbox_to_center(initialBbox);
    result.scores(1) = NaN;
    result.frameTimes(1) = NaN;

    for frameIdx = 2:sequence.numFrames
        frame = imread(sequence.framePaths{frameIdx});
        frameStart = tic;
        [tracker, predictedBbox, score, ~] = update_classic_camshift_tracker(tracker, frame);
        result.frameTimes(frameIdx) = toc(frameStart);
        result.predictedBboxes(frameIdx, :) = predictedBbox;
        result.centers(frameIdx, :) = bbox_to_center(predictedBbox);
        result.scores(frameIdx) = score;

        if params.visualize
            frameOut = draw_tracking_frame(frame, predictedBbox, params.methodName, [255, 165, 0]);
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

    fileStem = sprintf('classic_camshift_%s', local_sequence_name(sequence));
    export_experiment_summary(result, config.project.metricsDir, fileStem);
end

function name = local_sequence_name(sequence)
    if isfield(sequence, 'sequenceDir')
        [~, name] = fileparts(sequence.sequenceDir);
    else
        name = 'sequence';
    end
end
