%% stitch_zstacks.m
% Align two multi-channel confocal z-stacks in x-y using a rigid transform
% (rotation + translation, no scaling) estimated from 2-3 manually specified
% control-point pairs, then concatenate them along z.
%
% Output: ImageJ-readable hyperstack, [H, W, C, Z1+Z2], channels varying
% fastest then z. Regions with no data are filled with 0.
%
% Coordinate convention: points are [x y] = [column row], pixel units,
% pixel centres at integer values (MATLAB intrinsic coordinates).

clear; clc;

%% ------------------------- USER PARAMETERS -------------------------
file1   = "D:\programming\githubRepos\Connectome_pipe\zStich\s4_b5.tif";        % reference stack (defines output orientation)
file2   = "D:\programming\githubRepos\Connectome_pipe\zStich\s4_b4.tif";        % stack to be moved onto slice1
fileOut = 'stitched.tif';

nCh1 = 3;   % number of channels; leave [] to read from ImageJ metadata
nCh2 = 3;

% Control points: one row per pair, [x y]. Row i of p1 must correspond to
% the same physical feature as row i of p2. Use 2 or 3 pairs.
p1 = [ 1732  1155        % feature 1 in image 1
       358 1045 ];     % feature 2 in image 1

p2 = [ 1682 1080        % feature 1 in image 2
       336 940 ];     % feature 2 in image 2

% Z-stack reversal. Normal acquisition order is z1..zn. If a slice was
% mounted flipped, its z frames come out reversed relative to physical depth.
% Set the flag for whichever stack needs its z-order reversed before
% concatenation. (x-y orientation/flip is handled manually via the points.)
flipZ1 = true;               % reverse z-order of stack 1
flipZ2 = false;               % reverse z-order of stack 2

interpMethod    = 'linear';   % 'linear' | 'nearest' | 'cubic'
%% --------------------------------------------------------------------

%% Read stacks
[I1, C1, Z1] = read_stack(file1, nCh1);
[I2, C2, Z2] = read_stack(file2, nCh2);

% Reverse z-order where requested (dim 4 = z in the [H,W,C,Z] layout)
if flipZ1, I1 = flip(I1, 4); fprintf('Stack 1 z-order reversed.\n'); end
if flipZ2, I2 = flip(I2, 4); fprintf('Stack 2 z-order reversed.\n'); end

assert(C1 == C2, 'Channel count differs: %d vs %d.', C1, C2);
assert(isa(I1, class(I2)), 'Bit depth / class differs between the two stacks.');
C = C1;
[H1, W1, ~, ~] = size(I1);
[H2, W2, ~, ~] = size(I2);

fprintf('Stack 1: %d x %d, %d channels, %d slices\n', H1, W1, C, Z1);
fprintf('Stack 2: %d x %d, %d channels, %d slices\n', H2, W2, C, Z2);

%% Fit rigid transform mapping image-2 coordinates -> image-1 coordinates
assert(size(p1,1) == size(p2,1) && size(p1,2) == 2, 'p1 and p2 must be N x 2 with equal N.');
assert(size(p1,1) >= 2, 'Need at least 2 point pairs.');

[R, t, rmse, scaleCheck] = fit_rigid(p2, p1);

fprintf('\nRotation  : %+.3f deg\n', atan2d(R(2,1), R(1,1)));
fprintf('Translation: [%+.2f, %+.2f] px\n', t(1), t(2));
fprintf('Residual RMSE at control points: %.2f px\n', rmse);
if ~isnan(scaleCheck)
    fprintf('Inter-point distance ratio (img1/img2): %.4f  (should be ~1)\n', scaleCheck);
end

% affine2d uses the row-vector convention: [x y 1] * T
tform = affine2d([R.' [0;0]; t.' 1]);

%% Output canvas = union of both footprints, image 1 kept on its pixel grid
corners2 = [0.5      0.5;
            W2+0.5   0.5;
            W2+0.5   H2+0.5;
            0.5      H2+0.5];
cw = (R * corners2.' + t).';        % warped corners of image 2

padL = max(0, ceil(0.5 - min(cw(:,1))));
padR = max(0, ceil(max(cw(:,1)) - (W1 + 0.5)));
padT = max(0, ceil(0.5 - min(cw(:,2))));
padB = max(0, ceil(max(cw(:,2)) - (H1 + 0.5)));

outH = H1 + padT + padB;
outW = W1 + padL + padR;
Rout = imref2d([outH outW], ...
               [0.5 - padL, W1 + 0.5 + padR], ...
               [0.5 - padT, H1 + 0.5 + padB]);

fprintf('Output canvas: %d x %d (pad L/R/T/B = %d/%d/%d/%d)\n', ...
        outH, outW, padL, padR, padT, padB);

%% Place image 1 (no interpolation) and warp image 2
I1p = zeros(outH, outW, C, Z1, 'like', I1);
I1p(padT + (1:H1), padL + (1:W1), :, :) = I1;

I2w = zeros(outH, outW, C, Z2, 'like', I2);
for z = 1:Z2
    for c = 1:C
        I2w(:,:,c,z) = imwarp(I2(:,:,c,z), tform, interpMethod, ...
                              'OutputView', Rout, 'FillValues', 0);
    end
end

out  = cat(4, I1p, I2w);
Ztot = Z1 + Z2;

%% Write ImageJ hyperstack (channels fastest, then z)
% Integer stacks -> imwrite path. Floating-point (single/double) stacks
% -> Tiff-class path, because imwrite cannot write float TIFFs.
% Set forceUint16 = true to cast float data down to 16-bit instead.
forceUint16 = false;
 
if forceUint16 && ~isinteger(out)
    mx = max(out(:));
    if mx <= 1
    %% 
        warning('Float data max <= 1; scaling by 65535 before uint16 cast.');
        out = uint16(round(double(out) * 65535));
    else
        out = uint16(round(double(out)));   % assume integer-valued intensities
    end
    fprintf('Cast output to uint16.\n');
end
 
write_ij_hyperstack(fileOut, out, C, Ztot);
 
fprintf('\nWrote %s : %d x %d, %d channels, %d slices (%d pages), class %s\n', ...
        fileOut, outH, outW, C, Ztot, C*Ztot, class(out));









