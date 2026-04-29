function kernel = gaussian_correlation(featuresX, featuresY, sigma)
%GAUSSIAN_CORRELATION 计算多通道特征的高斯核相关。
% 输入:
%   featuresX - 特征张量X。
%   featuresY - 特征张量Y。
%   sigma - 高斯核带宽。
% 输出:
%   kernel - 空域高斯相关响应图。

xf = fft2(featuresX);
yf = fft2(featuresY);
crossSpectrum = sum(xf .* conj(yf), 3);
crossCorrelation = real(ifft2(crossSpectrum));

xNorm = sum(featuresX(:) .^ 2);
yNorm = sum(featuresY(:) .^ 2);
distance = max(0, (xNorm + yNorm - 2 * crossCorrelation) ./ numel(crossCorrelation));

kernel = exp(-distance ./ max(eps('single'), sigma ^ 2));
kernel = single(kernel);
end
