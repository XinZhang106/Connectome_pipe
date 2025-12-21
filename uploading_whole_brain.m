function [whole_brain_ids, whole_brain_fnames] = uploading_whole_brain(animal_data)
whole_folder = animal_data.whole_brain.folder;
files = dir(whole_folder);
files = files(~[files.isdir]);

whole_brain_ids = zeros([numel(files), 1]);
whole_brain_fnames = cell(numel(files), 1);

for i = 1:numel(files)
    %going through the files and matches the token
    expr = '^s(?<snum>\d+)_b(?<bnum>\d+)_';
    tokens = regexp(files(i).name, expr, 'names');
    if (isempty(tokens.bnum) || isempty(tokens.snum))
        warning('%s cannot be processed as a whole brain image, skipping...\n', files(i).name);
    else
        %upload to the table sln_image.wholebrain
        filepath = fullfile(files(i).folder, files(i).name);
        whole_brain_ids(i) = sln_image.WholeBrainImage.insert_wb_image(animal_data.brain.tissue_id, ....
            filepath, str2num(tokens.snum), str2num(tokens.bnum));
        whole_brain_fnames{i}= files(i).name;
        fprintf('whole brain reference uploaded %s, ref_image_id %d\n', whole_brain_fnames{i}, whole_brain_ids(i));
    end

end
fprintf('Uploading finished animal id %d.\n', animal_data.brain.animal_id);
end