function clean_up_tempAxonAssociation(animal_id)
arguments
    animal_id = -1;
end

if (animal_id == -1)
    delAll = input('Delete all "TBD" in the databaser? Y or N.');
    if (delAll == 'Y')
        %TODO finish the purge
        delAll=input('Are you sure? Y or N\n');
        if (delAll == 'Y')
            todel = fetch(sln_cell.Axon & 'brain_region = "TBD"');
            for i = 1:numel(todel)
                del(sln_cell.Axon & todel(i).axon_id);
            end
        else
            fprintf('bye!\n');
        end

    else
        fprintf('No animal id input. End the function now....\n');
        return;
    end
else %targeted deleting only the animal
    key.animal_id = animal_id;
    key.brain_region = 'TBD';
    todel = fetch(sln_cell.Axon & key, '*');
    if (~isempty(todel))
        fprintf('Deleting list: \n');
        disp(struct2table(todel))
        delblock = sln_cell.Axon & key;
        chidblock = sln_image.AxonImageAssociationV2 & delblock;
        chidblock.delQuick();
        delblock.delQuick();
    else
        fprintf('Cannot find "TBD" brain region in animal %d, in table sln_cell.Axon', animal_id);
        return;
    end
end    
end