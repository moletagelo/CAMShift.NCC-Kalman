function params = create_improved_camshift_parameters(config)
% 创建改进 CAMshift 跟踪器的默认参数配置。

if nargin < 1
    config = struct();
end

params = struct();
params.methodName = 'Improved CAMshift';
params.searchRadius = 30;
params.templateUpdateAlpha = 0.05;
params.minUpdateConfidence = 0.35;
params.minDetectionConfidence = 0.10;
params.dt = 1.0;
params.transitionMatrix = [1, 0, 1, 0; ...
                           0, 1, 0, 1; ...
                           0, 0, 1, 0; ...
                           0, 0, 0, 1];
params.observationMatrix = [1, 0, 0, 0; ...
                            0, 1, 0, 0];
params.processNoise = diag([25, 25, 9, 9]);
params.measurementNoise = diag([16, 16]);
params.initialCovariance = diag([25, 25, 16, 16]);
params.visualizationPause = 0.001;

if isfield(config, 'improvedCamshift') && isstruct(config.improvedCamshift)
    params = local_merge_struct(params, config.improvedCamshift);
end
end

function merged = local_merge_struct(baseStruct, overrideStruct)
% 合并用户覆盖参数，保留默认字段。

merged = baseStruct;
fieldNames = fieldnames(overrideStruct);
for idx = 1:numel(fieldNames)
    merged.(fieldNames{idx}) = overrideStruct.(fieldNames{idx});
end
end
