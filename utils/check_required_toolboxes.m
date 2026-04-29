function tf = check_required_toolboxes(toolboxNames)
%CHECK_REQUIRED_TOOLBOXES 检查所需工具箱是否已安装。
% 输入：toolboxNames，字符串或元胞数组形式的工具箱名称。
% 输出：tf，逻辑值，表示所有工具箱是否齐全。

    if ischar(toolboxNames) || isstring(toolboxNames)
        toolboxNames = cellstr(toolboxNames);
    end

    installed = ver();
    installedNames = {installed.Name};
    missing = {};

    for idx = 1:numel(toolboxNames)
        if ~any(strcmp(installedNames, toolboxNames{idx}))
            missing{end + 1} = toolboxNames{idx}; %#ok<AGROW>
        end
    end

    tf = isempty(missing);
    if ~tf
        warning('check_required_toolboxes:MissingToolboxes', ...
            'Missing MATLAB toolboxes: %s', strjoin(missing, ', '));
    end
end
