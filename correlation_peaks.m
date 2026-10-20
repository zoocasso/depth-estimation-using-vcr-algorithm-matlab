function [peaks, pce] = correlation_peaks(reference, scene, k)
%CORRELATION_PEAKS How strongly a reference target appears in a scene, with four FFT filters.
%   peaks = CORRELATION_PEAKS(reference, scene) returns a struct with the correlation peak of
%       LCF  the linear correlation filter (matched filter), S .* conj(R)
%       POF  the phase-only filter, S .* conj(R) ./ abs(R)
%       PC   phase correlation, exp(1i * (angle(S) - angle(R))): only the phase difference is
%            kept, and nothing where S is 0. Apart from those zeros it is NLF with k = 0. The
%            2022 course code called this one the phase-only filter.
%       NLF  the nonlinear filter, (abs(S) .* abs(R)) .^ k with the phase of S ./ R
%   where R and S are the 2-D Fourier transforms of the reference and the scene. Each peak is
%   divided by the peak the same filter gives for the reference against itself, so it is 1 when
%   the scene is the reference. It is not bounded by 1 and does not account for the scene's
%   energy: LCF and POF are linear in the scene, so a scene twice as bright gives 2, NLF grows as
%   2^k, and a bright scene without the target can score above 1. PC is the exception: its peak
%   is at most 1 and does not depend on brightness.
%
%   [peaks, pce] = CORRELATION_PEAKS(...) also returns the peak-to-correlation energy of each
%   filter output c, PCE = max(abs(c(:)))^2 / sum(abs(c(:)).^2), between 0 and 1. A sharp,
%   isolated peak gives a high PCE, and PCE does not change when the scene is multiplied by a
%   constant, so it compares scenes of different brightness.
%
%   CORRELATION_PEAKS(reference, scene, k) sets the nonlinearity (default 0.3).
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
    'POF', @(X) X .* conj(R) ./ max(abs(R), eps), ...
    'PC', @(X) (abs(X) > 0) .* exp(1i * (angle(X) - angle(R))), ...
    'NLF', @(X) (abs(X) .* abs(R)) .^ k .* exp(1i * (angle(X) - angle(R))));

names = fieldnames(filters);
for n = 1:numel(names)
    filter = filters.(names{n});
    auto = max(max(abs(ifft2(filter(R)))));
    c = abs(ifft2(filter(S)));
    peaks.(names{n}) = max(c(:)) / auto;
    pce.(names{n}) = max(c(:))^2 / sum(c(:).^2);
end
end
