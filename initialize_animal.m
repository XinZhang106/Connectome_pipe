function sucess = initialize_animal(animal_id, eyeside, slice_ori, slice_thick, owner)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
sucess = 0;

%DJ records saved on
basefd = "D:\localData\trace_pipe_DJ";
animal_fd = fullfile(basefd, string(animal_id));

if (isfolder(animal_fd))
    fprintf('Folder for animal %d already exits!\n', animal_id);
else
    mkdir(animal_fd);
    fprintf('Creaing new folder for animal %d, %s', animal_id, animal_fd);
end

retina_key.animal_id = animal_id;
retina_insert = fetch(sln_tissue.Retina & retina_key);
if (isempty(retina_insert))
    retina_key.tissue_id = sln_tissue.Retina.add_new_retina(owner, eyeside, animal_id);
    fprintf('Retina inserted in sln_tissue.Retina!');
else
    retina_key.tissue_id = retina_insert.tissue_id;
    fprintf('Retina already in DJ, skipping...\n');
end

brain_key.animal_id = animal_id;
brain_insert = fetch(sln_tissue.BrainSliceBatch & brain_key);
if (~isempty(brain_insert))
    brain_key.tissue_id = brain_insert.tissue_id;
    fprintf('Brain already in DJ, skipping....\n');
else
    brain_key.tissue_id = sln_tissue.BrainSliceBatch.add_BrainSliceBatch(owner, slice_ori, slice_thick, animal_id);
    fprintf('Brain inserted in sln_tissue.Brain!');
end
animal_dj.retina = retina_key;
animal_dj.brain = brain_key;
filename = fullfile(animal_fd, sprintf('%d_sum.mat', animal_id));
save(filename, "animal_dj");

%making folders
wf = fullfile(animal_fd, 'wholebrain_wf');
make_if_notexist(wf);
rc = fullfile(animal_fd, 'retina_confocal');
make_if_notexist(rc);

bspd = fullfile(animal_fd, 'axon_spd');
make_if_notexist(bspd);
rspd = fullfile(animal_fd, 'rgc_spd');
make_if_notexist(rspd);

recon = fullfile(animal_fd, 'retina_recon');
make_if_notexist(recon);
fprintf('Folders prepared for all processes! Happy processing!\n')

sucess = 1;
end