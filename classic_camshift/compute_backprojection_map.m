function backprojection = compute_backprojection_map(frame, histogramModel, params)
%COMPUTE_BACKPROJECTION_MAP 计算经典 CAMShift 的颜色反投影图。
    hsvFrame = rgb2hsv(local_ensure_rgb(frame));
    hue = hsvFrame(:, :, 1);
    sat = hsvFrame(:, :, 2);
    val = hsvFrame(:, :, 3);

    edges = linspace(0, 1, params.histogramBins + 1);
    binIndex = discretize(hue, edges);
    binIndex(isnan(binIndex)) = 1;

    probabilities = histogramModel(binIndex);
    validMask = sat >= params.minSaturation & val >= params.minValue;
    probabilities(~validMask) = 0;

    backprojection = imgaussfilt(single(probabilities), 1.0);
end

function frameRgb = local_ensure_rgb(frame)
    if size(frame, 3) == 1
        frameRgb = repmat(frame, 1, 1, 3);
    else
        frameRgb = frame;
    end
end
