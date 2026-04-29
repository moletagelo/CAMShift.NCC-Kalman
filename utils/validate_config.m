function validate_config(config)
%VALIDATE_CONFIG 检查配置字段完整性并验证关键目录参数。
% 输入：config，项目统一配置结构体。
% 输出：无；若关键字段缺失则抛出错误。

    requiredTopLevel = {'project', 'dataset', 'runtime', 'preprocessing', 'kcf', 'camshift'};
    for idx = 1:numel(requiredTopLevel)
        fieldName = requiredTopLevel{idx};
        if ~isfield(config, fieldName)
            error('validate_config:MissingField', ...
                'Config is missing required field "%s".', fieldName);
        end
    end

    if ~isfolder(config.project.root)
        error('validate_config:InvalidRoot', ...
            'Project root does not exist: %s', config.project.root);
    end

    ensure_dir(config.project.resultsDir);
    ensure_dir(config.project.figuresDir);
    ensure_dir(config.project.metricsDir);
    ensure_dir(config.project.logsDir);
    ensure_dir(config.project.videosDir);
    ensure_dir(config.dataset.rootDir);

    if ~ischar(config.dataset.sequenceName) && ~isstring(config.dataset.sequenceName)
        error('validate_config:InvalidSequenceName', ...
            'config.dataset.sequenceName must be text.');
    end

    if ~ischar(config.dataset.imageExtension) && ~isstring(config.dataset.imageExtension)
        error('validate_config:InvalidImageExtension', ...
            'config.dataset.imageExtension must be text.');
    end

    if ~(isscalar(config.dataset.frameLimit) && ...
            (isinf(config.dataset.frameLimit) || config.dataset.frameLimit > 0))
        error('validate_config:InvalidFrameLimit', ...
            'config.dataset.frameLimit must be Inf or a positive scalar.');
    end

    if isfield(config.runtime, 'requiredToolboxes') && ~isempty(config.runtime.requiredToolboxes)
        check_required_toolboxes(config.runtime.requiredToolboxes);
    end

    sequenceDir = fullfile(config.dataset.rootDir, config.dataset.sequenceName);
    if ~isfolder(sequenceDir)
        warning('validate_config:MissingSequenceDir', ...
            'Default sequence directory is missing: %s', sequenceDir);
    end
end
