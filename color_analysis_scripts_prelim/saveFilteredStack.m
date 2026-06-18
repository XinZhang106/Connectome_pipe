function outPath = saveFilteredStack(img, mask, outFolder, baseName)
% img:       [H x W x Z x C]
% mask:      [H x W x Z]
% outFolder: destination folder (created if missing)
% baseName:  filename stem; saved as <baseName>_filtered.tif
%
% Page order written: Z1C1, Z2C1, ..., ZnC1, Z1C2, ...

    assert(isequal(size(img,1:3), size(mask,1:3)), ...
        'img and mask must agree on H, W, Z.');

    if ~exist(outFolder, 'dir'); mkdir(outFolder); end

    masked  = img .* cast(logical(mask), 'like', img);
    outPath = fullfile(outFolder, [baseName '_filtered.tif']);
    if exist(outPath, 'file'); delete(outPath); end  % avoid appending to old file

    [~, ~, nZ, nC] = size(masked);
    for c = 1:nC
        for z = 1:nZ
            imwrite(masked(:,:,z,c), outPath, ...
                'WriteMode', 'append', 'Compression', 'none');
        end
    end
end