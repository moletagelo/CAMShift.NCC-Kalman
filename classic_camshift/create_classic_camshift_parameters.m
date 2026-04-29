function params = create_classic_camshift_parameters(config)
%CREATE_CLASSIC_CAMSHIFT_PARAMETERS 构建经典 CAMShift 基线所需参数。
    params = struct();
    params.methodName = 'Classic CAMShift';
    params.histogramBins = 32;
    params.minSaturation = 0.20;
    params.minValue = 0.20;
    params.maxIterations = 10;
    params.centerTolerance = 1.0;
    params.minWindowSize = [16, 16];
    params.maxWindowScale = 2.5;
    params.sizeScaleFactor = 4.0;
    params.epsilonWeight = 1e-6;
    params.visualize = isfield(config.runtime, 'visualize') && logical(config.runtime.visualize);

    if isfield(config, 'classicCamshift') && isstruct(config.classicCamshift)
        params = local_merge_struct(params, config.classicCamshift);
    end
end

function merged = local_merge_struct(baseStruct, overrideStruct)
    merged = baseStruct;
    fieldNames = fieldnames(overrideStruct);
    for idx = 1:numel(fieldNames)
        merged.(fieldNames{idx}) = overrideStruct.(fieldNames{idx});
    end
end
