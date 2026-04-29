function ensure_dir(pathStr)
%ENSURE_DIR 确保目标目录存在，不存在时自动创建。
% 输入：pathStr，目录路径字符串。
% 输出：无。

    if ~(ischar(pathStr) || isstring(pathStr))
        error('ensure_dir:InvalidPath', 'Directory path must be text.');
    end

    if strlength(string(pathStr)) == 0
        error('ensure_dir:EmptyPath', 'Directory path must not be empty.');
    end

    if ~isfolder(pathStr)
        mkdir(pathStr);
    end
end
