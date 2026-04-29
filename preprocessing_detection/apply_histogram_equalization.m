function equalizedFrame = apply_histogram_equalization(frame, method, clipLimit, numTiles)
% 对输入灰度图像执行直方图均衡化，支持全局与自适应模式。
% 输入:
%   frame      - 输入图像，支持灰度或 RGB
%   method     - 'global' 或 'adaptive'，默认 'global'
%   clipLimit  - 自适应均衡化裁剪阈值，默认 0.01
%   numTiles   - 自适应均衡化分块数，默认 [8, 8]
% 输出:
%   equalizedFrame - 均衡化后的灰度图像

if nargin < 2 || isempty(method)
    method = 'global';
end

if nargin < 3 || isempty(clipLimit)
    clipLimit = 0.01;
end

if nargin < 4 || isempty(numTiles)
    numTiles = [8, 8];
end

grayFrame = convert_to_grayscale(frame);
method = lower(string(method));

switch method
    case "global"
        equalizedFrame = histeq(grayFrame);
    case "adaptive"
        equalizedFrame = adapthisteq(grayFrame, 'ClipLimit', clipLimit, 'NumTiles', numTiles);
    otherwise
        error('apply_histogram_equalization:InvalidMethod', ...
            'Supported methods are ''global'' and ''adaptive''.');
end
end
