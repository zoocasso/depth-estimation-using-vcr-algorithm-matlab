function [best, scores, tied] = estimate_depth(get_image, cam, depths, reference, method, varargin)
%ESTIMATE_DEPTH Depth at which a target comes into focus in the reconstruction.
%   [best, scores, tied] = ESTIMATE_DEPTH(get_image, cam, depths, reference, method) reconstructs
%   the scene at every depth in DEPTHS with METHOD ('fixed' or 'nonuniform', see VCR_SHIFTS),
%   correlates each grayscale reconstruction with the REFERENCE image of the target, and returns
%   the depth with the highest score, the score at every depth, and TIED, every depth that
%   reaches that highest score. The target is sharp, and so matches best, only at its own depth.
%
%   Neighbouring depths often round to the same integer offsets, above all with fixed VCR, and
%   then give the same reconstruction and the same score. BEST is the first depth with the top
%   score, but the data only place the target somewhere in [min(tied), max(tied)]. A depth whose
%   offsets equal those of the depth before it is not reconstructed again, so pass DEPTHS sorted.
%
%   Options, as name-value pairs:
%       'filter'   'LCF', 'POF', 'PC' or 'NLF' (default), see CORRELATION_PEAKS
%       'measure'  'peak' (default), the correlation peak divided by the reference's own peak,
%                  or 'pce', the peak-to-correlation energy, which does not depend on the
%                  brightness of the reconstruction

opts = struct('filter', 'NLF', 'measure', 'peak');
if mod(numel(varargin), 2) ~= 0
    error('estimate_depth:option', 'options must come in name-value pairs');
end
for i = 1:2:numel(varargin)
    if ~ischar(varargin{i}) || ~isfield(opts, lower(varargin{i}))
        error('estimate_depth:option', 'unknown option (expected ''filter'' or ''measure'')');
    end
    opts.(lower(varargin{i})) = varargin{i + 1};
end
if ~any(strcmp(opts.measure, {'peak', 'pce'}))
    error('estimate_depth:option', 'measure must be ''peak'' or ''pce'', not ''%s''', opts.measure);
end
if ~any(strcmp(opts.filter, {'LCF', 'POF', 'PC', 'NLF'}))
    error('estimate_depth:option', 'filter must be ''LCF'', ''POF'', ''PC'' or ''NLF'', not ''%s''', opts.filter);
end

scores = zeros(size(depths));
for d = 1:numel(depths)
    [sx, sy] = vcr_shifts(cam, depths(d), method);
    if d > 1 && isequal(sx, prev_sx) && isequal(sy, prev_sy)
        scores(d) = scores(d - 1);  % same offsets, so the same reconstruction
        continue;
    end
    recon = to_gray(vcr_reconstruct(get_image, cam, sx, sy));
    [peaks, pce] = correlation_peaks(reference, recon);
    if strcmp(opts.measure, 'pce')
        scores(d) = pce.(opts.filter);
    else
        scores(d) = peaks.(opts.filter);
    end
    prev_sx = sx;
    prev_sy = sy;
end
if ~any(isfinite(scores))
    error('estimate_depth:score', 'no finite score: is the reference or every reconstruction all zero?');
end
tied = depths(scores == max(scores));
best = tied(1);
end
