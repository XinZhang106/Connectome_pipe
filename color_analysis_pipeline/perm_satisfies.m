function ok = perm_satisfies(perm, constr)
% PERM_SATISFIES  True if assignment 'perm' respects axon->RGC constraints.
%   perm : 1 x n, perm(i) = RGC index matched to axon i
%   constr.axon : 1 x m vector of constrained axon indices
%   constr.rgc  : 1 x m cell, constr.rgc{j} = allowed RGCs for axon constr.axon(j)

    ok = true;
    for j = 1:numel(constr.axon)
        a = constr.axon(j);                 % the actual axon index
        rgc_of_a = perm(a);                 % RGC assigned to that axon
        if ~ismember(rgc_of_a, constr.rgc{j})
            ok = false;
            return;
        end
    end
end