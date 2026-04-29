function [updatedTemplate, didUpdate] = update_adaptive_template(currentTemplate, candidateTemplate, confidence, isNearBorder, params)
% 根据观测结果自适应更新灰度模板。

updatedTemplate = currentTemplate;
didUpdate = false;

if isempty(currentTemplate) || isempty(candidateTemplate)
    return;
end

if isNearBorder || confidence < params.minUpdateConfidence
    return;
end

if ~isequal(size(candidateTemplate), size(currentTemplate))
    candidateTemplate = imresize(candidateTemplate, size(currentTemplate));
end

alpha = double(params.templateUpdateAlpha);
blendedTemplate = (1 - alpha) * double(currentTemplate) + alpha * double(candidateTemplate);

if isinteger(currentTemplate)
    className = class(currentTemplate);
    maxValue = double(intmax(className));
    minValue = double(intmin(className));
    blendedTemplate = min(max(blendedTemplate, minValue), maxValue);
    updatedTemplate = cast(round(blendedTemplate), className);
else
    updatedTemplate = cast(blendedTemplate, class(currentTemplate));
end

didUpdate = true;
end
