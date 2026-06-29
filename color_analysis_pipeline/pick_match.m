function [best, rank_found, diag_info] = pick_match(results, constr, slope_idx, tol)
% PICK_MATCH  Rank by score; return highest-ranked permutation satisfying BOTH
%             the affine slope-diagonal sign filter AND the topographic constraint.
%
%   results   : struct array from match_permute (.perm, .A, .score, ...)
%   constr    : struct with .rgc and .axons (see perm_satisfies); pass [] to skip
%   slope_idx : diagonal indices that must be >= 0 (e.g. [1 2] for [s23 s13 b23])
%   tol       : sign tolerance for affine_sign_ok (optional; default -1e-9)
%
%   best       : chosen results entry, or [] if none qualifies
%   rank_found : its rank in the score-sorted list (1 = best score); NaN if none
%   diag_info  : struct with fields explaining what happened:
%                .n_total          number of permutations
%                .n_sign_pass      how many passed the sign filter
%                .n_both_pass      how many passed sign AND constraint
%                .top_score        best score overall (rank 1, unfiltered)
%                .score_gap        best.score - top_score (0 if best is rank 1)

    if nargin < 4 || isempty(tol), tol = -1e-9; end

    scores = [results.score];
    [sorted_scores, order] = sort(scores, 'ascend');   % best first
    nP = numel(order);

    n_sign_pass = 0;
    n_both_pass = 0;
    best = [];
    rank_found = NaN;

    for r = 1:nP
        idx = order(r);

        sign_ok = affine_sign_ok(results(idx).A, slope_idx, tol);
        if sign_ok, n_sign_pass = n_sign_pass + 1; end

        if isempty(constr)
            constr_ok = true;
        else
            constr_ok = perm_satisfies(results(idx).perm, constr);
        end

        if sign_ok && constr_ok
            n_both_pass = n_both_pass + 1;
            if isempty(best)            % first (= highest-ranked) qualifier
                best = results(idx);
                rank_found = r;
            end
        end
    end

    diag_info = struct( ...
        'n_total',     nP, ...
        'n_sign_pass', n_sign_pass, ...
        'n_both_pass', n_both_pass, ...
        'top_score',   sorted_scores(1), ...
        'score_gap',   NaN);

    if ~isempty(best)
        diag_info.score_gap = best.score - sorted_scores(1);
        if rank_found > 1
            warning('pick_match:notTopRanked', ...
                ['Chosen match is rank %d of %d (score gap %.4g above best). ' ...
                 'Top-scoring permutation was rejected by sign and/or constraint ' ...
                 '— inspect whether the affine overfit or the constraint conflicts.'], ...
                rank_found, nP, diag_info.score_gap);
        end
    else
        warning('pick_match:noneQualify', ...
            ['No permutation satisfied both the sign filter and the constraint ' ...
             '(%d of %d passed sign; %d passed both). Returning empty.'], ...
            n_sign_pass, nP, n_both_pass);
    end
end