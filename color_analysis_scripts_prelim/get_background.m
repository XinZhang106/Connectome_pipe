function bg = get_background(image_id, if_brain)
query = sprintf('image_id = %d', image_id);

fprintf('Getting the background of image %d...\n', image_id);
if (if_brain)
    data = fetch(sln_image.Image * sln_image.AxonInBrain & query, 'raw_image', 'background_roi', 'n_channels', 'n_slices');
else
    data = fetch(sln_image.Image*sln_image.RGCinRetina & query, 'raw_image', 'background_roi', 'n_channels', 'n_slices');
end
channel_N = data.n_channels;
slice = data.n_slices;
%measure the size of the background
bg_line = data.background_roi;
bg_d1 = abs(bg_line(1)-bg_line(2))+1;
bg_d2 = abs(bg_line(3)-bg_line(4))+1;
bg = zeros([bg_d1, bg_d2, slice, channel_N]);
dim = size(data.raw_image);
for s = 1:slice
    image_frame = data.raw_image(:, :, s, :);
    for c = 1: channel_N
        channelFrame = reshape(image_frame(:, :, :, c), dim(1), dim(2));
        bg(:, :, s, c) = channelFrame(bg_line(1):bg_line(2), bg_line(3):bg_line(4));
    end
end
end