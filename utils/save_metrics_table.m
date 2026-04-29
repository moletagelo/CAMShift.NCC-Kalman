function save_metrics_table(tableStruct, outputFile)
%SAVE_METRICS_TABLE 将指标结构体保存为单行 CSV 表格。
% 输入：tableStruct，标量结构体或 table；outputFile，CSV 输出路径。
% 输出：无。

    if istable(tableStruct)
        dataTable = tableStruct;
    elseif isstruct(tableStruct) && isscalar(tableStruct)
        flatStruct = flatten_struct(tableStruct);
        dataTable = struct2table(flatStruct, 'AsArray', true);
    else
        error('save_metrics_table:InvalidInput', ...
            'tableStruct must be a scalar struct or a table.');
    end

    outputDir = fileparts(outputFile);
    if strlength(string(outputDir)) > 0
        ensure_dir(outputDir);
    end

    writetable(dataTable, outputFile);
end

function flatStruct = flatten_struct(inputStruct)
    flatStruct = struct();
    fieldNames = fieldnames(inputStruct);

    for idx = 1:numel(fieldNames)
        fieldName = fieldNames{idx};
        value = inputStruct.(fieldName);

        if isstruct(value) && isscalar(value)
            nestedStruct = flatten_struct(value);
            nestedFields = fieldnames(nestedStruct);
            for nestedIdx = 1:numel(nestedFields)
                nestedName = nestedFields{nestedIdx};
                flatStruct.([fieldName, '_', nestedName]) = nestedStruct.(nestedName);
            end
        else
            flatStruct.(fieldName) = serialize_value(value);
        end
    end
end

function valueOut = serialize_value(valueIn)
    if isnumeric(valueIn) || islogical(valueIn)
        if isscalar(valueIn)
            valueOut = valueIn;
        else
            valueOut = strjoin(compose('%.6g', valueIn(:).'), '|');
        end
    elseif isstring(valueIn)
        valueOut = strjoin(cellstr(valueIn(:).'), '|');
    elseif ischar(valueIn)
        valueOut = valueIn;
    elseif iscellstr(valueIn)
        valueOut = strjoin(valueIn(:).', '|');
    else
        valueOut = string(class(valueIn));
    end
end
