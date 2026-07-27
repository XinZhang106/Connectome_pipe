function [R, t, rmse, scaleCheck] = fit_rigid(src, dst)
% Least-squares rigid fit (Kabsch) such that  R*src' + t  ~=  dst'.
% Pure rotation + translation, det(R) forced to +1 (no reflection).
cs = mean(src, 1);
cd = mean(dst, 1);
qs = src - cs;
qd = dst - cd;

H = qs.' * qd;
[U, ~, V] = svd(H);
R = V * diag([1, sign(det(V*U.'))]) * U.';   % force det(R) = +1
t = cd.' - R * cs.';

res  = (R * src.' + t).' - dst;
rmse = sqrt(mean(sum(res.^2, 2)));

% Sanity check on scale using the first two points
if size(src,1) >= 2
    scaleCheck = norm(dst(2,:) - dst(1,:)) / norm(src(2,:) - src(1,:));
else
    scaleCheck = NaN;
end
end