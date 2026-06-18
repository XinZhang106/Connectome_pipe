function [cluster1, cluster2] = separate_2PxCluster(color_table)
T = table2array(color_table);
c1 = T(:, 1);  c2 = T(:, 2);

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
cluster1 = T(label == 'red', :);
cluster1 = array2table(cluster1, 'VariableNames',{'c1', 'c2', 'c3', 'fr'});
cluster2 = T(label== 'purple', :);
cluster2 = array2table(cluster2, 'VariableNames',{'c1', 'c2', 'c3', 'fr'});
end