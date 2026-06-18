function h = Plot_retinaRecon(ax, reconData, opts)
    arguments
        ax
        reconData
        opts.NumCircles (1,1) double = 6
        opts.MaxRadius  (1,1) double = 2
    end

    cla(ax);
    hold(ax, 'on');

    % --- Reference circles ---
    radii = linspace(opts.MaxRadius/opts.NumCircles, opts.MaxRadius, opts.NumCircles);
    theta = linspace(0, 2*pi, 500);
    h.circles = gobjects(opts.NumCircles, 1);
    for k = 1:opts.NumCircles
        r = radii(k);
        h.circles(k) = plot(ax, r*cos(theta), r*sin(theta), 'k--');
    end

    % --- Cross-hairs at origin ---
    h.xline = xline(ax, 0);
    h.yline = yline(ax, 0);

    % --- RGC positions ---
    proj    = reconData.reproj;
    cellIds = reconData.cell_ids;

    h.scatter = scatter(ax, proj(:,1), proj(:,2), 'filled');
    h.text    = gobjects(height(proj), 1);
    for i = 1:height(proj)
        h.text(i) = text(ax, proj(i,1), proj(i,2)+0.1, num2str(cellIds(i)));
    end

    % --- Cosmetics ---
    title(ax,  'Retina reconstruction');
    xlabel(ax, 'Nasal <---> Temporal');
    ylabel(ax, 'Dorsal <---> Ventral');
    axis(ax, 'equal');
    xlim(ax, [-2.1 2.1]);
    ylim(ax, [-2.1 2.1]);
end