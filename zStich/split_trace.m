%% split_traces.m
% Split a merged SNT .traces file into two per-slice .traces files, reversing
% the rigid merge so each path lands in its original slice's coordinate frame.
% Only <path> elements are transformed/split; run "Fill Out Paths" natively in
% SNT on each output afterwards to regenerate masks (no resampling distortion).
%
% Forward merge convention (from stitch_zstacks.m):
%   slice1 pixel (x,y) -> merged (x+padL, y+padT)          [pasted, not warped]
%   slice2:  merged = R*orig' + t   (t includes the pad shift, padded frame)
% Inverse:
%   slice1: orig = merged - [padL padT]
%   slice2: orig = R' * (merged - t)
%
% Slice membership is decided by z-plane (SNT z is 0-based).

clear; clc;

%% ------------------------- USER PARAMETERS -------------------------
fileIn    = "D:\programming\githubRepos\Connectome_pipe\zStich\stitched.traces";      % merged traces (may be gzipped or plain XML)
fileOut1  = 'D:\programming\githubRepos\Connectome_pipe\zStich\s4b4.traces';        % output for slice 1 (lower z)
fileOut2  = 'D:\programming\githubRepos\Connectome_pipe\zStich\s4b5.traces';        % output for slice 2 (upper z)

% --- transform from the stitch run (re-run stitch_zstacks.m and copy here) ---
p1 = [ 1732  1155        % feature 1 in image 1
       358 1045 ];     % feature 2 in image 1

p2 = [ 1682 1080        % feature 1 in image 2
       336 940 ];     % feature 2 in image 2
[R, t, rmse, scaleCheck] = fit_rigid(p2, p1);
% R    = [ 1 0; 0 1 ];    % 2x2 rotation used to warp slice2 into merged frame
% t    = [ 0; 0 ];        % 2x1 translation (padded frame), column vector
padL = 0;               % left pad added to slice1
padR = 61;
padT = 0;  
padB = 114;% top  pad added to slice1

% --- z split (SNT 0-based plane indices) ---
z1_max = 38;            % planes 0..z1_max -> slice1 ; planes > z1_max -> slice2

% --- original slice dimensions, for the rewritten <imagesize> headers ---
W1 = 2044; H1 = 2048; D1 = z1_max + 1;              % slice1 (adjust if flipped)
W2 = 2044; H2 = 2048; D2 = 45;        % slice2

% --- how to handle a path that crosses the z seam ---
straddlePolicy = 'bynode';   % 'error' | 'majority' | 'bynode'
%   'error'    : stop and list offending paths (safest; decide manually)
%   'majority' : assign whole path to whichever slice holds most of its nodes
%   'bynode'   : split the path itself at the seam into two partial paths
%% --------------------------------------------------------------------

%% Read (gunzip if needed) and parse
xmlText = read_maybe_gzip(fileIn);

tmp = [tempname '.xml'];
fid = fopen(tmp, 'w', 'n', 'UTF-8');  fwrite(fid, xmlText, 'char');  fclose(fid);
doc = xmlread(tmp);  delete(tmp);

root = doc.getDocumentElement();      % <tracings>
assert(strcmp(char(root.getNodeName()), 'tracings'), 'Root is not <tracings>.');

paths = root.getElementsByTagName('path');
nPaths = paths.getLength();
fprintf('Found %d <path> elements.\n', nPaths);

%% Classify each path by z, detect straddlers
Rt = R.';                              % inverse rotation (R is orthonormal)
assign = zeros(nPaths,1);              % 1 -> slice1, 2 -> slice2, 0 -> straddle
straddlers = [];
for k = 0:nPaths-1
    p = paths.item(k);
    pts = p.getElementsByTagName('point');
    zvals = zeros(pts.getLength(),1);
    for j = 0:pts.getLength()-1
        zvals(j+1) = str2double(char(pts.item(j).getAttribute('z')));
    end
    inS1 = all(zvals <= z1_max);
    inS2 = all(zvals >  z1_max);
    if inS1,      assign(k+1) = 1;
    elseif inS2,  assign(k+1) = 2;
    else,         assign(k+1) = 0;  straddlers(end+1) = k; %#ok<AGROW>
    end
end
fprintf('slice1 paths: %d | slice2 paths: %d | straddling: %d\n', ...
        nnz(assign==1), nnz(assign==2), numel(straddlers));

if ~isempty(straddlers)
    switch straddlePolicy
        case 'error'
            ids = arrayfun(@(kk) char(paths.item(kk).getAttribute('id')), ...
                           straddlers, 'uni', 0);
            error(['Paths cross the z=%d seam (ids: %s). Set straddlePolicy ' ...
                   'to ''majority'' or ''bynode'', or fix these in SNT.'], ...
                   z1_max, strjoin(ids, ', '));
        case 'majority'
            for kk = straddlers
                p = paths.item(kk);
                pts = p.getElementsByTagName('point');
                zv = zeros(pts.getLength(),1);
                for j = 0:pts.getLength()-1
                    zv(j+1) = str2double(char(pts.item(j).getAttribute('z')));
                end
                assign(kk+1) = 1 + (mean(zv > z1_max) > 0.5);
            end
        case 'bynode'
            error('bynode splitting is not enabled in this build; use majority or fix in SNT.');
    end
end

%% Build two output documents by cloning + transforming
doc1 = build_slice_doc(doc, root, paths, assign, 1, Rt, t, padL, padT, z1_max, W1,H1,D1, 'slice1');
doc2 = build_slice_doc(doc, root, paths, assign, 2, Rt, t, padL, padT, z1_max, W2,H2,D2, 'slice2');

write_xml(doc1, fileOut1);
write_xml(doc2, fileOut2);
fprintf('\nWrote %s and %s\n', fileOut1, fileOut2);
fprintf('Next: open each ORIGINAL slice in SNT, load its .traces, Fill Out Paths.\n');


%% ============================ LOCAL FUNCTIONS ============================
function txt = read_maybe_gzip(fname)
% Return file contents as char, decompressing if it is gzipped (magic 1F 8B).
fid = fopen(fname, 'r');
magic = fread(fid, 2, 'uint8')';
fclose(fid);
if numel(magic) >= 2 && magic(1) == 31 && magic(2) == 139
    outdir = tempname; mkdir(outdir);
    names  = gunzip(fname, outdir);
    txt    = fileread(names{1});
    delete(names{1}); rmdir(outdir, 's');
else
    txt = fileread(fname);
end
end


function newDoc = build_slice_doc(srcDoc, srcRoot, paths, assign, which, ...
                                  Rt, t, padL, padT, z1_max, W,H,D, tag) %#ok<INUSL>
% Clone <tracings> with only the paths for `which` slice, coordinates inverted.
newDoc  = com.mathworks.xml.XMLUtils.createDocument('tracings');
newRoot = newDoc.getDocumentElement();

% samplespacing: copy as-is (voxel units, 1.0)
ss = srcRoot.getElementsByTagName('samplespacing').item(0);
newRoot.appendChild(newDoc.importNode(ss, true));

% imagesize: rewrite for this slice's dimensions
img = newDoc.createElement('imagesize');
img.setAttribute('width',  num2str(W));
img.setAttribute('height', num2str(H));
img.setAttribute('depth',  num2str(D));
newRoot.appendChild(img);

% z offset so slice2 planes restart at 0
zoff = (which == 2) * (z1_max + 1);

for k = 0:paths.getLength()-1
    if assign(k+1) ~= which, continue; end
    p    = paths.item(k);
    pNew = newDoc.importNode(p, true);   % deep clone (keeps attrs + points)

    % transform every <point>
    pts = pNew.getElementsByTagName('point');
    for j = 0:pts.getLength()-1
        transform_point(pts.item(j), which, Rt, t, padL, padT, zoff, ...
                        {'x','y','z'}, {'xd','yd','zd'});
    end

    % transform path-level start/end coordinate attributes if present
    transform_attr_xy(pNew, which, Rt, t, padL, padT, 'startsx','startsy');
    transform_attr_xy(pNew, which, Rt, t, padL, padT, 'endsx','endsy');
    offset_attr_z(pNew, 'startsz', zoff);
    offset_attr_z(pNew, 'endsz',   zoff);

    newRoot.appendChild(pNew);
end
end


function transform_point(pt, which, Rt, t, padL, padT, zoff, ixyz, dxyz)
x = str2double(char(pt.getAttribute(ixyz{1})));
y = str2double(char(pt.getAttribute(ixyz{2})));
z = str2double(char(pt.getAttribute(ixyz{3})));
[xn, yn] = inv_xy(x, y, which, Rt, t, padL, padT);
zn = z - zoff;
% integer voxel attrs (SNT uses rounded indices)
pt.setAttribute(ixyz{1}, num2str(round(xn)));
pt.setAttribute(ixyz{2}, num2str(round(yn)));
pt.setAttribute(ixyz{3}, num2str(round(zn)));
% floating-point duplicates, if present
if pt.hasAttribute(dxyz{1}), pt.setAttribute(dxyz{1}, num2str(xn)); end
if pt.hasAttribute(dxyz{2}), pt.setAttribute(dxyz{2}, num2str(yn)); end
if pt.hasAttribute(dxyz{3}), pt.setAttribute(dxyz{3}, num2str(zn)); end
end


function transform_attr_xy(el, which, Rt, t, padL, padT, ax, ay)
if el.hasAttribute(ax) && el.hasAttribute(ay)
    x = str2double(char(el.getAttribute(ax)));
    y = str2double(char(el.getAttribute(ay)));
    if ~isnan(x) && ~isnan(y)
        [xn, yn] = inv_xy(x, y, which, Rt, t, padL, padT);
        el.setAttribute(ax, num2str(xn));
        el.setAttribute(ay, num2str(yn));
    end
end
end


function offset_attr_z(el, az, zoff)
if el.hasAttribute(az)
    z = str2double(char(el.getAttribute(az)));
    if ~isnan(z), el.setAttribute(az, num2str(z - zoff)); end
end
end


function [xn, yn] = inv_xy(x, y, which, Rt, t, padL, padT)
% Invert the forward merge for a single (x,y).
if which == 1
    xn = x - padL;
    yn = y - padT;
else
    v  = Rt * ([x; y] - t(:));   % R' * (merged - t)
    xn = v(1);
    yn = v(2);
end
end


function write_xml(doc, fname)
% Write pretty-printed XML. (SNT reads uncompressed .traces fine; gzip if you
% prefer smaller files -- see note at end of chat.)
xmlwrite(fname, doc);
end