function motionMask = postprocess_motion_mask(motionMask, options)
% 对运动掩膜进行形态学后处理与小区域清理。
% 输入:
%   motionMask - 原始二值掩膜
%   options    - 参数结构体，支持 useMorphology、diskRadius、minArea
% 输出:
%   motionMask - 处理后的二值掩膜

motionMask = logical(motionMask);

if isfield(options, 'useMorphology') && options.useMorphology
    diskRadius = 2;
    if isfield(options, 'diskRadius') && ~isempty(options.diskRadius)
        diskRadius = options.diskRadius;
    end
    se = strel('disk', diskRadius, 0);
    motionMask = imclose(motionMask, se);
    motionMask = imfill(motionMask, 'holes');
end

if isfield(options, 'minArea') && ~isempty(options.minArea) && options.minArea > 0
    motionMask = bwareaopen(motionMask, options.minArea);
end
end
