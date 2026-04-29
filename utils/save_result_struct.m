function save_result_struct(resultStruct, outputFile)
%SAVE_RESULT_STRUCT 将结果结构体保存为 MAT 文件。
% 输入：resultStruct，任意标量结构体；outputFile，MAT 输出路径。
% 输出：无。

    outputDir = fileparts(outputFile);
    if strlength(string(outputDir)) > 0
        ensure_dir(outputDir);
    end

    save(outputFile, 'resultStruct', '-v7');
end
