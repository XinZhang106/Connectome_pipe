function [bigcluster, smallcluster] = separate_2PxCluster(color_table, ifc1c2)
T = table2array(color_table);
if(ifc1c2)
    c1 = T(:, 1);  c2 = T(:, 2);
    fprintf('Separating by raw c1 and c2...\n');
else
    c1 = T(:, 1); c2 = T(:, 3);
    fprintf('Separating by raw c1 and c3...\n');
end


% --- Feature: angle from origin ---

theta = atan2(c2, c1);                       % radians

% --- 2-component GMM on theta ---
rng(0);
gm = fitgmdist(theta, 2, 'Replicates', 5);

% Sort components so 1 = shallow (red), 2 = steep (purple)
[mu_sorted, order] = sort(gm.mu);
post = posterior(gm, theta);
post = post(:, order);
p_red    = post(:, 1);
p_purple = post(:, 2);

% --- Hard assignment with ambiguous zone ---
CONF = 0.9;
label = strings(size(c1));
label(:)            = "ambiguous";
label(p_red    > CONF) = "red";
label(p_purple > CONF) = "purple";

%finding out which is the bigger cluster
redcluster = T(label == 'red', :);
purplecluster =  T(label== 'purple', :);
if (numel(redcluster)>numel(purplecluster))
    bigcluster = redcluster;
    smallcluster = purplecluster;
else
    bigcluster = purplecluster;
    smallcluster = redcluster;
end
bigcluster = array2table(bigcluster, 'VariableNames',{'c1', 'c2', 'c3', 'fr'});
smallcluster = array2table(smallcluster, 'VariableNames',{'c1', 'c2', 'c3', 'fr'});
end