function image_id = uploading_zMerge(ndfolder, real_folder, scope_name, user_name, z_scale, channel_arr, real_z)

%find original nd2 for most part of the meta file
ndName = dir(fullfile(ndfolder, '*.nd2'));
mergeName = dir(fullfile(real_folder, 'stitched.tif'));
if(numel(ndName)>1)
    error('Multiple .nd2 files in the foder %s cannot process\n', ndfolder);
end

if (~isfile(fullfile(ndfolder, ndName.name)))
    error('Cannot find .nd2 files in folder %s\n', ndfolder);
end
if (~isfile(fullfile(real_folder, mergeName.name)))
    error('Cannot find merged file in folder %s\n', real_folder);
end
meta_raw = BioformatsImage(char(fullfile(ndfolder,...
    ndName.name)));

meta = struct();
meta.sizeC = meta_raw.sizeC;
meta.sizeZ = real_z;

%some information is only in the real file
realpath = fullfile(real_folder, 'stitched.tif');
finfo = imfinfo(realpath);
%pick the first  frame
f1 = finfo(1);
meta.height = f1.Height;
meta.width = f1.Width;

%now saver the meta in the folde of real_folder where merged file is
%tifName = dir(fullfile(real_folder, 'stiched.tif'));
metapath = fullfile(real_folder, 'stitched_meta.mat');
save(metapath, "meta");
fprintf('Chimera meta file saved in %s\n', metapath);
mergeFPath  = fullfile(real_folder, mergeName.name);

%uploading function of its own
nPlanes = meta.sizeC * meta.sizeZ;
info = Tiff(mergeFPath,'r');
%H  = info.getTag('ImageLength');
%W  = info.getTag('ImageWidth');
so = double(info.getTag('StripOffsets'));
cls = class(info.read());          % 'single' here
info.close();

dataStart = min(so);

fid = fopen(mergeFPath,'r');
magic = fread(fid,2,'*char')';
fclose(fid);
machine = 'l'; if strcmp(magic,'MM'), machine = 'b'; end

fid = fopen(mergeFPath,'r',machine);
fseek(fid, dataStart, 'bof');
raw = fread(fid, meta.height*meta.width*nPlanes, ['*' cls]);
fclose(fid);

raw_image_interleaved = permute(reshape(raw, [meta.width, meta.height, nPlanes]), [2 1 3]);

fprintf('Loading image %d channels %d frames\n', meta.sizeC, meta.sizeZ);
key.raw_image = zeros(meta.height, meta.width,  meta.sizeZ, meta.sizeC, 'single');

for i = 1:meta.sizeC
    key.raw_image(:,:,:,i) = raw_image_interleaved(:,:, i:meta.sizeC:nPlanes);
end

fprintf('Image loaded %s\n', mergeFPath);

%insert
key.image_filename = mergeName.name;
[key.folder, ~, ~] = fileparts(mergeFPath);
key.creation_date = datestr(mergeName.datenum, 'yyyy-mm-dd');
if (mergeName.bytes>4294967295)
    key.size_in_bytes = 4294967295;
    fprintf('Warning: size of this image is larger than the 2^32, using the max instead.\n');
else
    key.size_in_bytes = file_info.bytes;
end
key.scope_name = scope_name;
key.user_name = user_name;
key.x_scale = meta_raw.pxSize(1);
key.y_scale = meta_raw.pxSize(2);
key.z_scale = z_scale;
key.width = meta.width;
key.height = meta.height;
key.n_channels = meta.sizeC;
key.n_slices = real_z;
key.zoom_factor = 1;
chan_options = {'ch1_type', 'ch2_type', 'ch3_type', 'ch4_type'};
for i = 1:meta.sizeC
    chanName = chan_options{i};
    key.(chanName) = channel_arr{i};
end
try
    insert(sln_image.Image, key);
catch ME
    rethrow (ME);
end

%get the new image id
image_id = fetch(sln_image.Image.get_db_match_nodaterestrict(mergeName));
fprintf('New image inserted into sln_image.Image: %s', mergeName.name);
fprintf('image id: %d\n', image_id);
end


% image_filename : varchar(128)
% folder : varchar(512) #folder from which it was imported, but likely has local parts of the path
% creation_date : date #from file when loaded. might not be right
% size_in_bytes : int unsigned # from file when loaded, used as part of a check for same files
% -> sln_lab.Scope
% -> sln_lab.User
% x_scale : float #microns per pixel
% y_scale : float #microns per pixel
% z_scale = NULL : float #microns per slice (null if 2D image)
% width : smallint unsigned
% height : smallint unsigned 
% n_channels : tinyint unsigned
% n_slices : smallint unsigned
% raw_image : blob@raw #the actual raw data 
% zoom_factor : float #read in from image metadata
% (ch1_type) -> [nullable] sln_image.ChannelType
% (ch2_type) -> [nullable] sln_image.ChannelType
% (ch3_type) -> [nullable] sln_image.ChannelType
% (ch4_type) -> [nullable] sln_image.ChannelType
% %}