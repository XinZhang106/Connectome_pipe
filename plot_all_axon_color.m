function plot_all_axon_color(animal_id, buffer_folder, figure_handle)
%plot the axon average color by frame of all the axons from 1 animal, save the
%   Detailed explanation goes here
arguments (Input)
    animal_id
    buffer_folder
    figure_handle = {};
end

marker_selection = ["o", "+", "*", ".", 'x', "square", "diamond", "pentagram", "hexgram"];
%how many difference brain regions are in this mouse
qs = sprintf('animal_id = %d', animal_id);
all_axons = fetch(sln_cell.Axon * sln_image.AxonImageAssociation & qs, 'brain_region');
brain_reg = unique({all_axons.brain_region});
fprintf('Mouse %d have axons in %d different brain regions...\n', animal_id, numel(brain_reg));

%export the averages first
export_spd_color(animal_id, true, false, buffer_folder);

cfs = dir(buffer_folder);
cfs = cfs(~[cfs.isdir]);
fprintf('Total axonal image number %d\n', numel(cfs));

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

    if (isempty(figure_handle))
        figure_handle = figure; % Create a new figure if none is provided
        hold on; % Hold on to plot multiple axons in the same figure


        % Plot the axon color for the current image
        scatter3(tdata.c1, tdata.c2, tdata.c3, 'Marker', this_marker);
    else
        scatter3(figure_handle, tdata.c1, tdata.c2, tdata.c3, 'Marker', this_marker);
    end
end


hold off;

end