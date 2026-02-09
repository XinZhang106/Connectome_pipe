function rgc_spd_assign_by_table(rgc_t)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%check if the input table has all columns and correctedly named
columns = {'cell_unid', 'spd_im_id', 'spd_folder'};
tableV = rgc_t.Properties.VariableNames;
for i = 1:numel(columns)
    if (~ismember(columns{i}, tableV))
        error('Column %d %s not found in input table!\n', i, columns{i});
    end
end

for j = 1:height(rgc_t)
    %folder_fs = get_files_of_folder(rgc_t.spd_folder(j));
    mask = fullfile(rgc_t.spd_folder(j), 'mask.tif');
    background = fullfile(rgc_t.spd_folder(j), 'background.roi');
    if ~isfile(mask)
        error('Mask file not found: %s\n', mask);
    end
    if ~isfile(background)
        error('Background file not found: %s\n', background);
    end

    sln_image.RGCinRetina.assign_rgc_in_retina(rgc_t.spd_im_id(j), rgc_t.cell_unid(j), ...
        background, mask);
    
    fprintf('Color extracted from spinning disk image %d, cell %d\n', rgc_t.spd_im_id(j), rgc_t.cell_unid(j));


end
end