function [sx, sy] = vcr_shifts(cam, depth, method)
%VCR_SHIFTS Integer pixel offsets of the elemental images at a reconstruction depth.
%   [sx, sy] = VCR_SHIFTS(cam, depth, method) returns the column offsets (1 x Lx) and the row
%   offsets (1 x Ly) at which the elemental images are placed on the reconstruction plane.
%
%   cam is a struct with the fields
%       Nx, Ny  pixels per elemental image
%       f       focal length
%       p       pitch between neighbouring cameras
%       cx, cy  sensor size
%       Lx, Ly  number of elemental images
%   f, cx and cy share one unit; p and depth share another.
%
%   The ideal shift between neighbouring images, S = N * f * p / (c * depth), is a real number,
%   but images can only be placed on whole pixels:
%       'fixed'       k * round(S)    one rounded step reused, so the error grows with k
%       'nonuniform'  round(k * S)    every image rounded on its own

Sx = cam.Nx * cam.f * cam.p / (cam.cx * depth);
Sy = cam.Ny * cam.f * cam.p / (cam.cy * depth);
kx = 0:cam.Lx - 1;
ky = 0:cam.Ly - 1;

switch method
    case 'fixed'
        sx = kx * round(Sx);
        sy = ky * round(Sy);
    case 'nonuniform'
        sx = round(kx * Sx);
        sy = round(ky * Sy);
    otherwise
        error('vcr_shifts:method', 'method must be ''fixed'' or ''nonuniform'', not ''%s''', method);
end
end
