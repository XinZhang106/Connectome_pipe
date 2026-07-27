function results = match_permute(X_rgc, Y_axon, w)
% MATCH_PERMUTE  Score every RGC->axon assignment by affine fit + brain-space deviation.
%
% Inputs:
%   X_rgc : n x F  RGC (retina) features, one row per RGC
%   Y_axon: n x F  axon (brain) features, one row per axon, FIXED order
%   w     : 1 x F  per-feature brain-space scale, computed ONCE outside, fixed
%
% Output (struct array, one entry per permutation):
%   results(k).perm   : 1 x n  perm; RGC perm(i) is matched to axon i
%   results(k).A      : F x F  fitted affine linear part
%   results(k).b      : 1 x F  fitted affine offset
%   results(k).d      : n x 1  per-axon balanced deviation (from proj_dev)
%   results(k).score  : scalar grouping score (norm(d)); smaller = better
%
% Returns 0 (and warns) if n is too small to fit the affine with any residual
% left to discriminate permutations. Needs n >= F+2.

    [n, F] = size(Y_axon);

    if n < F + 2
        warning('match_permute:insufficientPairs', ...
            ['n = %d pairs is insufficient for an F = %d affine fit with ' ...
             'discriminating residual (need n >= %d). Returning 0.'], ...
            n, F, F + 2);
        results = 0;
        return;
    end

    P  = perms(1:n);            % all n! permutations, each row a perm
    nP = size(P, 1);

    results = struct('perm', cell(nP,1), 'A', [], 'b', [], 'd', [], 'score', []);
    fprintf('Starting permutating, total possibilities %d\n', nP);

    for k = 1:nP
        p  = P(k, :);
        Xp = X_rgc(p, :);                 % RGCs reordered to align with axons

        Xa = [Xp, ones(n,1)];             % n x (F+1)
        M  = Xa \ Y_axon;                 % (F+1) x F  least squares
        A  = M(1:F, :).';                 % F x F
        b  = M(F+1, :);                   % 1 x F

        d  = proj_dev(Y_axon, Xp, A, b, w);   % n x 1

        results(k).perm  = p;
        results(k).A     = A;
        results(k).b     = b;
        results(k).d     = d;
        results(k).score = norm(d);
    end
    
end