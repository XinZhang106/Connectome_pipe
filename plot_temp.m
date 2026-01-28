animal_id = 4088;
buffer_folder ="D:\programming\githubRepos\Connectome_pipe\test\pixel\pixel_filtered\top10";

%plotting start
marker_selection = ["+", "*", "<", 'x', ".", "pentagram", "hexgram"];
%how many difference brain regions are in this mouse
qs = sprintf('animal_id = %d', animal_id);
all_axons = fetch(sln_cell.Axon * sln_image.AxonImageAssociation & qs, 'brain_region');
brain_reg = unique({all_axons.brain_region});
fprintf('Mouse %d have axons in %d different brain regions...\n', animal_id, numel(brain_reg));

cfs = dir(buffer_folder);
cfs = cfs(~[cfs.isdir]);
colors = turbo(numel(cfs));
fprintf('Total axonal image number %d\n', numel(cfs));
%figure_handle = figure; % Create a new figure if none is provided
sum_data.image_id = zeros([numel(cfs), 1]);
sum_data.cmass = zeros([numel(cfs), 3]);
mylegend = cell(numel(cfs, 1));
for i = 1:numel(cfs)
    %read table
    tpath = fullfile(buffer_folder, cfs(i).name);
    tdata = readtable(tpath);

    tokens = regexp(cfs(i).name, '^(\d+)_', 'tokens');
    image_id = str2double(tokens{1}{1});
    axon_idx = [all_axons.image_id] == image_id;
    if (sum(axon_idx)==0)
        warning('cannot find associated axons for image %d\n', image_id);
    end

    this_br = all_axons(axon_idx).brain_region;
    this_marker = marker_selection(find(strcmp(this_br, brain_reg)));    
    hold on; % Hold on to plot multiple axons in the same figure


    % Plot the axon color for the current image
    scatter3(tdata.c1, tdata.c2, tdata.c3, 20, 'Marker', this_marker, 'MarkerFaceAlpha', 0.01, 'MarkerEdgeAlpha',0.01, ...
        'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', colors(i, :), ...
        'HandleVisibility', 'off');

    % x = tdata.c1./tdata.c3;
    % y = tdata.c2./tdata.c3;
    % scatter(x, y, 'Marker', this_marker, 'MarkerFaceAlpha', 0.3, 'MarkerEdgeAlpha',0.1, ...
    %     'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', colors(i, :), 'HandleVisibility', 'off');
    sum_data.image_id(i) = image_id;
    sum_data.cmass(i, 1) = mean(tdata.c1, "all");
    sum_data.cmass(i, 2) = mean(tdata.c2, "all");
    sum_data.cmass(i, 3) = mean(tdata.c3, "all");
    l =  sprintf('im %d -- axon %d', image_id, all_axons(axon_idx).axon_id);
    mylegend{i} = l;
end


for i = 1:numel(cfs)

    scatter3(sum_data.cmass(i, 1), sum_data.cmass(i,2), sum_data.cmass(i,3),50, ...
        'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', colors(i, :));
    % scatter(sum_data.cmass(i, 1)/sum_data.cmass(i, 3), sum_data.cmass(i, 2)/sum_data.cmass(i, 3), ...
    %     50, 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', colors(i, :));
end
legend(mylegend);
%output marker for each brain region
for i = 1:numel(brain_reg)
    fprintf('Marker: %s ---- %s\n', marker_selection(i), brain_reg{i})
end

hold off;

