function [d, distscale] = proj_dev(Y_axon, X_rgc, A, b, w)
% AXONDIST  Feature-balanced distance in brain space between observed axon
%           features and the RGC features projected through the affine (A,b).
%
% Inputs:
%   Y_axon : N x F  observed axon features in brain space
%   X_rgc  : N x F  RGC (retina) features, same rows correspond to Y_axon
%   A      : F x F  affine linear part (maps retina -> brain)
%   b      : 1 x F  affine offset (row vector)
%   w      : 1 x F  per-feature brain-space scale (e.g. axon-population std
%                   or median), computed ONCE outside and held fixed across
%                   all permutations so distances stay comparable
%
% Output:
%   d      : N x 1  per-row feature-balanced Euclidean distance in brain space

    Yhat = X_rgc * A.' + b;          % N x F   projected axons in brain space
    R    = (Yhat - Y_axon) ./ w;     % N x F   residual, balanced per feature
    d    = sqrt(sum(R.^2, 2));       % N x 1   distance per axon
    distscale = norm(d);
end