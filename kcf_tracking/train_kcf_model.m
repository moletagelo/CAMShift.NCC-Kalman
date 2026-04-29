function model = train_kcf_model(features, yf, lambda, sigma)
%TRAIN_KCF_MODEL 在频域中训练KCF回归模型。
% 输入:
%   features - 训练特征张量。
%   yf - 标签频谱。
%   lambda - 正则化系数。
%   sigma - 高斯核带宽。
% 输出:
%   model - 包含模型模板和频域参数的结构体。

kernel = gaussian_correlation(features, features, sigma);
kernelSpectrum = fft2(kernel);
alphaf = yf ./ (kernelSpectrum + lambda);

model = struct();
model.x = single(features);
model.xf = fft2(features);
model.alphaf = alphaf;
model.kernel_spectrum = kernelSpectrum;
end
