function filtered_pixels= GuassianBgFilt(bgstd, frame_n, channel_n, image_id, if_brain, times_bgstd)
query = sprintf('image_id = %d', image_id);

if(if_brain)
    data = fetch(sln_image.AxonInBrain & query, 'pixel_color');
else
    data = fetch(sln_image.RGCinRetina & query, 'color_pixel');
    data.pixel_color = data.color_pixel;
    data = rmfield(data, 'color_pixel');
end

fprintf('Filtering the pixel by std of background')
%pixel color is already subtracted by mean so only need to pass > 3*std
%filt_flag = zeros([frame_n, channel_n]);
filtered_pixels = [];
for i = 1:frame_n
    unpack = data.pixel_color{i};
    [pixel_n, ~] = size(unpack);
    filt_flag = zeros([pixel_n, channel_n]);
    for j = 1:channel_n
        filt_flag(:, j) = (unpack(:, j)>times_bgstd*bgstd(i, j));
    end
    total_filt = find(all(filt_flag, 2));
    filtered_pixels = [filtered_pixels; unpack(total_filt, :)];

end

end