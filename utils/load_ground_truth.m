function gt = load_ground_truth(gtFile)
%LOAD_GROUND_TRUTH 读取 OTB 风格标注文件并返回矩形框矩阵。
% 输入：gtFile，标注文件路径。
% 输出：gt，N×4 的 [x, y, width, height] 矩阵。

    if ~isfile(gtFile)
        error('load_ground_truth:MissingFile', ...
            'Ground-truth file does not exist: %s', gtFile);
    end

    rawText = fileread(gtFile);
    rawText = strrep(rawText, sprintf('\r\n'), sprintf('\n'));
    rawText = strrep(rawText, sprintf('\r'), sprintf('\n'));
    rawText = strrep(rawText, ',', ' ');
    rawText = strrep(rawText, sprintf('\t'), ' ');

    numericValues = sscanf(rawText, '%f');
    if mod(numel(numericValues), 4) ~= 0
        error('load_ground_truth:InvalidFormat', ...
            'Ground-truth file must contain rectangles with four values per row.');
    end

    gt = reshape(numericValues, 4, []).';
end
