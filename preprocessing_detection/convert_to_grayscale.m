function grayFrame = convert_to_grayscale(frame, weights)
% 转换输入图像为灰度图像，兼容 RGB 与灰度输入。
% 输入:
%   frame   - 输入图像，支持 MxN 或 MxNx3 数组
%   weights - RGB 加权系数，默认使用 [0.2989, 0.5870, 0.1140]
% 输出:
%   grayFrame - 灰度图像，数据类型与输入保持一致

if nargin < 2 || isempty(weights)
    weights = [0.2989, 0.5870, 0.1140];
end

validateattributes(frame, {'numeric', 'logical'}, {'nonempty'}, mfilename, 'frame', 1);
validateattributes(weights, {'numeric'}, {'vector', 'numel', 3, 'real', 'finite'}, mfilename, 'weights', 2);

if ismatrix(frame)
    grayFrame = frame;
    return;
end

if ndims(frame) ~= 3 || size(frame, 3) ~= 3
    error('convert_to_grayscale:InvalidFrameShape', ...
        'Input frame must be grayscale or RGB.');
end

workingFrame = double(frame);
grayFrame = weights(1) * workingFrame(:, :, 1) + ...
    weights(2) * workingFrame(:, :, 2) + ...
    weights(3) * workingFrame(:, :, 3);

if isa(frame, 'uint8')
    grayFrame = uint8(min(max(round(grayFrame), 0), 255));
elseif isa(frame, 'uint16')
    grayFrame = uint16(min(max(round(grayFrame), 0), intmax('uint16')));
elseif isa(frame, 'logical')
    grayFrame = grayFrame > 0.5;
else
    grayFrame = cast(grayFrame, 'like', frame);
end
end
