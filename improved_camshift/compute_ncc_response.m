function response = compute_ncc_response(searchPatch, template)
% 计算搜索区域与模板之间的归一化互相关响应。

response = struct('responseMap', [], ...
                  'bestScore', -Inf, ...
                  'bestLocation', [], ...
                  'isValid', false);

if isempty(searchPatch) || isempty(template)
    return;
end

searchPatch = double(searchPatch);
template = double(template);

[patchHeight, patchWidth] = size(searchPatch);
[templateHeight, templateWidth] = size(template);

if templateHeight > patchHeight || templateWidth > patchWidth
    return;
end

if std(template(:)) < eps
    return;
end

fullResponse = normxcorr2(template, searchPatch);
validRows = templateHeight:patchHeight;
validCols = templateWidth:patchWidth;
validResponse = fullResponse(validRows, validCols);
validResponse(~isfinite(validResponse)) = -Inf;

[bestScore, linearIndex] = max(validResponse(:));
if ~isfinite(bestScore)
    return;
end

[bestRow, bestCol] = ind2sub(size(validResponse), linearIndex);

response.responseMap = validResponse;
response.bestScore = bestScore;
response.bestLocation = [bestRow, bestCol];
response.isValid = true;
end
