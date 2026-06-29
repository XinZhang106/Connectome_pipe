function export_spd_color(animal_id, if_brain, if_pixel, out_folder)
%Export the pixel color of the axon to table

if (if_brain)
    query = sprintf('animal_id = %d', animal_id);
    fprintf('load data... it may takes a while....\n');
    image_datas = fetch(sln_image.AxonInBrain * sln_image.AxonImageAssociation * sln_cell.Axon & query, ...
        'pixel_color');
    for i = 1:numel(image_datas)
        fprintf('exporting color data of image %d\n', image_datas(i).image_id);
        colorbuf = image_datas(i).pixel_color;
        if (~if_pixel) %calculating average color of every frame
            cbf = zeros([numel(colorbuf), 3]);
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
            %export the pixel value
            cbf = [];
            framindx = [];
            for j = 1:numel(colorbuf)
                if (isempty(cbf))
                    cbf = colorbuf{j};
                    pixelnum = height(cbf);
                    framindx = repmat(j, pixelnum, 1);
                else
                    cbf = [cbf; colorbuf{j}];
                    pixelnum = height(colorbuf{j});
                    framindx = [framindx; repmat(j, pixelnum, 1)];
                end
            end
        end
        % Save the color data to a table
        colorTable = array2table([cbf framindx], 'VariableNames', {'c1', 'c2', 'c3', 'fr'});
        if (if_pixel)
            outputFile = fullfile(out_folder, sprintf('%d_axon_color_pixeldata.csv', image_datas(i).image_id));
        else
            outputFile = fullfile(out_folder, sprintf('%d_axon_color_data.csv', image_datas(i).image_id));
        end
        writetable(colorTable, outputFile);
    end
else
    query = sprintf('animal_id = %d', animal_id);
    image_datas = fetch(sln_image.RGCinRetina * sln_image.RetinalCellImage * sln_cell.RetinalCell & query, '*');
    if (isempty(image_datas))
        warning("No color image found for this mouse %d.\n", animal_id);
        return
    end
    for i = 1:numel(image_datas)
        fprintf('exporting color data of image %d\n', image_datas(i).image_id);
        colorbuf = image_datas(i).color_pixel;
        if (~if_pixel) %calculating average color of every frame
            cbf = zeros([numel(colorbuf), 3]);
            framindx = [];
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
            %export the pixel value
            cbf = [];
            framindx = [];
            for j = 1:numel(colorbuf)
                if (isempty(cbf))
                    cbf = colorbuf{j};
                    pixelnum = height(cbf);
                    framindx = repmat(j, pixelnum, 1);
                else
                    cbf = [cbf; colorbuf{j}];
                    pixelnum = height(colorbuf{j});
                    framindx = [framindx; repmat(j, pixelnum, 1)];
                end
            end
        end
        % Save the color data to a table
        colorTable = array2table([cbf framindx], 'VariableNames', {'c1', 'c2', 'c3', 'fr'});
        if (if_pixel)
            outputFile = fullfile(out_folder, sprintf('%d_rgc_color_pixeldata.csv', image_datas(i).image_id));
        else
            outputFile = fullfile(out_folder, sprintf('%d_axon_rgc_data.csv', image_datas(i).image_id));
        end
        writetable(colorTable, outputFile);
    end
end
end
