function frameOut = draw_tracking_frame(frame, bbox, label, color)
%DRAW_TRACKING_FRAME 在图像帧上绘制跟踪框和标签。
% 输入：frame，原始图像；bbox，1×4 跟踪框；label，显示文字；color，RGB 颜色。
% 输出：frameOut，绘制后的 RGB 图像。

    if nargin < 3 || isempty(label)
        label = '';
    end
    if nargin < 4 || isempty(color)
        color = [255, 0, 0];
    end

    validateattributes(bbox, {'numeric'}, {'vector', 'numel', 4}, mfilename, 'bbox');

    if ndims(frame) == 2
        frameOut = repmat(frame, 1, 1, 3);
    else
        frameOut = frame;
    end

    if ~isa(frameOut, 'uint8')
        frameOut = im2uint8(mat2gray(frameOut));
    end

    frameOut = insertShape(frameOut, 'Rectangle', bbox, ...
        'Color', color, 'LineWidth', 3);

    if strlength(string(label)) > 0
        textPosition = [bbox(1), max(1, bbox(2) - 18)];
        frameOut = insertText(frameOut, textPosition, char(label), ...
            'BoxOpacity', 0.6, 'TextColor', 'white', 'BoxColor', color, ...
            'FontSize', 16);
    end
end
