function [imTotal, rmaskTotal] = merge(im1_rgb, im2_rgb, rmask1, rmask2, show)
if nargin < 5
    show = false;
end
if nargin < 4
    rmask2 = ones(size(im2_rgb, 1:2));
end
if nargin < 3
    rmask1 = ones(size(im1_rgb, 1:2));
end
if nargin < 2
    error("merge need at least 2 arguments");
end
im1 = rgb2gray(im1_rgb);
im2 = rgb2gray(im2_rgb);

pts1 = detectSURFFeatures(im1);
pts2 = detectSURFFeatures(im2);
[f1, vpts1] = extractFeatures(im1, pts1);
[f2, vpts2] = extractFeatures(im2, pts2);

indexPairs = matchFeatures(f1, f2, 'Unique', true);
mpts1 = vpts1(indexPairs(:, 1));
mpts2 = vpts2(indexPairs(:, 2));

if show
    figure(1);
    showMatchedFeatures(im1, im2, mpts1, mpts2, 'montage');
    legend('pts 1', 'pts 2');
end

H = ransac_homography(mpts1.Location, mpts2.Location, 1000, 10);
tform = projective2d(H');


transed = transformPointsForward(tform, [0, 0; 0, size(im2, 1); size(im2, 2), 0; size(im2, 2), size(im2, 1)]);
xlo = min([floor(transed(:, 1)); 1]);
xhi = max([floor(transed(:, 1)); size(im1, 2)]);
ylo = min([floor(transed(:, 2)); 1]);
yhi = max([floor(transed(:, 2)); size(im1, 1)]);

dx = 1 - xlo;
dy = 1 - ylo;
szx = xhi-xlo+1;
szy = yhi-ylo+1;
nc = size(im1_rgb, 3);

mask1 = gen_mask(size(im1)) .* rmask1;
mask2 = gen_mask(size(im2)) .* rmask2;

[xmesh, ymesh] = meshgrid(1:szx, 1:szy);
xmesh = xmesh - dx;
ymesh = ymesh - dy;

im1_tmp = zeros(szy, szx, nc);
for i = 1:nc
    im1_tmp(:, :, i) = interp2(double(im1_rgb(:, :, i)), xmesh, ymesh, 'linear', 0);
end
mask1_tmp = interp2(double(mask1), xmesh, ymesh, 'linear', 0);
rmask1_tmp = interp2(double(rmask1), xmesh, ymesh, 'linear', 0);

coords = transformPointsInverse(tform, [xmesh(:), ymesh(:)]);
xcoords = reshape(coords(:, 1), size(xmesh));
ycoords = reshape(coords(:, 2), size(ymesh));

im2_tmp = zeros(szy, szx, nc);
for i = 1:nc
    im2_tmp(:, :, i) = interp2(double(im2_rgb(:, :, i)), xcoords, ycoords, 'linear', 0);
end
mask2_tmp = interp2(double(mask2), xcoords, ycoords, 'linear', 0);
rmask2_tmp = interp2(double(rmask2), xcoords, ycoords, 'linear', 0);

imTotal = im1_tmp .* repmat(mask1_tmp, [1, 1, nc])...
    + im2_tmp .* repmat(mask2_tmp, [1, 1, nc]);
maskTotal = mask1_tmp + mask2_tmp;
rmaskTotal = (rmask1_tmp > 0.5) | (rmask2_tmp > 0.5);

imTotal = uint8(imTotal(:, :, :) ./ repmat(maskTotal+1e-20, [1, 1, nc]));

if show
    figure(2);
    imshow(imTotal);
end
end

function mask =  gen_mask(sz)
nx = sz(2);
ny = sz(1);
sigma = 0.75;
[xg,yg] = meshgrid(1:nx, 1:ny);
mask = (xg - nx/2.0).^2 ./(sigma*nx)^2 + (yg - ny/2.0).^2./(sigma*ny)^2;
end

