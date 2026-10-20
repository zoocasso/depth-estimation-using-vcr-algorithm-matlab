function gray = to_gray(img)
%TO_GRAY Luminance of an RGB image (ITU-R BT.601 weights, as in rgb2gray); gray images pass through.

if size(img, 3) == 3
    gray = 0.2989 * img(:, :, 1) + 0.5870 * img(:, :, 2) + 0.1140 * img(:, :, 3);
else
    gray = img;
end
end
