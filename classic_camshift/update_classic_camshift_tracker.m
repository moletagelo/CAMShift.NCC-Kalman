function [tracker, predictedBbox, score, diagnostics] = update_classic_camshift_tracker(tracker, frame)
%UPDATE_CLASSIC_CAMSHIFT_TRACKER 执行一帧经典 CAMShift 更新。
    backprojection = compute_backprojection_map(frame, tracker.templateHistogram, tracker.params);
    currentBbox = tracker.bbox;
    imageSize = size(backprojection);
    covarianceXY = eye(2);
    massValue = 0;

    for iter = 1:tracker.params.maxIterations
        [newCenterXY, covarianceXY, massValue] = weighted_window_stats(backprojection, currentBbox, tracker.params);
        oldCenterXY = bbox_to_center(currentBbox);
        centerShift = norm(newCenterXY - oldCenterXY);

        updatedSizeHW = estimate_window_size(covarianceXY, [currentBbox(4), currentBbox(3)], imageSize, tracker.params);
        currentBbox = center_to_bbox(newCenterXY, updatedSizeHW);
        currentBbox = clamp_bbox(currentBbox, imageSize);

        if centerShift <= tracker.params.centerTolerance
            break;
        end
    end

    tracker.bbox = currentBbox;
    predictedBbox = currentBbox;
    score = massValue;
    diagnostics = struct('mass', massValue, 'covarianceXY', covarianceXY);
end

function [centerXY, covarianceXY, massValue] = weighted_window_stats(backprojection, bbox, params)
    x1 = max(1, floor(bbox(1)));
    y1 = max(1, floor(bbox(2)));
    x2 = min(size(backprojection, 2), ceil(bbox(1) + bbox(3) - 1));
    y2 = min(size(backprojection, 1), ceil(bbox(2) + bbox(4) - 1));
    patch = double(backprojection(y1:y2, x1:x2));

    [gridX, gridY] = meshgrid(x1:x2, y1:y2);
    massValue = sum(patch(:));

    if massValue <= params.epsilonWeight
        centerXY = bbox_to_center(bbox);
        covarianceXY = diag([max(bbox(3), 1)^2, max(bbox(4), 1)^2] / 16);
        return;
    end

    normWeights = patch / massValue;
    centerX = sum(sum(normWeights .* gridX));
    centerY = sum(sum(normWeights .* gridY));
    dx = gridX - centerX;
    dy = gridY - centerY;
    covXX = sum(sum(normWeights .* (dx .^ 2)));
    covYY = sum(sum(normWeights .* (dy .^ 2)));
    covarianceXY = [covXX, 0; 0, covYY];
    centerXY = [centerX, centerY];
end

function windowSizeHW = estimate_window_size(covarianceXY, fallbackSizeHW, imageSize, params)
    sigmaX = sqrt(max(covarianceXY(1, 1), 1));
    sigmaY = sqrt(max(covarianceXY(2, 2), 1));
    width = max(params.minWindowSize(2), params.sizeScaleFactor * sigmaX);
    height = max(params.minWindowSize(1), params.sizeScaleFactor * sigmaY);

    width = min(width, params.maxWindowScale * fallbackSizeHW(2));
    height = min(height, params.maxWindowScale * fallbackSizeHW(1));
    width = min(width, imageSize(2));
    height = min(height, imageSize(1));
    windowSizeHW = [height, width];
end
