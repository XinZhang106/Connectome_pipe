function [I, C, Z] = read_stack(fname, nChUser)
% Read a multi-page TIFF into [H, W, C, Z]; assumes channels vary fastest.
info   = imfinfo(fname);
nPages = numel(info);

C = [];
if isfield(info(1), 'ImageDescription') && ~isempty(info(1).ImageDescription)
    tok = regexp(info(1).ImageDescription, 'channels=(\d+)', 'tokens', 'once');
    if ~isempty(tok), C = str2double(tok{1}); end
end
if ~isempty(nChUser), C = nChUser; end     % user value overrides metadata
if isempty(C), C = 1; end

assert(mod(nPages, C) == 0, ...
    '%s: %d pages is not divisible by %d channels.', fname, nPages, C);
Z = nPages / C;

probe = imread(fname, 1);
I = zeros(info(1).Height, info(1).Width, C, Z, class(probe));
k = 0;
for z = 1:Z
    for c = 1:C                 % channels vary fastest
        k = k + 1;
        I(:,:,c,z) = imread(fname, k);
    end
end
end