function params = create_kcf_parameters(config)
%CREATE_KCF_PARAMETERS 构建KCF跟踪器参数配置。
% 输入:
%   config - 可选项目配置结构体，可覆盖默认KCF参数。
% 输出:
%   params - KCF参数结构体。

if nargin < 1
    config = struct();
end

params.padding = 1.5;
params.lambda = 1e-4;
params.output_sigma_factor = 0.1;
params.interp_factor = 0.02;
params.sigma = 0.5;
params.cell_size = 4;
params.num_orientations = 9;
params.large_target_diagonal = 100;
params.large_target_resize_factor = 0.5;
params.use_builtin_hog = exist('extractHOGFeatures', 'file') == 2;
params.append_gray_channel = true;
params.visualization_stride = 1;
params.max_visualization_fps = 30;

if isfield(config, 'tracker') && isfield(config.tracker, 'kcf')
    params = merge_structs(params, config.tracker.kcf);
elseif isfield(config, 'kcf')
    params = merge_structs(params, config.kcf);
end
end

function merged = merge_structs(baseStruct, overrideStruct)
%MERGE_STRUCTS 合并参数结构体，后者覆盖前者同名字段。
% 输入:
%   baseStruct - 基础结构体。
%   overrideStruct - 覆盖结构体。
% 输出:
%   merged - 合并后的结构体。

merged = baseStruct;
if ~isstruct(overrideStruct)
    return;
end

fieldNames = fieldnames(overrideStruct);
for idx = 1:numel(fieldNames)
    fieldName = fieldNames{idx};
    merged.(fieldName) = overrideStruct.(fieldName);
end
end
