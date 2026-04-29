function windowInfo = extract_search_window(frame, predictedCenter, templateSize, params)
% 根据预测中心提取 NCC 搜索区域。

if ndims(frame) > 2
    error('extract_search_window:InvalidFrame', 'Frame must be grayscale.');
end

frameSize = size(frame);
templateHeight = templateSize(1);
templateWidth = templateSize(2);
radius = double(params.searchRadius);

predictedCenter = double(predictedCenter(:)');
if numel(predictedCenter) ~= 2
    error('extract_search_window:InvalidCenter', 'Predicted center must contain [row, col].');
end

startRow = round(predictedCenter(1) - templateHeight / 2) - radius + 1;
startCol = round(predictedCenter(2) - templateWidth / 2) - radius + 1;
endRow = startRow + templateHeight + 2 * radius - 1;
endCol = startCol + templateWidth + 2 * radius - 1;

clampedRowStart = max(1, startRow);
clampedColStart = max(1, startCol);
clampedRowEnd = min(frameSize(1), endRow);
clampedColEnd = min(frameSize(2), endCol);

windowInfo = struct();
windowInfo.patch = frame(clampedRowStart:clampedRowEnd, clampedColStart:clampedColEnd);
windowInfo.topLeft = [clampedRowStart, clampedColStart];
windowInfo.bottomRight = [clampedRowEnd, clampedColEnd];
windowInfo.predictedCenter = predictedCenter;
windowInfo.requestedBounds = [startRow, startCol, endRow, endCol];
windowInfo.isClipped = any([clampedRowStart ~= startRow, clampedColStart ~= startCol, ...
                            clampedRowEnd ~= endRow, clampedColEnd ~= endCol]);
end
