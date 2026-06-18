function h = Plot_SCtopo(ax, contradata, ipData, opts)
    arguments
        ax
        contradata
        ipData = []
        opts.PreserveAnatomy (1,1) logical = true   % your 'pta'
    end

    cla(ax);
    hold(ax, 'on');

    % --- Contralateral ---
    x = [contradata.anterior_posterior];
    if ~opts.PreserveAnatomy, x = -x; end
    y = [contradata.medial_lateral];

    h.contraScatter = scatter(ax, x, y, 'filled');
    h.contraText    = gobjects(numel(x), 1);          % preallocate handle array
    for i = 1:numel(x)
        h.contraText(i) = text(ax, x(i), y(i)+20, num2str(contradata(i).axon_id));
    end

    % --- Ipsilateral (optional) ---
    if ~isempty(ipData)
        x = [ipData.anterior_posterior];
        if ~opts.PreserveAnatomy, x = -x; end
        y = [ipData.medial_lateral];

        h.ipsiScatter = scatter(ax, x, y, 'filled');
        h.ipsiText    = gobjects(numel(x), 1);
        for i = 1:numel(x)
            h.ipsiText(i) = text(ax, x(i), y(i)+10, num2str(ipData(i).axon_id));
        end
        h.legend = legend(ax, {'Contralateral', 'Ipsilateral'});
    end

    title(ax,  'Axons in Superior Colliculus');
    xlabel(ax, 'Posterior <---> Anterior (\mum)');
    ylabel(ax, 'Medial <---> Lateral (\mum)');

    % --- axis limits (your logic, condensed) ---
    apRange = range([contradata.anterior_posterior]);
    mlMax   = max([contradata.medial_lateral]);
    if apRange >= mlMax
        ylim(ax, [0 apRange]);
    else
        xmid = mean([min([contradata.anterior_posterior]) max([contradata.anterior_posterior])]);
        xlim(ax, xmid + [-mlMax/2  mlMax/2]);
        ylim(ax, [0 mlMax]);
    end
end