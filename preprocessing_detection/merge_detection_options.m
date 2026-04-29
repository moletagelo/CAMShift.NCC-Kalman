function mergedOptions = merge_detection_options(userOptions, defaultOptions)
% 合并用户参数与默认参数，缺失字段自动补齐。
% 输入:
%   userOptions    - 用户传入参数结构体
%   defaultOptions - 默认参数结构体
% 输出:
%   mergedOptions  - 合并后的参数结构体

if nargin < 1 || isempty(userOptions)
    userOptions = struct();
end

if nargin < 2 || isempty(defaultOptions)
    defaultOptions = struct();
end

mergedOptions = defaultOptions;
fieldNames = fieldnames(userOptions);
for fieldIndex = 1:numel(fieldNames)
    fieldName = fieldNames{fieldIndex};
    mergedOptions.(fieldName) = userOptions.(fieldName);
end
end
