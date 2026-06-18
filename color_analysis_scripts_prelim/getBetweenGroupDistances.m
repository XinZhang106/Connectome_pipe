function [betweenDists, betweenPairs] = getBetweenGroupDistances(distMat, groups)
% getBetweenGroupDistances
%   Returns all pairwise distances between images that belong to
%   DIFFERENT groups.
%
% INPUTS:
%   distMat — NxN symmetric distance matrix
%   groups  — cell array of index vectors, e.g. {[1,2], [3,4], [5,6,7]}
%
% OUTPUTS:
%   betweenDists — vector of between-group distances
%   betweenPairs — Mx2 matrix where each row is the (i,j) index pair
%                   corresponding to each distance in betweenDists
%
% EXAMPLE:
%   groups = {[1,2], [3,4], [5,6,7]};
%   [dists, pairs] = getBetweenGroupDistances(distMat, groups);
 
nGroups = length(groups);
betweenDists = [];
betweenPairs = [];
 
for g1 = 1:nGroups-1
    for g2 = g1+1:nGroups
        members1 = groups{g1};
        members2 = groups{g2};
        for i = 1:length(members1)
            for j = 1:length(members2)
                idx1 = members1(i);
                idx2 = members2(j);
                betweenDists(end+1, 1) = distMat(idx1, idx2);
                betweenPairs(end+1, :) = [idx1, idx2];
            end
        end
    end
end
 
fprintf('Found %d between-group pairs across %d groups\n', length(betweenDists), nGroups);
end