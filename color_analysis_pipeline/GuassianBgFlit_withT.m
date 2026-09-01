function filtered = GuassianBgFlit_withT(colorTable, bgstd, channel_n, times_std)
existingframes = unique([colorTable.fr]);
filtered = [];
%frameflag = [];
for i = 1:numel(existingframes)
    frame = existingframes(i);
    frameinx = (colorTable.fr == frame);
    framepixelraw = table2array(colorTable(frameinx, 1:3));
    
    filt_flag = zeros([height(framepixelraw), channel_n]);
    % filt_flag(:, j) = (unpack(:, j)>times_bgstd*bgstd(i, j));
    for j = 1:channel_n
     filt_flag(:, j) = framepixelraw(:, j)>times_std * bgstd(frame, j);
    end
    total_filt = find(any(filt_flag, 2));
    frame_pixel_filted = framepixelraw(total_filt, :);
    filtered = [filtered; [frame_pixel_filted repmat(frame, height(frame_pixel_filted), 1)]];
end
end