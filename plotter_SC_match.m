function plotter_SC_match(animal_id, pta, fig_handle)
%PLOTTER_SC_MATCH Summary of this function goes here
%   Detailed explanation goes here
arguments
    animal_id 
    pta = true;
    fig_handle = null;
end

%getting all axon coordinates by the animal id
q.animal_id = animal_id;
q.brain_region = 'SCs';

axon_data = fetch(sln_cell.Axon * sln_cell.AxonCoordinate & q, '*');
if (fig_handle == null)
    figure
    ax1 = subplot(2,1,1);
    hold on;
    
    contra_filter = strcmp({axon_data.side}, 'Contralateral');
    contra_data = axon_data(contra_filter);
    x = (-1) * [contra_data.anterior_posterior];
    y = [contra_data.medial_lateral];
    scatter(ax1, x, y, 'filled');

    ipdata = axon_data(~contra_filter);
    if (~isempty(ipdata))
        x = (-1) *[ ipdata.anterior_posterior];
        y = [ipdata.medial_lateral];
        scatter(ax1, x, y, 'filled');
    end
    hold off;
else
    %todo in case we need to plot this elsewhere
end

%plot the retina recon with azimuth equal-distance projection 

end

