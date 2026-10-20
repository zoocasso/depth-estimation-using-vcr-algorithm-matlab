function recon = vcr_reconstruct(get_image, cam, sx, sy)
%VCR_RECONSTRUCT Volumetric computational reconstruction at one depth.
%   recon = VCR_RECONSTRUCT(get_image, cam, sx, sy) places elemental image (k1, k2) at row offset
%   sy(k1) and column offset sx(k2) and averages wherever images overlap. Objects at the depth the
%   offsets were computed for line up and come out sharp; everything else is blurred.
%
%   get_image(k1, k2) returns elemental image (row k1, column k2) as a double array in [0, 1].
%   Images are read one at a time, so a 10 x 10 set of 3008 x 2000 images never has to fit in
%   memory at once. See EI_READER.

canvas = zeros(cam.Ny + max(sy), cam.Nx + max(sx), 3);
count = zeros(cam.Ny + max(sy), cam.Nx + max(sx));
for k1 = 1:cam.Ly
    rows = sy(k1) + (1:cam.Ny);
    for k2 = 1:cam.Lx
        cols = sx(k2) + (1:cam.Nx);
        img = get_image(k1, k2);
        if size(img, 3) == 1
            img = repmat(img, [1 1 3]);
        end
        canvas(rows, cols, :) = canvas(rows, cols, :) + img;
        count(rows, cols) = count(rows, cols) + 1;
    end
end
recon = canvas ./ max(count, 1);
end
