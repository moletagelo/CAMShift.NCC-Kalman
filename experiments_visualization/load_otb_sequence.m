function sequence = load_otb_sequence(config)
%LOAD_OTB_SEQUENCE 加载 OTB 序列路径、帧列表与标注信息。
% 输入：config，项目配置结构体。
% 输出：sequence，包含目录、帧路径、真值、帧数和图像尺寸信息。

    sequence.sequenceDir = fullfile(config.dataset.rootDir, config.dataset.sequenceName);
    sequence.imgDir = fullfile(sequence.sequenceDir, 'img');
    sequence.framePaths = list_sequence_frames( ...
        sequence.imgDir, config.dataset.imageExtension, config.dataset.frameLimit);
    sequence.groundTruth = load_ground_truth( ...
        fullfile(sequence.sequenceDir, config.dataset.groundTruthFile));
    sequence.numFrames = numel(sequence.framePaths);

    firstFrame = imread(sequence.framePaths{1});
    sequence.imageSize = size(firstFrame);

    if size(sequence.groundTruth, 1) < sequence.numFrames
        warning('load_otb_sequence:ShortGroundTruth', ...
            'Ground-truth rows (%d) are fewer than frames (%d). Truncating frame list.', ...
            size(sequence.groundTruth, 1), sequence.numFrames);
        sequence.numFrames = size(sequence.groundTruth, 1);
        sequence.framePaths = sequence.framePaths(1:sequence.numFrames);
    elseif size(sequence.groundTruth, 1) > sequence.numFrames
        sequence.groundTruth = sequence.groundTruth(1:sequence.numFrames, :);
    end
end
