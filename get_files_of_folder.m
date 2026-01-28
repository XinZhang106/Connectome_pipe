function file_list_struct = get_files_of_folder(folder)
%do as described by the title, teeny tiny utility function
file_list_struct = dir(folder);
file_list_struct = file_list_struct(~[file_list_struct.isdir]);

end