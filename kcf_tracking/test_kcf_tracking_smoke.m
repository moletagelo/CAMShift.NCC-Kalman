function test_kcf_tracking_smoke()
%TEST_KCF_TRACKING_SMOKE KCF模块基础烟雾测试。
% 输入:
%   无。
% 输出:
%   无，断言失败时抛出错误。

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projectRoot);
addpath(fullfile(projectRoot, 'kcf_tracking'));

params = create_kcf_parameters();
assert(abs(params.padding - 1.5) < eps, 'Unexpected default padding.');
assert(params.cell_size == 4, 'Unexpected default cell size.');

featureA = rand(8, 8, 3);
kernelAA = gaussian_correlation(featureA, featureA, params.sigma);
assert(abs(max(kernelAA(:)) - 1) < 1e-6, 'Kernel self-similarity should peak at 1.');

frameSize = [128, 128];
initialBox = [38, 44, 18, 14];
nextBox = [42, 47, 18, 14];

frame1 = create_synthetic_frame(frameSize, initialBox);
frame2 = create_synthetic_frame(frameSize, nextBox);

tracker = initialize_kcf_tracker(frame1, initialBox, params);
[tracker, prediction, diagnostics] = update_kcf_tracker(tracker, frame2);

predCenter = [prediction(2) + prediction(4) / 2, prediction(1) + prediction(3) / 2];
gtCenter = [nextBox(2) + nextBox(4) / 2, nextBox(1) + nextBox(3) / 2];
centerError = norm(predCenter - gtCenter);

assert(centerError < 6, 'Synthetic target translation should be tracked within tolerance.');
assert(isfield(diagnostics, 'peakValue'), 'Update diagnostics should include peak value.');
assert(~isempty(tracker.model_alphaf), 'Tracker model should be updated.');

disp('KCF_SMOKE_OK');
end

function frame = create_synthetic_frame(frameSize, bbox)
%CREATE_SYNTHETIC_FRAME 构造带亮矩形目标的灰度测试帧。
% 输入:
%   frameSize - 图像尺寸 [height, width]。
%   bbox - 目标框 [x, y, width, height]。
% 输出:
%   frame - uint8测试图像。

frame = uint8(20 + 5 * randn(frameSize));
frame = max(frame, uint8(0));
frame = min(frame, uint8(255));

x1 = max(1, round(bbox(1)));
y1 = max(1, round(bbox(2)));
x2 = min(frameSize(2), round(bbox(1) + bbox(3) - 1));
y2 = min(frameSize(1), round(bbox(2) + bbox(4) - 1));

frame(y1:y2, x1:x2) = 220;
frame(max(1, y1 - 1):min(frameSize(1), y2 + 1), max(1, x1 - 1):min(frameSize(2), x2 + 1)) = 160;
end
