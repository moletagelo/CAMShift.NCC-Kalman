function project = bootstrap_project()
%BOOTSTRAP_PROJECT 初始化项目路径并返回常用目录结构。
% 输入：无。
% 输出：project，包含根目录、结果目录及其子目录路径。

    currentFile = mfilename('fullpath');
    project.root = fileparts(fileparts(currentFile));

    pathList = {
        project.root
        fullfile(project.root, 'utils')
        fullfile(project.root, 'preprocessing_detection')
        fullfile(project.root, 'classic_camshift')
        fullfile(project.root, 'kcf_tracking')
        fullfile(project.root, 'improved_camshift')
        fullfile(project.root, 'experiments_visualization')
    };

    currentPath = [pathsep, path, pathsep];
    for idx = 1:numel(pathList)
        if ~contains(currentPath, [pathsep, pathList{idx}, pathsep])
            addpath(pathList{idx});
        end
    end

    project.resultsDir = fullfile(project.root, 'results');
    project.results = project.resultsDir;
    project.figuresDir = fullfile(project.resultsDir, 'figures');
    project.metricsDir = fullfile(project.resultsDir, 'metrics');
    project.logsDir = fullfile(project.resultsDir, 'logs');
    project.videosDir = fullfile(project.resultsDir, 'videos');

    ensure_dir(project.resultsDir);
    ensure_dir(project.figuresDir);
    ensure_dir(project.metricsDir);
    ensure_dir(project.logsDir);
    ensure_dir(project.videosDir);
end
