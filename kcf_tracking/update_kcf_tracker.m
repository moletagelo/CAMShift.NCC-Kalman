function [tracker, prediction, diagnostics] = update_kcf_tracker(tracker, frame)
%UPDATE_KCF_TRACKER 在新帧上执行KCF检测与模型更新。
% 输入:
%   tracker - 上一帧KCF跟踪器状态。
%   frame - 当前帧图像。
% 输出:
%   tracker - 更新后的跟踪器状态。
%   prediction - 当前帧预测框 [x, y, width, height]。
%   diagnostics - 响应峰值等诊断信息。

frameGray = ensure_grayscale_single(frame);
workingFrame = resize_if_needed(frameGray, tracker.scale_factor);

searchPatch = get_subwindow_patch(workingFrame, tracker.position, tracker.window_size);
searchFeatures = extract_kcf_features(searchPatch, tracker.params, tracker.cos_window);
detection = detect_kcf_target(tracker, searchFeatures);

tracker.position = tracker.position + detection.delta_pixels;
prediction = position_to_bbox(tracker.position, tracker.base_target_size, tracker.scale_factor);
prediction = apply_clamp_bbox(prediction, size(frameGray));
tracker.position = bbox_to_position(prediction) * tracker.scale_factor;

modelPatch = get_subwindow_patch(workingFrame, tracker.position, tracker.window_size);
modelFeatures = extract_kcf_features(modelPatch, tracker.params, tracker.cos_window);
newModel = train_kcf_model(modelFeatures, tracker.yf, tracker.params.lambda, tracker.params.sigma);

interpFactor = tracker.params.interp_factor;
tracker.model_alphaf = (1 - interpFactor) * tracker.model_alphaf + interpFactor * newModel.alphaf;
tracker.model_x = (1 - interpFactor) * tracker.model_x + interpFactor * newModel.x;
tracker.model_xf = (1 - interpFactor) * tracker.model_xf + interpFactor * newModel.xf;
tracker.last_bbox = prediction;
tracker.last_peak_value = detection.peakValue;
tracker.frame_size = size(frameGray);

diagnostics = detection;
diagnostics.prediction = prediction;
end

function frameGray = ensure_grayscale_single(frame)
%ENSURE_GRAYSCALE_SINGLE 将图像转换为single灰度形式。
% 输入:
%   frame - 原始图像。
% 输出:
%   frameGray - single灰度图。

if ndims(frame) == 3
    frameGray = rgb2gray(frame);
else
    frameGray = frame;
end

frameGray = im2single(frameGray);
end

function resizedFrame = resize_if_needed(frameGray, scaleFactor)
%RESIZE_IF_NEEDED 在大目标模式下对图像降采样。
% 输入:
%   frameGray - 灰度图像。
%   scaleFactor - 当前工作尺度。
% 输出:
%   resizedFrame - 工作尺度图像。

if abs(scaleFactor - 1.0) < eps
    resizedFrame = frameGray;
else
    resizedFrame = imresize(frameGray, scaleFactor, 'bilinear');
end
end

function bbox = position_to_bbox(position, baseTargetSize, scaleFactor)
%POSITION_TO_BBOX 将中心位置转换为原始尺度目标框。
% 输入:
%   position - 工作尺度中心 [row, col]。
%   baseTargetSize - 原始尺度目标尺寸 [height, width]。
%   scaleFactor - 工作尺度因子。
% 输出:
%   bbox - 原始尺度目标框 [x, y, width, height]。

center = position ./ scaleFactor;
bbox = [center(2) - baseTargetSize(2) / 2, center(1) - baseTargetSize(1) / 2, ...
    baseTargetSize(2), baseTargetSize(1)];
bbox = double(bbox);
end

function center = bbox_to_position(bbox)
%BBOX_TO_POSITION 将目标框转换为中心点 [row, col]。
% 输入:
%   bbox - 目标框 [x, y, width, height]。
% 输出:
%   center - 中心点 [row, col]。

if exist('bbox_to_center', 'file') == 2
    externalCenter = bbox_to_center(bbox);
    if numel(externalCenter) == 2
        center = [externalCenter(2), externalCenter(1)];
        return;
    end
end

center = [bbox(2) + bbox(4) / 2, bbox(1) + bbox(3) / 2];
end

function bbox = apply_clamp_bbox(bbox, imageSize)
%APPLY_CLAMP_BBOX 优先调用共享边界裁剪函数，否则使用本地实现。
% 输入:
%   bbox - 待裁剪目标框。
%   imageSize - 图像尺寸。
% 输出:
%   bbox - 裁剪后的目标框。

if exist('clamp_bbox', 'file') == 2
    try
        bbox = clamp_bbox(bbox, imageSize);
        return;
    catch
    end
end

bbox(1) = max(1, min(bbox(1), imageSize(2)));
bbox(2) = max(1, min(bbox(2), imageSize(1)));
bbox(3) = max(1, min(bbox(3), imageSize(2) - bbox(1) + 1));
bbox(4) = max(1, min(bbox(4), imageSize(1) - bbox(2) + 1));
bbox = double(bbox);
end
