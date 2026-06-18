function h = Plot_Zproj(ax, zproj)
arguments
    ax
    zproj
end

cla(ax);
h.image = imshow(zproj, 'Parent', ax);
axis(ax, 'image');
title(ax, 'Axon Z-projection');
end