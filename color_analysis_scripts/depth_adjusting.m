function [adj_flo, bg_byfra] = depth_adjusting(spd_imid, if_brain)
%adjusting the fluorescence intensity by the depth, if any
%Overal frame fluorescence could change dramatically with depth, thus.. adjust it
arguments
    spd_imid
    if_brain = true;
end
querystr = sprintf('image_id = %d', spd_imid);
fprintf('Loading image, may take a while....\n');
if (if_brain)
    unadj_flo = fetch(sln_image.Image * sln_image.AxonInBrain & querystr,...
        'raw_image', 'background_roi', 'pixel_color');
else
    unadj_flo = fetch(sln_image.Image * sln_image.RGCinRetina & querystr,...
        'raw_image', 'background_roi', 'color_pixel');
end

%calculate the background average in each frame of each channel
dim = size(unadj_flo.raw_image);
channel_N = dim(end);
bg_byfra = zeros([dim(end-1), channel_N]);
bg_line = unadj_flo.background_roi;
for f = 1:dim(end-1)
    image_frame = reshape(unadj_flo.raw_image(:, :, f, :), dim(1), dim(2), dim(end));
    bg_numbers = image_frame(bg_line(1):bg_line(2), bg_line(3):bg_line(4), :);
    bg_byfra(f, :) = mean(bg_numbers, [1,2]);
end

%max_byc = zeros([1, channel_N]);
%max_byc = max(bg_byfra,[], 1);
%aplify_indx = max_byc./bg_byfra;
fprintf('Intensity depth adjusted!\n');
adj_flo = {};
for j = 1:numel(unadj_flo.pixel_color)
    if (if_brain)
        signal_frame =  double(unadj_flo.pixel_color{j});
    else
        signal_frame = double(unadj_flo.color_pixel{j});
    end
    for c =1:channel_N
        adj_flo{j}(:, c) = signal_frame(:, c)./bg_byfra(j, c);
    end
end
end