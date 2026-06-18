function zproj = maxZProjection(mask)
    arguments
        mask   % filename (char/string) OR a 3D array directly
    end

    if ischar(mask) || isstring(mask)
        info    = imfinfo(mask);
        nFrames = numel(info);
        stack   = zeros(info(1).Height, info(1).Width, nFrames, 'uint8');
        for k = 1:nFrames
            stack(:,:,k) = imread(mask, k);
        end
    else
        stack = mask;
    end

    zproj = max(stack, [], 3);
end