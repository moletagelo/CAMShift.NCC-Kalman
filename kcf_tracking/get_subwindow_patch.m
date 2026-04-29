function patch = get_subwindow_patch(imageData, center, sizeHW)
%GET_SUBWINDOW_PATCH 提取带边界复制的子窗口图像块。
% 输入:
%   imageData - 输入图像，可为灰度或彩色。
%   center - 子窗口中心 [row, col]。
%   sizeHW - 子窗口尺寸 [height, width]。
% 输出:
%   patch - 提取后的图像块。

sizeHW = max([1, 1], round(double(sizeHW)));
center = double(center);

rowIndices = floor(center(1)) + ((1:sizeHW(1)) - ceil(sizeHW(1) / 2));
colIndices = floor(center(2)) + ((1:sizeHW(2)) - ceil(sizeHW(2) / 2));

rowIndices = min(max(rowIndices, 1), size(imageData, 1));
colIndices = min(max(colIndices, 1), size(imageData, 2));

patch = imageData(rowIndices, colIndices, :);
end
