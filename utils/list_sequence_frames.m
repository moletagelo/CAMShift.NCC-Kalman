function framePaths = list_sequence_frames(sequenceDir, imageExtension, frameLimit)
%LIST_SEQUENCE_FRAMES 读取并排序序列帧路径列表。
% 输入：sequenceDir，图像目录；imageExtension，图像扩展名；frameLimit，最大帧数。
% 输出：framePaths，按顺序排列的帧路径元胞数组。

    if nargin < 3 || isempty(frameLimit)
        frameLimit = inf;
    end

    if ~isfolder(sequenceDir)
        error('list_sequence_frames:MissingDirectory', ...
            'Sequence image directory does not exist: %s', sequenceDir);
    end

    if startsWith(char(imageExtension), '.')
        pattern = ['*', char(imageExtension)];
    else
        pattern = ['*.', char(imageExtension)];
    end

    fileInfo = dir(fullfile(sequenceDir, pattern));
    if isempty(fileInfo)
        error('list_sequence_frames:NoFramesFound', ...
            'No frames matching "%s" found in %s', pattern, sequenceDir);
    end

    fileNames = natsortfiles({fileInfo.name});
    framePaths = fullfile(sequenceDir, fileNames(:));

    if ~isinf(frameLimit)
        framePaths = framePaths(1:min(numel(framePaths), frameLimit));
    end
end

function sortedNames = natsortfiles(fileNames)
    tokens = regexp(fileNames, '\d+', 'match', 'once');
    numericIds = nan(size(fileNames));

    for idx = 1:numel(fileNames)
        if ~isempty(tokens{idx})
            numericIds(idx) = str2double(tokens{idx});
        end
    end

    tableData = table(fileNames(:), numericIds(:), 'VariableNames', {'Name', 'NumericId'});
    tableData.FallbackName = lower(string(tableData.Name));
    tableData = sortrows(tableData, {'NumericId', 'FallbackName'});
    sortedNames = cellstr(tableData.Name);
end
