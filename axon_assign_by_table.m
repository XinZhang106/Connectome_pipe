function  axon_assign_by_table(axon_table)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%check if the input table has all columns and correctedly named
columns = {'ref_im', 'centroid_x', 'centroid_y', 'centroid_perimeter', 'ml1_x', 'ml1_y', 'ml2_x', 'ml2_y'...
   'spinning_image_id', 'axon_djid', 'image_folder'};
tableV = axon_table.Properties.VariableNames;
for i = 1:numel(columns)
    if (~ismember(columns{i}, tableV))
        error('Column %d %s not found in input table!\n', i, columns{i});
    end
end

%uploading each row
for j = 1:height(axon_table)
    
    %insert whole brain midline information test if the midline already exists
    midkey.ref_image_id = axon_table.ref_im(j);
    md = fetch(sln_image.WholeBrainMidline & midkey, '*');
    if (isempty(md))
        midkey.midline_x1 = axon_table.ml1_x(j);
        midkey.midline_y1 = axon_table.ml1_y(j);
        midkey.midline_x2 = axon_table.ml2_x(j);
        midkey.midline_y2 = axon_table.ml2_y(j);
        try
            C = dj.conn;
            C.startTransaction;
            insert(sln_image.WholeBrainMidline,midkey)
            C.commitTransaction;
        catch ME
            C.cancelTransaction;
            rethrow(ME);
        end
        fprintf('Inserted midline information for whole brain image %d\n', midkey.ref_image_id);
        disp(midkey);
    else
        fprintf('Midline information already exists for brain image:\n');
        disp(md);
    end

    %upload into AxonInBrain
    imq.image_id = axon_table.spinning_image_id(j);
    %test if already inserted
    axontest = fetch(sln_image.AxonInBrain & imq);

    if (isempty(axontest))
        c = axon_table.image_folder(j);
        subfd_files = dir(c{1});
        subfd_files = subfd_files(~[subfd_files.isdir]);
        mask = 0;
        background = 0;
        for k = 1:numel(subfd_files)
            %find mask file path
            if (strcmp(subfd_files(k).name, 'mask.tif'))
                mask = fullfile(c{1}, subfd_files(k).name);
            end

            if (strcmp(subfd_files(k).name, 'background.roi'))
                background = fullfile(c{1}, subfd_files(k).name);
            end

        end

        if (~all([mask background]))
            error('Either mask or background cannot be found for %s\n', axon_table.image_folder(j));
        end

        centroid = [axon_table.centroid_x(j) axon_table.centroid_y(j)];
        r = axon_table.centroid_perimeter(j)/(2*pi);
        medial_lateral = sln_image.WholeBrainMidline.calculate_distance_to_midline(centroid, axon_table.ref_im(j));
        ap = sln_image.WholeBrainImage.count_slice_before(axon_table.ref_im(j));

        sln_image.AxonInBrain.assign_axon_in_brain(axon_table.spinning_image_id(j),...
            axon_table.ref_im(j), axon_table.centroid_x(j), axon_table.centroid_y(j), r, background, mask, medial_lateral, ap);
    else
        fprintf('axonal image %d already exist in table sln_image.AxonInBrain!\n', imq.image_id);
    end
  

    %link axon and image
    key = {};
    key.image_id = axon_table.spinning_image_id(j);
    key.axon_id = axon_table.axon_djid(j);
    axon_linked = fetch(sln_image.AxonImageAssociation & key);
    if (~isempty(axon_linked))
        fprintf('Axon %d and image %d are already linked!\n', key.axon_id, key.image_id);
    else
        if(key.axon_id ~= 0)
            try
                C = dj.conn;
                C.startTransaction;
                insert(sln_image.AxonImageAssociation, key);
                C.commitTransaction;
                fprintf('Linking axon %d to image %d.\n', key.axon_id, key.image_id);
            catch ME
                C.cancelTransaction;
                rethrow (ME)
            end
        else
            %TODO insert axon here
            fprintf('Axon not in the database... inserting...\n');
        end
    end

end
populate(sln_cell.AxonCoordinate);

end