function export_spd_color(animal_id, if_brain, depth_mid, out_folder)
%Export the pixel color of the axon to table

if (if_brain)
    query = sprintf('animal_id = %d', animal_id);
    fprintf('load data... it may takes a while....\n');
    image_datas = fetch(sln_image.AxonInBrain * sln_image.AxonImageAssociation * sln_cell.Axon & query, ...
        'pixel_color');
    for i = 1:numel(image_datas)
        fprintf('exporting color data of image %d\n', image_datas(i).image_id);
        colorbuf = image_datas(i).pixel_color;
        cbf = zeros([numel(colorbuf), 3]);

        if (~depth_mid) %calculating average color of every frame
            for j = 1:numel(colorbuf) %number of frames
                bufbuf = colorbuf{j};
                if (~isempty(bufbuf))
                    for k = 1:3
                        cbf(j, k) = mean(bufbuf(:, k), 'all');
                    end
                else
                    fprintf('Skipping empty frame %d\n', j);
                end
            end
        else
            q1 = floor(numel(colorbuf)/4);
            q3 = flor(3*numel(colorbuf)/4);
            for j = q1:q3
                bufbuf = colorbuf{j};
                if (~isempty(bufbuf))
                    for k = 1:3
                        cbf(j, k) = mean(bufbuf(:, k), 'all');
                    end
                else
                    fprintf('Skipping empty frame %d\n', j);
                end


            end
        end

        % Save the color data to a table
        colorTable = array2table(cbf, 'VariableNames', {'c1', 'c2', 'c3'});
        outputFile = fullfile(out_folder, sprintf('%d_axon_color_data.csv', image_datas(i).image_id));
        writetable(colorTable, outputFile);

    end
else
    %TO DO: export retina spinning disk color
end
end