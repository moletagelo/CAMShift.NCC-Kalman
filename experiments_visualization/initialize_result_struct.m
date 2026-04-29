function resultStruct = initialize_result_struct(methodName, sequence)
%INITIALIZE_RESULT_STRUCT 创建统一的跟踪结果结构体骨架。
% 输入：methodName，算法名称；sequence，序列信息结构体。
% 输出：resultStruct，预分配预测框、中心点、分数和耗时字段。

    numFrames = sequence.numFrames;
    resultStruct.methodName = char(string(methodName));
    resultStruct.sequenceName = extract_sequence_name(sequence.sequenceDir);
    resultStruct.sequence = sequence;
    resultStruct.predictedBboxes = nan(numFrames, 4);
    resultStruct.centers = nan(numFrames, 2);
    resultStruct.scores = nan(numFrames, 1);
    resultStruct.frameTimes = nan(numFrames, 1);
    resultStruct.metrics = struct();
    resultStruct.createdAt = datestr(now, 'yyyy-mm-dd HH:MM:SS');
end

function sequenceName = extract_sequence_name(sequenceDir)
    [~, sequenceName] = fileparts(sequenceDir);
end
