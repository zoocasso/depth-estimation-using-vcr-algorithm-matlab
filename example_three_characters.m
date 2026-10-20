%EXAMPLE_THREE_CHARACTERS Depth of a target in the "Three Characters" scene, fixed and nonuniform VCR.
%   The scene is 10 x 10 elemental images of 3008 x 2000 pixels taken with a 105 mm lens, a
%   36 x 24 mm sensor and a 2 mm camera pitch. Put the images in data/Three_Characters/EI_1.jpg
%   ... EI_100.jpg and a crop of the target in data/Three_Characters/target.png, then run
%   EXAMPLE_THREE_CHARACTERS from this folder. The data set is not in the repository.
%
%   The reader caches the decoded images (about 1.8 GB as uint8), so the 100 JPEGs are decoded
%   once instead of once per depth and method. Pass false to EI_READER to read them from disk
%   every time instead.

cam = struct('Nx', 3008, 'Ny', 2000, 'f', 105, 'p', 2, 'cx', 36, 'cy', 24, 'Lx', 10, 'Ly', 10);
scene = fullfile('data', 'Three_Characters');
depths = 400:5:1000;  % mm

get_image = ei_reader(scene, 'EI_%d.jpg', cam.Lx, true);
reference = to_gray(double(imread(fullfile(scene, 'target.png'))) / 255);

figure;
hold on;
for method = {'fixed', 'nonuniform'}
    [best, scores, tied] = estimate_depth(get_image, cam, depths, reference, method{1});
    plot(depths, scores, 'DisplayName', sprintf('%s VCR, best %d-%d mm', method{1}, min(tied), max(tied)));
    fprintf('%-10s best depth %d mm, same peak from %d to %d mm (peak %.3f)\n', ...
            method{1}, best, min(tied), max(tied), max(scores));
end
xlabel('reconstruction depth (mm)');
ylabel('nonlinear correlation peak');
legend('show');
grid on;
