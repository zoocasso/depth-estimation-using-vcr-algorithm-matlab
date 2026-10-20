function get_image = ei_reader(folder, pattern, Lx)
%EI_READER Function that reads one elemental image from disk.
%   get_image = EI_READER(folder, pattern, Lx) returns a function: get_image(k1, k2) reads the
%   image in row k1 and column k2 as a double array in [0, 1]. PATTERN is the file name with a
%   %d for the image number, counted row by row from 1, for example 'EI_%d.jpg'.

get_image = @(k1, k2) im2unit(imread(fullfile(folder, sprintf(pattern, (k1 - 1) * Lx + k2))));
end

function img = im2unit(img)
% integer images are scaled by their type's maximum, so 8- and 16-bit files both end up in [0, 1]
if isinteger(img)
    img = double(img) / double(intmax(class(img)));
else
    img = double(img);
end
end
