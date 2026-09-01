function [im_idlist, folderNames] = upload_spd_multi(totalfolder,  std_str, user_name, z_scale, channel_arr)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%all folders in the folder
items = dir(totalfolder);
subfolders = items([items.isdir]);
subfolders = subfolders(~ismember({subfolders.name}, {'.', '..'}));
folderNames = {subfolders.name};
im_idlist = zeros([numel(folderNames), 1]);
for i = 1:numel(folderNames)
    fprintf('Uploading spinning disk %d of %d...\n', i, numel(folderNames));
    sub_full = fullfile(totalfolder, folderNames(i));
    im_idlist(i) = spd_upload(sub_full, std_str, user_name, z_scale, channel_arr);
end
end