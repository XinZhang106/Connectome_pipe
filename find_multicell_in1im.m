function cell_id = find_multicell_in1im(image_id)
%Dealing with situation in sln_image.RetinalCellImage where multiple cells are linked to the same image
%not in use currently
fptintf('Searching for cells linked to image %d:....\n', image_id);
q.image_id = image_id;
cells = fetch(sln_image.RetinalCellImage & q);
if (numel(cells)>1)
    fprintf('Multiple cells found to be linked to this image, please pick one.\n');
    %fprintf('Multiple cells are associated with this image, please pick one.');
    disp(cells);
    confirm = false;
    id_list = [cells.cell_unid];
    while (~confirm)
        choosed_id = input('pick: ');
        choice_confirm = input('Are you sure? Y/N [Y]: ');
        if (strcmpi(choice_confirm, 'y') & ismember(choosed_id, id_list))
            confirm = true;
        end
    end
    cell_id = choosed_id;
elseif(numel(cells)==1)
    cell_id = cells.cell_unid;
    fprintf('Only 1 cell found linked to that image: %d\n', cell_id);
else
    fprintf('No cells found.\n');
    cell_id = 0;
end

end