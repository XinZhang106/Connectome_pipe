function ok = perm_satisfies(perm, constr)
% PERM_SATISFIES  True if assignment 'perm' respects all prior-knowledge constraints.
%   perm : 1 x n, perm(i) = RGC index matched to axon i  (match_permute convention)
%   constr.rgc   : 1 x m vector of constrained RGC indices
%   constr.axons : 1 x m cell, constr.axons{j} = allowed axon indices for constr.rgc(j)

    ok = true;
    for j = 1:numel(constr.rgc)
        r = constr.rgc(j);
        axon_of_r = find(perm == r);        % which axon this RGC got assigned to
        if isempty(axon_of_r) || ~ismember(axon_of_r, constr.axons{j})
            ok = false;
            return;
        end
    end
end