function plotter_SC_match(animal_id, pta, fig_handle)
%PLOTTER_SC_MATCH Summary of this function goes here
%   Detailed explanation goes here
arguments
    animal_id 
    pta = true;
    fig_handle = 0;
end

%getting all axon coordinates by the animal id
q.animal_id = animal_id;
q.brain_region = 'SCs';

axon_data = fetch(sln_cell.Axon * sln_cell.AxonCoordinate & q, '*');

q.brain_region = 'SCig';
igdata = fetch(sln_cell.Axon * sln_cell.AxonCoordinate &q, '*');
if (~isempty(igdata))
    axon_data = [axon_data; igdata];
end

if (fig_handle == 0)
    figure
    ax1 = subplot(1,2,1);
    hold on;
    
    contra_filter = strcmp({axon_data.side}, 'Contralateral');
    contra_data = axon_data(contra_filter);
    if (pta)
        x = [contra_data.anterior_posterior];
    else
        x = -[contra_data.anterior_posterior];
    end
    y = [contra_data.medial_lateral];
    %axon_ids = contra_data
    scatter(ax1, x, y, 'filled');
    %add text labeling for each axon 
    for i = 1:numel(x)
        text(ax1, x(i), y(i)+20, num2str(contra_data(i).axon_id));
    end

    ipdata = axon_data(~contra_filter);
    if (~isempty(ipdata))
        if (pta)
            x = [ipdata.anterior_posterior];
        else
            x = (-1) *[ ipdata.anterior_posterior];
        end
        
        y = [ipdata.medial_lateral];
        scatter(ax1, x, y, 'filled');
        for i=1:numel(x)
            text(ax1, x(i), y(i)+10, strcmp(ipdata(i).axon_id));
        end
    legend(ax1, {'Contralateral', 'Ipsilateral'});
    end
    
    title(ax1, 'Axon in Superior Colliculus');
    
    xlabel(ax1, 'Posterior<---> Anterior (um), relative');
    ylabel(ax1, 'Medial<--->Lateral (um), abusolute');
    %some calculation to set the x and y limit of this plot
    ap_dif = max([contra_data.anterior_posterior], [], 'all')- min([contra_data.anterior_posterior], [], 'all');
    ml_dif = max([contra_data.medial_lateral], [], 'all') - 0;

    if (ap_dif >= ml_dif)
        %range = ap_dif;
        yup_yl = [0  ap_dif];
        ylim(ax1, yup_yl);
    else
        xmid = (max([contra_data.anterior_posterior],[], 'all') +min([contra_data.anterior_posterior],[], 'all'))/2;
        xup_xl = [xmid - ml_dif/2 xmid+ml_dif/2];
        xlim(ax1, xup_xl);
        ylim(ax1, [0, ml_dif])
    end
    %TODO THIS NEEDS A FALSE PTA SITUATION
    
    axis(ax1, 'equal');
    axis(ax1, 'square');
    ylim(ax1, [0,1600])
    hold off;
    


    %plot the retina recon with azimuth equal-distance projection
    q = rmfield(q, 'brain_region');
    retina_data = fetch(sln_tissue.Retina * sln_tissue.RetinaRecon & q,'side', 'cell_ids', 'reproj');
    ax2 = subplot(1,2,2);
    hold on;

    %adding some reference lines 
    nCircles = 6;
    % Maximum radius
    rMax = 2;
    % Radii
    radii = linspace(rMax/nCircles, rMax, nCircles);
    theta = linspace(0, 2*pi, 500);
    for r = radii
        x = r * cos(theta);
        y = r * sin(theta);
        plot(ax2, x, y, 'k--');  % dashed black circles
    end
    xline(ax2, 0);
    yline(ax2, 0)

    proj = retina_data.reproj;
    cell_id = retina_data.cell_ids;
    scatter(ax2, proj(:, 1), proj(:, 2), 'filled');
    for i = 1:height(proj)
        text(ax2, proj(i, 1), proj(i, 2)+0.1, num2str(cell_id(i)))
    end
    title(ax2, 'Retina reconstruction')
    axis(ax2, 'equal');
    xlabel(ax2, 'Nasal <->  Temporal');
    ylabel(ax2, 'Dorsal <-> Ventral');
    xlim(ax2, [-2.1, 2.1]);
    ylim(ax2, [-2.1, 2.1]);
    hold off;
else
    %todo in case we need to plot this elsewhere
end


end

