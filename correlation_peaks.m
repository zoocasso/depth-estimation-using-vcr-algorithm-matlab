function peaks = correlation_peaks(reference, scene, k)
%CORRELATION_PEAKS How strongly a reference target appears in a scene, with three FFT filters.
%   peaks = CORRELATION_PEAKS(reference, scene) returns a struct with the correlation peak of
%       LCF  the linear correlation filter (matched filter)
%       POF  the phase-only filter
%       NLF  the nonlinear filter, |X||R| raised to k, with the phase of X/R
%   each divided by the reference's own (autocorrelation) peak, so 1 means the scene holds the
%   target exactly. CORRELATION_PEAKS(reference, scene, k) sets the nonlinearity (default 0.3).
%
%   Both inputs are grayscale double images. The reference is zero-padded to the scene's size,
%   so it must not be larger than the scene.

if nargin < 3
    k = 0.3;
end
[v, h] = size(scene);
[rv, rh] = size(reference);
if rv > v || rh > h
    error('correlation_peaks:size', 'the reference (%dx%d) is larger than the scene (%dx%d)', rv, rh, v, h);
end

padded = zeros(v, h);
top = floor((v - rv) / 2);
left = floor((h - rh) / 2);
padded(top + (1:rv), left + (1:rh)) = reference;

R = fft2(padded);
S = fft2(scene);
filters = struct( ...
    'LCF', @(X) X .* conj(R), ...
    'POF', @(X) exp(1i * (angle(X) - angle(R))), ...
    'NLF', @(X) (abs(X) .* abs(R)) .^ k .* exp(1i * (angle(X) - angle(R))));

names = fieldnames(filters);
for n = 1:numel(names)
    filter = filters.(names{n});
    auto = max(max(abs(ifft2(filter(R)))));
    peaks.(names{n}) = max(max(abs(ifft2(filter(S))))) / auto;
end
end
