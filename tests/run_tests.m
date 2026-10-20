function run_tests()
%RUN_TESTS Checks of the reconstruction and the depth estimate on synthetic scenes.
%   Runs in MATLAB and in GNU Octave, from the repository root:
%       addpath(pwd); addpath(fullfile(pwd, 'tests')); run_tests

tests = {@test_shifts, @test_reconstruction_averages_overlaps, @test_identical_images_peak_at_one, ...
         @test_target_inside_a_larger_scene, @test_depth_of_a_synthetic_target, @test_unknown_method, @test_ei_reader};
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
peaks = correlation_peaks(img, img);
for name = {'LCF', 'POF', 'NLF'}
    assert(abs(peaks.(name{1}) - 1) < 1e-9, name{1});
end
end

function test_target_inside_a_larger_scene()
target = rand(8, 8);
scene = zeros(40, 40);
scene(5:12, 20:27) = target;
peaks = correlation_peaks(target, scene);
assert(abs(peaks.LCF - 1) < 1e-9);
assert(peaks.POF > 0.99 && peaks.NLF > 0.99);
assert(correlation_peaks(target, rand(40, 40)).NLF < 0.5);  % no target, low peak
end

function test_depth_of_a_synthetic_target()
% a textured patch seen by 4 x 4 cameras; at its true depth every view shifts it by S = 3 px
n = 64;
cam = small_cam(n, 4);
true_depth = 5 * n / 3;
patch = rand(10, 10);
get_image = @(k1, k2) place(patch, n, 30 - 3 * (k1 - 1), 30 - 3 * (k2 - 1));
depths = true_depth * [0.6 0.75 0.9 1 1.15 1.3 1.5];
best = estimate_depth(get_image, cam, depths, patch, 'nonuniform');
assert(abs(best - true_depth) < 1e-9, sprintf('expected %g, got %g', true_depth, best));
end

function img = place(patch, n, row, col)
img = zeros(n, n);
img(row + (1:size(patch, 1)), col + (1:size(patch, 2))) = patch;
end

function test_unknown_method()
try
    vcr_shifts(small_cam(10, 2), 100, 'bogus');
    error('run_tests:noerror', 'expected an error');
catch err
    assert(strcmp(err.identifier, 'vcr_shifts:method'));
end
end

function test_ei_reader()
folder = tempname();
mkdir(folder);
cleanup = onCleanup(@() rmdir(folder, 's'));
for k = 1:4
    imwrite(uint8(k * 50 * ones(4, 5, 3)), fullfile(folder, sprintf('EI_%d.png', k)));
end
get_image = ei_reader(folder, 'EI_%d.png', 2);
img = get_image(2, 1);  % third image, row by row
assert(isequal(size(img), [4 5 3]));
assert(abs(img(1) - 150 / 255) < 1e-12);
end
