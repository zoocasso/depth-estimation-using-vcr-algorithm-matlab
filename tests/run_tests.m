function run_tests()
%RUN_TESTS Checks of the reconstruction and the depth estimate on synthetic scenes.
%   Written for MATLAB and GNU Octave (checked with Octave). From the repository root:
%       addpath(pwd); addpath(fullfile(pwd, 'tests')); run_tests

rng(42);  % the synthetic scenes use rand
tests = {@test_shifts, @test_reconstruction_averages_overlaps, @test_identical_images_peak_at_one, ...
         @test_peaks_scale_with_the_scene, @test_phase_correlation_is_nlf_with_k_zero, ...
         @test_target_inside_a_larger_scene, @test_depth_of_a_synthetic_target, ...
         @test_fixed_method_reports_tied_depths, @test_pce_measure, @test_repeated_offsets_are_not_reconstructed, ...
         @test_bad_options, @test_all_zero_reference, @test_unknown_method, @test_ei_reader, @test_ei_reader_cache};
for t = 1:numel(tests)
    tests{t}();
    fprintf('ok  %s\n', func2str(tests{t}));
end
fprintf('%d tests passed\n', numel(tests));
end

function cam = small_cam(n, l)
% S = N * f * p / (c * z) = n * 50 * 1 / (10 * z) = 5 * n / z
cam = struct('Nx', n, 'Ny', n, 'f', 50, 'p', 1, 'cx', 10, 'cy', 10, 'Lx', l, 'Ly', l);
end

function test_shifts()
cam = small_cam(100, 3);
depth = 500 / 2.4;  % S = 2.4 pixels
[sx, sy] = vcr_shifts(cam, depth, 'fixed');
assert(isequal(sx, [0 2 4]) && isequal(sy, [0 2 4]));
[sx, ~] = vcr_shifts(cam, depth, 'nonuniform');
assert(isequal(sx, [0 2 5]));  % 2.4 and 4.8 rounded separately
end

function test_reconstruction_averages_overlaps()
cam = small_cam(2, 2);
values = [1 2; 3 4];
get_image = @(k1, k2) values(k1, k2) * ones(2, 2);
recon = vcr_reconstruct(get_image, cam, [0 1], [0 1]);
assert(isequal(size(recon), [3 3 3]));
gray = recon(:, :, 1);
assert(abs(gray(2, 2) - mean(values(:))) < 1e-12);  % covered by all four images
assert(gray(1, 1) == 1 && gray(3, 3) == 4);        % covered by one image each
assert(abs(gray(1, 2) - 1.5) < 1e-12);              % images (1,1) and (1,2)
end

function test_identical_images_peak_at_one()
img = rand(32, 32);
[peaks, pce] = correlation_peaks(img, img);
for name = {'LCF', 'POF', 'PC', 'NLF'}
    assert(abs(peaks.(name{1}) - 1) < 1e-9, name{1});
end
assert(abs(pce.PC - 1) < 1e-9);  % phase correlation of an image with itself is a single spike
end

function test_peaks_scale_with_the_scene()
% the peaks are relative to the reference's own peak, not to the scene's energy
img = rand(32, 32);
[peaks, pce] = correlation_peaks(img, img);
[bright, pce_bright] = correlation_peaks(img, 2 * img);
assert(abs(bright.LCF - 2) < 1e-9 && abs(bright.POF - 2) < 1e-9);
assert(abs(bright.NLF - 2^0.3) < 1e-9);
assert(abs(bright.PC - 1) < 1e-9);
assert(correlation_peaks(img, ones(32, 32)).LCF > 1);  % a white scene without the target
for name = {'LCF', 'POF', 'PC', 'NLF'}
    assert(abs(pce_bright.(name{1}) - pce.(name{1})) < 1e-9, name{1});  % PCE does not change
end
end

function test_phase_correlation_is_nlf_with_k_zero()
ref = rand(16, 16);
scene = rand(32, 32);
peaks = correlation_peaks(ref, scene, 0);
assert(abs(peaks.NLF - peaks.PC) < 1e-12);
assert(peaks.PC <= 1);
assert(correlation_peaks(ref, zeros(32, 32)).PC == 0);  % a black scene has no phase to match
end

function test_target_inside_a_larger_scene()
target = rand(8, 8);
scene = zeros(40, 40);
scene(5:12, 20:27) = target;
peaks = correlation_peaks(target, scene);
assert(abs(peaks.LCF - 1) < 1e-9);
assert(peaks.PC > 0.99 && peaks.NLF > 0.99);
assert(correlation_peaks(target, rand(40, 40)).NLF < 0.5);  % no target, low peak
end

function [get_image, true_depth] = synthetic_target(n, l)
% a textured patch seen by l x l cameras; at its true depth every view shifts it by S = 3 px
true_depth = 5 * n / 3;
patch = rand(10, 10);
get_image = @(k1, k2) place(patch, n, 30 - 3 * (k1 - 1), 30 - 3 * (k2 - 1));
end

function img = place(patch, n, row, col)
img = zeros(n, n);
img(row + (1:size(patch, 1)), col + (1:size(patch, 2))) = patch;
end

function test_depth_of_a_synthetic_target()
n = 64;
cam = small_cam(n, 4);
[get_image, true_depth] = synthetic_target(n, 4);
depths = true_depth * [0.6 0.75 0.9 1 1.15 1.3 1.5];
reference = get_image(1, 1);
reference = reference(31:40, 31:40);
[best, ~, tied] = estimate_depth(get_image, cam, depths, reference, 'nonuniform');
assert(abs(best - true_depth) < 1e-9, sprintf('expected %g, got %g', true_depth, best));
assert(isscalar(tied));
end

function test_fixed_method_reports_tied_depths()
% S = 320 / z. Fixed VCR uses round(S) = 3 for every z in (91.4, 128], so on a 4 mm grid the
% depths 92 ... 128 give the same reconstruction. Nonuniform VCR also rounds 2S and 3S, which
% narrows the tie to 104 ... 112. The true depth, 106.7, lies inside both ranges.
n = 64;
cam = small_cam(n, 4);
[get_image, true_depth] = synthetic_target(n, 4);
reference = get_image(1, 1);
reference = reference(31:40, 31:40);
depths = 80:4:140;
[best, scores, tied] = estimate_depth(get_image, cam, depths, reference, 'fixed');
assert(isequal(tied, 92:4:128), mat2str(tied));
assert(best == 92);
assert(numel(unique(scores(ismember(depths, tied)))) == 1);
[~, ~, tied] = estimate_depth(get_image, cam, depths, reference, 'nonuniform');
assert(isequal(tied, [104 108 112]), mat2str(tied));
assert(min(tied) < true_depth && true_depth < max(tied));
end

function test_pce_measure()
n = 64;
cam = small_cam(n, 4);
[get_image, true_depth] = synthetic_target(n, 4);
reference = get_image(1, 1);
reference = reference(31:40, 31:40);
depths = true_depth * [0.75 1 1.3];
best = estimate_depth(get_image, cam, depths, reference, 'nonuniform', 'measure', 'pce', 'filter', 'PC');
assert(abs(best - true_depth) < 1e-9);
end

function test_repeated_offsets_are_not_reconstructed()
n = 32;
cam = small_cam(n, 2);
calls = containers.Map({'n'}, {0});
get_image = @(k1, k2) counted(calls, rand(n, n));
depths = 80:4:140;  % S = 160 / z
estimate_depth(get_image, cam, depths, rand(8, 8), 'fixed');
distinct = numel(unique(round(160 ./ depths)));  % one reconstruction per distinct round(S)
assert(calls('n') == distinct * 4, sprintf('%d image reads', calls('n')));
end

function img = counted(calls, img)
calls('n') = calls('n') + 1;
end

function test_bad_options()
cam = small_cam(16, 2);
get_image = @(k1, k2) rand(16, 16);
for opts = {{'measure', 'psr'}, {'filter', 'XYZ'}, {'bogus', 1}, {'filter'}}
    try
        estimate_depth(get_image, cam, 100, rand(4, 4), 'fixed', opts{1}{:});
        error('run_tests:noerror', 'expected an error');
    catch err
        assert(strcmp(err.identifier, 'estimate_depth:option'), err.message);
    end
end
end

function test_all_zero_reference()
cam = small_cam(16, 2);
try
    estimate_depth(@(k1, k2) rand(16, 16), cam, [100 120], zeros(4, 4), 'fixed');
    error('run_tests:noerror', 'expected an error');
catch err
    assert(strcmp(err.identifier, 'estimate_depth:score'), err.message);
end
end

function test_unknown_method()
try
    vcr_shifts(small_cam(10, 2), 100, 'bogus');
    error('run_tests:noerror', 'expected an error');
catch err
    assert(strcmp(err.identifier, 'vcr_shifts:method'));
end
end

function folder = write_images()
folder = tempname();
mkdir(folder);
for k = 1:4
    imwrite(uint8(k * 50 * ones(4, 5, 3)), fullfile(folder, sprintf('EI_%d.png', k)));
end
end

function test_ei_reader()
folder = write_images();
cleanup = onCleanup(@() rmdir(folder, 's'));
get_image = ei_reader(folder, 'EI_%d.png', 2);
img = get_image(2, 1);  % third image, row by row
assert(isequal(size(img), [4 5 3]));
assert(abs(img(1) - 150 / 255) < 1e-12);
end

function test_ei_reader_cache()
folder = write_images();
cleanup = onCleanup(@() rmdir(folder, 's'));
cached = ei_reader(folder, 'EI_%d.png', 2, true);
plain = ei_reader(folder, 'EI_%d.png', 2);
assert(abs(cached(2, 1) - 150 / 255) < 1e-12);
imwrite(uint8(10 * ones(4, 5, 3)), fullfile(folder, 'EI_3.png'));  % change the file on disk
img = cached(2, 1);
assert(abs(img(1) - 150 / 255) < 1e-12);  % still the decoded copy
img = plain(2, 1);
assert(abs(img(1) - 10 / 255) < 1e-12);   % the plain reader reads the file again
end
