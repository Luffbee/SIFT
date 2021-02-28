function H = ransac_homography(u, v, T, eps)
n = min(size(u, 1), size(v, 1));
best_match = 0;
for i = 1:T
    idx = randsample(1:n, 4);
    h = calc_homography(u(idx, :), v(idx, :));
    match = validate_homography(u(1:n, :), h, v(1:n, :), eps);
    if match > best_match
        best_match = match;
        H = h;
    end
end
end

