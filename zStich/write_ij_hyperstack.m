function write_ij_hyperstack(fname, out, C, Z)
% Write an ImageJ hyperstack, page order = channels fastest then z.
% Uses imwrite for integer classes; Tiff class for single/double.
desc = sprintf(['ImageJ=1.53t\nimages=%d\nchannels=%d\nslices=%d\n' ...
                'hyperstack=true\nmode=composite\nloop=false\n'], ...
                C*Z, C, Z);
 
if isinteger(out)
    first = true;
    for z = 1:Z
        for c = 1:C
            if first
                imwrite(out(:,:,c,z), fname, 'tif', ...
                        'Compression', 'none', 'Description', desc);
                first = false;
            else
                imwrite(out(:,:,c,z), fname, 'tif', ...
                        'Compression', 'none', 'WriteMode', 'append');
            end
        end
    end
    return;
end
 
% ---- Floating-point path via Tiff class ----
if isa(out, 'double')
    out = single(out);          % ImageJ reads 32-bit float; 64-bit is nonstandard
end
[H, W, ~, ~] = size(out);
rps = min(H, 64);               % small strips: proven-safe, avoids giant single strip
t = Tiff(fname, 'w8');
cleanup = onCleanup(@() close(t));   %#ok<NASGU>
first = true;
for z = 1:Z
    for c = 1:C
        if z > 1 || c > 1, t.writeDirectory(); end
        t.setTag('ImageLength',        H);
        t.setTag('ImageWidth',         W);
        t.setTag('Photometric',        Tiff.Photometric.MinIsBlack);
        t.setTag('BitsPerSample',      32);
        t.setTag('SampleFormat',       Tiff.SampleFormat.IEEEFP);
        t.setTag('SamplesPerPixel',    1);
        t.setTag('RowsPerStrip',       rps);
        t.setTag('PlanarConfiguration',Tiff.PlanarConfiguration.Chunky);
        t.setTag('Software',           'MATLAB');
        if first
            t.setTag('ImageDescription', desc);   % ImageJ metadata on first page only
            first = false;
        end
        t.write(single(out(:,:,c,z)));
    end
end
end