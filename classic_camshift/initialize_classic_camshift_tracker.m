function tracker = initialize_classic_camshift_tracker(firstFrame, initialBbox, params)
%INITIALIZE_CLASSIC_CAMSHIFT_TRACKER 初始化经典 CAMShift 跟踪器状态。
    hsvFrame = rgb2hsv(local_ensure_rgb(firstFrame));
    tracker = struct();
    tracker.params = params;
    tracker.bbox = double(initialBbox);
    tracker.templateHistogram = build_roi_histogram(hsvFrame, tracker.bbox, params);
end

function histogram = build_roi_histogram(hsvFrame, bbox, params)
    patch = crop_bbox_patch(hsvFrame, bbox);
    hue = patch(:, :, 1);
    sat = patch(:, :, 2);
    val = patch(:, :, 3);
    validMask = sat >= params.minSaturation & val >= params.minValue;
    if ~any(validMask(:))
        validMask = true(size(hue));
    end

    edges = linspace(0, 1, params.histogramBins + 1);
    histogram = histcounts(hue(validMask), edges, 'Normalization', 'probability');
    histogram = histogram(:);
    histogram = histogram / max(sum(histogram), eps);
end

function patch = crop_bbox_patch(imageData, bbox)
    x1 = max(1, floor(bbox(1)));
    y1 = max(1, floor(bbox(2)));
    x2 = min(size(imageData, 2), ceil(bbox(1) + bbox(3) - 1));
    y2 = min(size(imageData, 1), ceil(bbox(2) + bbox(4) - 1));
    patch = imageData(y1:y2, x1:x2, :);
end

function frameRgb = local_ensure_rgb(frame)
    if size(frame, 3) == 1
        frameRgb = repmat(frame, 1, 1, 3);
    else
        frameRgb = frame;
    end
end
