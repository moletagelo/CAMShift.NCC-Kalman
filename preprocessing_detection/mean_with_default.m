function meanValue = mean_with_default(values, defaultValue)
% 计算均值，输入为空时返回指定默认值。
% 输入:
%   values       - 数值向量
%   defaultValue - 默认返回值
% 输出:
%   meanValue    - 均值或默认值

if isempty(values)
    meanValue = defaultValue;
else
    meanValue = mean(values);
end
end
