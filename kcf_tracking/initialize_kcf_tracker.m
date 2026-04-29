function tracker = initialize_kcf_tracker(frame, initialBBox, params)
%INITIALIZE_KCF_TRACKER 根据首帧和初始框初始化KCF跟踪状态。
% 输入:
%   frame - 首帧图像。
%   initialBBox - 初始目标框 [x, y, width, height]。
%   params - KCF参数结构体。
% 输出:
%   tracker - KCF跟踪器状态结构体。

if nargin < 3 || isempty(params)
    params = create_kcf_parameters();
end

frameGray = ensure_grayscale_single(frame);
baseTargetSize = max([1, 1], double([initialBBox(4), initialBBox(3)]));
baseCenter = [initialBBox(2) + initialBBox(4) / 2, initialBBox(1) + initialBBox(3) / 2];

scaleFactor = choose_scale_factor(baseTargetSize, params);
workingFrame = resize_if_needed(frameGray, scaleFactor);

targetSize = max([1, 1], round(baseTargetSize * scaleFactor));
windowSize = max([params.cell_size * 2, params.cell_size * 2], round(targetSize * (1 + params.padding)));
windowSize = max([params.cell_size, params.cell_size], floor(windowSize ./ params.cell_size) .* params.cell_size);
windowSize = max(windowSize, [params.cell_size, params.cell_size]);

labelSize = max([1, 1], floor(windowSize ./ params.cell_size));
outputSigma = sqrt(prod(targetSize)) / params.cell_size * params.output_sigma_factor;
yf = fft2(gaussian_shaped_labels(outputSigma, labelSize));
cosWindow = create_cosine_window(labelSize);

position = baseCenter * scaleFactor;
patch = get_subwindow_patch(workingFrame, position, windowSize);
features = extract_kcf_features(patch, params, cosWindow);
model = train_kcf_model(features, yf, params.lambda, params.sigma);

tracker = struct();
tracker.params = params;
tracker.position = position;
tracker.target_size = targetSize;
tracker.base_target_size = baseTargetSize;
tracker.window_size = windowSize;
tracker.scale_factor = scaleFactor;
tracker.yf = yf;
tracker.cos_window = cosWindow;
tracker.model_x = model.x;
tracker.model_xf = model.xf;
tracker.model_alphaf = model.alphaf;
tracker.last_bbox = double(initialBBox);
tracker.last_peak_value = NaN;
tracker.feature_size = size(features);
tracker.frame_size = size(frameGray);
end

function scaleFactor = choose_scale_factor(targetSize, params)
%CHOOSE_SCALE_FACTOR 根据目标大小选择是否降采样。
% 输入:
%   targetSize - 目标尺寸 [height, width]。
%   params - KCF参数结构体。
% 输出:
%   scaleFactor - 工作尺度因子。

diagonalLength = hypot(targetSize(1), targetSize(2));
if diagonalLength > params.large_target_diagonal
    scaleFactor = params.large_target_resize_factor;
else
    scaleFactor = 1.0;
end
end

function frameGray = ensure_grayscale_single(frame)
%ENSURE_GRAYSCALE_SINGLE 将输入图像统一转换为single灰度图。
% 输入:
%   frame - 原始图像。
% 输出:
%   frameGray - 范围为[0,1]的single灰度图。

if ndims(frame) == 3
    frameGray = rgb2gray(frame);
else
    frameGray = frame;
end

frameGray = im2single(frameGray);
end

function resizedFrame = resize_if_needed(frameGray, scaleFactor)
%RESIZE_IF_NEEDED 根据尺度因子缩放图像。
% 输入:
%   frameGray - 灰度图像。
%   scaleFactor - 缩放因子。
% 输出:
%   resizedFrame - 缩放后的图像。

if abs(scaleFactor - 1.0) < eps
    resizedFrame = frameGray;
else
    resizedFrame = imresize(frameGray, scaleFactor, 'bilinear');
end
end

function labels = gaussian_shaped_labels(sigma, labelSize)
%GAUSSIAN_SHAPED_LABELS 生成高斯形状的训练标签。
% 输入:
%   sigma - 标签高斯标准差。
%   labelSize - 标签尺寸 [rows, cols]。
% 输出:
%   labels - 二维高斯标签。

[rs, cs] = ndgrid(1:labelSize(1), 1:labelSize(2));
rs = rs - floor(labelSize(1) / 2) - 1;
cs = cs - floor(labelSize(2) / 2) - 1;
labels = exp(-0.5 / max(eps, sigma ^ 2) * (rs .^ 2 + cs .^ 2));
labels = circshift(labels, -floor(labelSize / 2));
labels = single(labels);
end

function window = create_cosine_window(labelSize)
%CREATE_COSINE_WINDOW 创建KCF所需二维余弦窗。
% 输入:
%   labelSize - 窗口尺寸 [rows, cols]。
% 输出:
%   window - 二维余弦窗。

rowWindow = local_hann(labelSize(1));
colWindow = local_hann(labelSize(2));
window = single(rowWindow * colWindow');
end

function values = local_hann(lengthValue)
%LOCAL_HANN 兼容不同MATLAB版本的Hann窗生成函数。
% 输入:
%   lengthValue - 窗口长度。
% 输出:
%   values - 列向量窗函数。

if exist('hann', 'file') == 2
    values = hann(lengthValue, 'periodic');
elseif exist('hanning', 'file') == 2
    values = hanning(lengthValue, 'periodic');
else
    index = (0:lengthValue - 1)';
    values = 0.5 - 0.5 * cos(2 * pi * index / max(1, lengthValue));
end
end
