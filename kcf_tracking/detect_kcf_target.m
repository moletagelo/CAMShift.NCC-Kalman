function detection = detect_kcf_target(tracker, features)
%DETECT_KCF_TARGET 基于当前模型估计目标在新帧中的偏移。
% 输入:
%   tracker - KCF跟踪器状态结构体。
%   features - 当前帧搜索区域特征。
% 输出:
%   detection - 检测结果结构体，包含偏移与响应图。

kernel = gaussian_correlation(features, tracker.model_x, tracker.params.sigma);
responseMap = real(ifft2(tracker.model_alphaf .* fft2(kernel)));
[peakRow, peakCol] = find(responseMap == max(responseMap(:)), 1);
peakValue = responseMap(peakRow, peakCol);

rowDelta = wrap_response_index(peakRow, size(responseMap, 1));
colDelta = wrap_response_index(peakCol, size(responseMap, 2));

rowDelta = rowDelta + subpixel_offset(responseMap(mod(peakRow - 2, size(responseMap, 1)) + 1, peakCol), ...
    responseMap(peakRow, peakCol), ...
    responseMap(mod(peakRow, size(responseMap, 1)) + 1, peakCol));
colDelta = colDelta + subpixel_offset(responseMap(peakRow, mod(peakCol - 2, size(responseMap, 2)) + 1), ...
    responseMap(peakRow, peakCol), ...
    responseMap(peakRow, mod(peakCol, size(responseMap, 2)) + 1));

detection = struct();
detection.delta_cells = [rowDelta, colDelta];
detection.delta_pixels = detection.delta_cells * tracker.params.cell_size;
detection.peakValue = peakValue;
detection.responseMap = responseMap;
detection.peakIndex = [peakRow, peakCol];
end

function delta = wrap_response_index(indexValue, dimensionSize)
%WRAP_RESPONSE_INDEX 将循环响应坐标转换为有符号位移。
% 输入:
%   indexValue - 峰值索引。
%   dimensionSize - 响应图对应维度长度。
% 输出:
%   delta - 有符号位移。

delta = double(indexValue - 1);
if delta > dimensionSize / 2
    delta = delta - dimensionSize;
end
end

function offset = subpixel_offset(leftValue, centerValue, rightValue)
%SUBPIXEL_OFFSET 使用抛物线拟合计算亚像素偏移。
% 输入:
%   leftValue - 左侧邻域响应。
%   centerValue - 中心响应。
%   rightValue - 右侧邻域响应。
% 输出:
%   offset - 范围约为[-0.5,0.5]的偏移量。

denominator = leftValue - 2 * centerValue + rightValue;
if abs(denominator) < eps('single')
    offset = 0;
else
    offset = 0.5 * (leftValue - rightValue) / denominator;
end
end
