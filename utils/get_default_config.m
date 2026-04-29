function config = get_default_config()
%GET_DEFAULT_CONFIG 构建项目默认配置，供各实验入口统一复用。
% 输入：无。
% 输出：config，包含项目、数据集、运行时、预处理、KCF 与 CAMshift 参数。

    project = bootstrap_project();

    config.project = project;

    config.dataset.rootDir = fullfile(project.root, 'data', 'otb');
    config.dataset.sequenceName = 'Football';
    config.dataset.imageExtension = '.jpg';
    config.dataset.groundTruthFile = 'groundtruth_rect.txt';
    config.dataset.frameLimit = inf;

    config.runtime.visualize = true;
    config.runtime.saveVideo = false;
    config.runtime.outputPrefix = datestr(now, 'yyyymmdd_HHMMSS');
    config.runtime.randomSeed = 42;
    config.runtime.requiredToolboxes = { ...
        'Image Processing Toolbox', ...
        'Computer Vision Toolbox' ...
    };

    config.preprocessing.grayscaleWeights = [0.2989, 0.5870, 0.1140];
    config.preprocessing.gaussianSigma = 1.2;
    config.preprocessing.gaussianKernelSize = [5, 5];
    config.preprocessing.useAdaptiveHistogramEqualization = false;
    config.preprocessing.histogramNumTiles = [8, 8];

    config.kcf.padding = 1.5;
    config.kcf.lambda = 1e-4;
    config.kcf.output_sigma_factor = 0.1;
    config.kcf.interp_factor = 0.02;
    config.kcf.sigma = 0.5;
    config.kcf.cell_size = 4;
    config.kcf.num_orientations = 9;

    config.camshift.templateUpdateAlpha = 0.05;
    config.camshift.searchRadius = 30;
    config.camshift.processNoise = diag([4, 4, 1, 1]);
    config.camshift.measurementNoise = diag([9, 9]);
    config.camshift.minConfidence = 0.1;

    config.improvedCamshift = struct();
    config.improvedCamshift.searchRadius = config.camshift.searchRadius;
    config.improvedCamshift.templateUpdateAlpha = config.camshift.templateUpdateAlpha;
    config.improvedCamshift.processNoise = config.camshift.processNoise;
    config.improvedCamshift.measurementNoise = config.camshift.measurementNoise;
    config.improvedCamshift.minDetectionConfidence = config.camshift.minConfidence;
    config.improvedCamshift.minUpdateConfidence = 0.35;
end
