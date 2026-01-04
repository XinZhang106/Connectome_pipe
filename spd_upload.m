function [image_id] = spd_upload(folder, std_str, user_name, z_scale, channel_arr)
%upload spnning disk images that have chromatic abberation which are corrected
arguments
    folder
    std_str
    user_name = "Xin";
    z_scale = 0.9;
    channel_arr = {3,3,3}
end
files = dir(folder);
files = files(~[files.isdir]);
image_id = 0;

%first loop creating metatdata
for j = 1:numel(files)
    if (endsWith(files(j).name, '.nd2'))
        %load files to get metadata
        meta = BioformatsImage(char(fullfile(folder, files(j).name)));
        %todo change this to save saving space
        sufix = strrep(std_str, '.tif', '_meta.mat');
        metapath = strrep(files(j).name, '.nd2',  sufix);
        metapath = fullfile(folder, metapath);
        save(metapath, "meta");
        break;
    end

end

for i = 1:numel(files)
    %upload the image
    if (endsWith(files(i).name, std_str))
        fprintf('Image found: %s\n', files(i).name);
        filepath = fullfile(folder, files(i).name);
        sln_image.Image.LoadFromFilewithStructuralInput(filepath,user_name, ...
            "Spinning Disk", channel_arr, z_scale, true);
        %get the image id
        fileinfo = dir(filepath);
        im_match = fetch(sln_image.Image.get_db_match_nodaterestrict(fileinfo));
        image_id = im_match.image_id;

        % if (isfield(imentity, 'brain_region'))%this spinning disk image is an axon
        %     entity_id = sln_cell.Axon.add_axon(imentity.brain_region, imentity.side, imentity.animal_id);
        % else
        %     entity_id = imentity.cell_unid; %cell should be created when confocal images are uploaded
        %     %creating a link in the sln_image.RetinalCellImage
        %     link.cell_unid = entity_id;
        %     link.image_id = image_id;
        %     insert(sln_image.RetinalCellImage, link);
        % end
        break; %discontinuing the loop if the tif file has been uploaded
    end
end

if (image_id == 0)
    error('No file with %s ending found in the folder %s!\n', std_str, folder);
end

% fprintf('Image inserted: %d\n', image_id);
% if (isfield(imentity, 'brain_region'))
%     if (~isfield(imeneity, 'axon_id'))
%         fprintf('Axon inserted: %d\n', entity_id);
%     end
% else
%     fprintf('Image linked to cell %d\n', entity_id);
% end

end