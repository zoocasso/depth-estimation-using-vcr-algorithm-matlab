function get_image = ei_reader(folder, pattern, Lx, cache)
%EI_READER Function that reads one elemental image from disk.
%   get_image = EI_READER(folder, pattern, Lx) returns a function: get_image(k1, k2) reads the
%   image in row k1 and column k2 as a double array in [0, 1]. PATTERN is the file name with a
%   %d for the image number, counted row by row from 1, for example 'EI_%d.jpg'.
%
%   EI_READER(folder, pattern, Lx, true) keeps every file it has decoded, in the file's own
%   integer type, so each image is decoded once instead of once per reconstruction depth. The
%   cache holds the whole set: 100 JPEGs of 3008 x 2000 px take about 1.8 GB as uint8.

if nargin < 4
    cache = false;
end
read = @(k1, k2) imread(fullfile(folder, sprintf(pattern, (k1 - 1) * Lx + k2)));
if cache
    store = containers.Map('KeyType', 'double', 'ValueType', 'any');
    get_image = @(k1, k2) im2unit(cached_read(store, read, k1, k2, (k1 - 1) * Lx + k2));
else
    get_image = @(k1, k2) im2unit(read(k1, k2));
end
end

function img = cached_read(store, read, k1, k2, key)
% containers.Map is a handle object, so what is stored here stays in the closure's map
if ~isKey(store, key)
    store(key) = read(k1, k2);
end
img = store(key);
end

function img = im2unit(img)
% integer images are scaled by their type's maximum, so 8- and 16-bit files both end up in [0, 1]
if isinteger(img)
    img = double(img) / double(intmax(class(img)));
else
    img = double(img);
end
end
