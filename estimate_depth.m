function [best, scores] = estimate_depth(get_image, cam, depths, reference, method, filter)
%ESTIMATE_DEPTH Depth at which a target comes into focus in the reconstruction.
%   [best, scores] = ESTIMATE_DEPTH(get_image, cam, depths, reference, method) reconstructs the
%   scene at every depth in DEPTHS with METHOD ('fixed' or 'nonuniform', see VCR_SHIFTS),
%   correlates each grayscale reconstruction with the REFERENCE image of the target, and returns
%   the depth with the highest correlation peak and the peak at every depth.
%
%   ESTIMATE_DEPTH(..., filter) picks the filter: 'LCF', 'POF' or 'NLF' (default), see
%   CORRELATION_PEAKS. The target is sharp, and so matches best, only at its own depth.

if nargin < 6
    filter = 'NLF';
end
scores = zeros(size(depths));
for d = 1:numel(depths)
    [sx, sy] = vcr_shifts(cam, depths(d), method);
    recon = to_gray(vcr_reconstruct(get_image, cam, sx, sy));
    peaks = correlation_peaks(reference, recon);
    scores(d) = peaks.(filter);
end
[~, i] = max(scores);
best = depths(i);
end
