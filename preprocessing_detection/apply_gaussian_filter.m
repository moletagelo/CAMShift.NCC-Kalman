function filteredFrame = apply_gaussian_filter(frame, sigma, kernelSize)
% 对输入图像执行高斯滤波，支持灰度与彩色图像。
% 输入:
%   frame      - 输入图像
%   sigma      - 高斯标准差，默认 1.0
%   kernelSize - 核大小，默认根据 sigma 自适应
% 输出:
%   filteredFrame - 滤波后的图像

if nargin < 2 || isempty(sigma)
    sigma = 1.0;
end

if nargin < 3 || isempty(kernelSize)
    radius = max(1, ceil(3 * sigma));
    kernelSize = 2 * radius + 1;
end

validateattributes(frame, {'numeric', 'logical'}, {'nonempty'}, mfilename, 'frame', 1);
validateattributes(sigma, {'numeric'}, {'scalar', 'real', 'positive', 'finite'}, mfilename, 'sigma', 2);
validateattributes(kernelSize, {'numeric'}, {'real', 'finite', 'nonempty'}, mfilename, 'kernelSize', 3);

if isscalar(kernelSize)
    kernelSize = [kernelSize, kernelSize];
end

kernelSize = double(kernelSize(:)');
kernelSize = max(1, 2 * floor(kernelSize / 2) + 1);

if exist('imgaussfilt', 'file') == 2
    filteredFrame = imgaussfilt(frame, sigma, 'FilterSize', kernelSize);
else
    gaussianKernel = fspecial('gaussian', kernelSize, sigma);
    filteredFrame = imfilter(frame, gaussianKernel, 'replicate');
end
end
