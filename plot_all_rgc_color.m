function sum_data = plot_all_rgc_color(animal_id, buffer_folder)
%plot the axon average color by frame of all the axons from 1 animal, save the
%   Detailed explanation goes here
arguments (Input)
    animal_id
    buffer_folder
end

qs = sprintf('animal_id = %d', animal_id);
all_rgcs = fetch(sln_cell.RetinalCell * sln_image.RetinalCellImage*sln_image.RGCinRetina & qs);

%brain_reg = unique({all_rgcs.brain_region});
fprintf('Mouse %d have rgc %d spinning images ...\n', animal_id, numel(all_rgcs));

%export the averages first
%export_spd_color(animal_id, true, false, buffer_folder);

cfs = dir(buffer_folder);
cfs = cfs(~[cfs.isdir]);
sum_data.image_id = zeros([numel(cfs), 1]);
sum_data.cmass = zeros([numel(cfs), 5]);
colors = turbo(numel(cfs));
%fprintf('Total axonal image number %d\n', numel(cfs));

hold on; % Hold on to plot multiple axons in the same figure
mylegend = cell(numel(sum_data.image_id), 1);
for i = 1:numel(cfs)
    %read table
    tpath = fullfile(buffer_folder, cfs(i).name);
    tdata = readtable(tpath);

    tokens = regexp(cfs(i).name, '^(\d+)_', 'tokens');
    image_id = str2double(tokens{1}{1});

    sum_data.image_id(i) = image_id;
    A = table2array(tdata);
    A_filtered = A(~any(A == 0, 2), :);
    % rowSum = sum(A_filtered, 2);

    % N = size(A_filtered,1);
    % k = ceil(0.1 * N);
    % [~, idx] = sort(rowSum, 'descend');
    % topQuarterRows = A_filtered(idx(1:k), :);
    % topnorm1 = topQuarterRows(:, 1)./topQuarterRows(:, 3);
    % topnorm2 = topQuarterRows(:, 2)./topQuarterRows(:, 3);

    sum_data.cmass(i, 1) = mean(A_filtered(:, 1), 'all');
    sum_data.cmass(i, 2) = mean(A_filtered(:, 2), 'all');
    sum_data.cmass(i, 3) = mean(A_filtered(:, 3), 'all');
    norm1 =A_filtered(:, 1) ./ A_filtered(:, 3);
    norm2 = A_filtered(:, 2)./A_filtered(:, 3);
    sum_data.cmass(i, 4) = mean(norm1, 'all');
    sum_data.cmass(i,5) = mean(norm2, 'all');
    rgc_idx = [all_rgcs.image_id] == image_id;
    l =  sprintf('im %d -- cell %d', image_id, all_rgcs(rgc_idx).cell_unid);
    mylegend{i} = l;
    % scatter3(tdata.c1, tdata.c2, tdata.c3, 'MarkerFaceAlpha', 0.01, 'MarkerEdgeAlpha',0.01, ...
    %     'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', colors(i, :), ...
    %     'HandleVisibility', 'off');
    %  scatter3(sum_data.cmass(i, 1), sum_data.cmass(i,2), sum_data.cmass(i,3),50, ...
    %     'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', colors(i, :));
    x = sum_data.cmass(i, 1)/sum_data.cmass(i, 3);
    y = sum_data.cmass(i, 2)/sum_data.cmass(i, 3);
    scatter(x,y, 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', colors(i, :));

    % h = scatter(norm1, norm2,  'MarkerFaceAlpha', 0.05, 'MarkerEdgeAlpha',0.05,...
    %     'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', colors(i, :));
    % h.HandleVisibility = 'off';
    %scatter(sum_data.cmass(i, 4),  sum_data.cmass(i,5),  'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', colors(i, :));

    % scatter(mean(topnorm1)*2, mean(topnorm2)*2, 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', colors(i, :));
    % h=scatter(topnorm1, topnorm2,  'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', colors(i, :),...
    %     'MarkerFaceAlpha', 0.01, 'MarkerEdgeAlpha',0.01);
    % h.HandleVisibility = 'off';

end

legend(mylegend);
hold off
end