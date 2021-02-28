function n = validate_homography(u, H, v, eps)
tform = projective2d(H');
uu = transformPointsForward(tform, v);
du = u - uu;
du2 = (du(:, 1) .^ 2) + (du(:, 2) .^ 2);
n = sum(du2 < eps^2);
end

