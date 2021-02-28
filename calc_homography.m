function H = calc_homography(u, v)
%calc_homography
%   u = H * v
%   u and v: 4x2 mat, 4 points
A = zeros(8, 9);
for i = 1:4
    ux = u(i, 1);
    uy = u(i, 2);
    vx = v(i, 1);
    vy = v(i, 2);
    A(2*i-1, 1:3) = [vx, vy, 1];
    A(2*i-1, 7:9) = -ux * [vx, vy, 1];
    A(2*i, 4:6) = [vx, vy, 1];
    A(2*i, 7:9) = -uy * [vx, vy, 1];
end
h = null(A);
H = reshape(h, 3, 3)';
end

