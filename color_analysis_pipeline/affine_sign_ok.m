function ok = affine_sign_ok(A, slope_idx, tol)
% AFFINE_SIGN_OK  True if the slope diagonal entries of A are non-negative.
%   A         : F x F fitted affine linear part
%   slope_idx : indices of the diagonal entries that are SLOPES and must be >= 0
%               (e.g. [1 2] if features are [s23, s13, b23] and b23 is index 3)
%   tol       : small negative tolerance (e.g. -1e-9) to ignore numerical noise
%               near zero; default -1e-9 if omitted
%
% The b23 diagonal is intentionally NOT checked: a composite intercept can
% legitimately invert ordering between tissues (see reasoning in pipeline notes).

    if nargin < 3 || isempty(tol), tol = -1e-9; end
    dA = diag(A);
    ok = all(dA(slope_idx) >= tol);
end