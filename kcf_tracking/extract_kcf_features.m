function features = extract_kcf_features(patch, params, cosineWindow)
%EXTRACT_KCF_FEATURES 提取KCF所需特征并施加余弦窗。
% 输入:
%   patch - 输入图像块。
%   params - KCF参数结构体。
%   cosineWindow - 特征空间二维余弦窗。
% 输出:
%   features - 特征张量 [rows, cols, channels]。

if nargin < 3
    cosineWindow = [];
end

grayPatch = ensure_grayscale_single(patch);
cellSize = params.cell_size;
featureRows = max(1, floor(size(grayPatch, 1) / cellSize));
featureCols = max(1, floor(size(grayPatch, 2) / cellSize));
trimmedPatch = grayPatch(1:featureRows * cellSize, 1:featureCols * cellSize);

featureTensor = [];
if isfield(params, 'use_builtin_hog') && params.use_builtin_hog && exist('extractHOGFeatures', 'file') == 2
    featureTensor = try_extract_builtin_hog(trimmedPatch, featureRows, featureCols, params);
end

if isempty(featureTensor)
    featureTensor = extract_gradient_histogram_features(trimmedPatch, featureRows, featureCols, params);
end

if isfield(params, 'append_gray_channel') && params.append_gray_channel
    grayFeature = imresize(trimmedPatch, [featureRows, featureCols], 'bilinear');
    grayFeature = single(grayFeature);
    grayFeature = grayFeature - mean(grayFeature(:));
    grayFeature = grayFeature ./ max(eps('single'), std(grayFeature(:)) + eps('single'));
    featureTensor = cat(3, featureTensor, grayFeature);
end

if ~isempty(cosineWindow)
    if ~isequal(size(cosineWindow), [featureRows, featureCols])
        cosineWindow = imresize(cosineWindow, [featureRows, featureCols], 'bilinear');
    end
    featureTensor = featureTensor .* cosineWindow;
end

features = single(featureTensor);
end

function grayPatch = ensure_grayscale_single(patch)
%ENSURE_GRAYSCALE_SINGLE 将图像块转换为single灰度图。
% 输入:
%   patch - 输入图像块。
% 输出:
%   grayPatch - 灰度single图像。

if ndims(patch) == 3
    grayPatch = rgb2gray(patch);
else
    grayPatch = patch;
end

grayPatch = im2single(grayPatch);
end

function featureTensor = try_extract_builtin_hog(patch, featureRows, featureCols, params)
%TRY_EXTRACT_BUILTIN_HOG 优先使用MATLAB内置HOG提取。
% 输入:
%   patch - 灰度图像块。
%   featureRows - 目标特征行数。
%   featureCols - 目标特征列数。
%   params - KCF参数结构体。
% 输出:
%   featureTensor - HOG特征张量，失败时返回空。

featureTensor = [];
try
    hogVector = extractHOGFeatures(patch, ...
        'CellSize', [params.cell_size, params.cell_size], ...
        'BlockSize', [1, 1], ...
        'NumBins', params.num_orientations, ...
        'UseSignedOrientation', false);

    expectedLength = featureRows * featureCols * params.num_orientations;
    if numel(hogVector) ~= expectedLength
        return;
    end

    featureTensor = reshape(single(hogVector), [params.num_orientations, featureCols, featureRows]);
    featureTensor = permute(featureTensor, [3, 2, 1]);
catch
    featureTensor = [];
end
end

function featureTensor = extract_gradient_histogram_features(patch, featureRows, featureCols, params)
%EXTRACT_GRADIENT_HISTOGRAM_FEATURES 提取梯度方向直方图特征。
% 输入:
%   patch - 灰度图像块。
%   featureRows - 特征行数。
%   featureCols - 特征列数。
%   params - KCF参数结构体。
% 输出:
%   featureTensor - 手工HOG样式特征张量。

[gradX, gradY] = compute_gradients(patch);
gradMagnitude = hypot(gradX, gradY);
gradOrientation = atan2d(gradY, gradX);
gradOrientation(gradOrientation < 0) = gradOrientation(gradOrientation < 0) + 180;
gradOrientation(gradOrientation >= 180) = gradOrientation(gradOrientation >= 180) - 180;

binEdges = linspace(0, 180, params.num_orientations + 1);
featureTensor = zeros(featureRows, featureCols, params.num_orientations, 'single');

for rowIdx = 1:featureRows
    rowRange = (rowIdx - 1) * params.cell_size + (1:params.cell_size);
    for colIdx = 1:featureCols
        colRange = (colIdx - 1) * params.cell_size + (1:params.cell_size);
        cellMagnitudes = gradMagnitude(rowRange, colRange);
        cellOrientations = gradOrientation(rowRange, colRange);
        orientationValues = cellOrientations(:);
        orientationValues(orientationValues >= 180) = 179.999;
        binIndices = discretize(orientationValues, binEdges);
        binIndices(isnan(binIndices)) = params.num_orientations;
        cellHist = accumarray(binIndices, cellMagnitudes(:), [params.num_orientations, 1], @sum, 0);
        cellHist = cellHist ./ max(norm(cellHist) + eps('single'), eps('single'));
        featureTensor(rowIdx, colIdx, :) = single(cellHist);
    end
end
end

function [gradX, gradY] = compute_gradients(patch)
%COMPUTE_GRADIENTS 计算图像梯度，优先使用内置梯度算子。
% 输入:
%   patch - 灰度图像块。
% 输出:
%   gradX - 水平方向梯度。
%   gradY - 垂直方向梯度。

if exist('imgradientxy', 'file') == 2
    [gradX, gradY] = imgradientxy(patch, 'sobel');
else
    sobelX = single([1 0 -1; 2 0 -2; 1 0 -1]) / 8;
    sobelY = sobelX';
    gradX = conv2(patch, sobelX, 'same');
    gradY = conv2(patch, sobelY, 'same');
end
end
