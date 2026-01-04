% function success = upload_wbmdl_from_table(excel_fpath)
% success = 0;
% %read the excel file 
% C = dj.conn;
% C.startTransaction;
% try
%     mdl_table = readtable(excel_fpath);
% 
%     for j =1:height(mdl_table)
%         key.ref_image_id = mdl_table.ref_image_id(j);
%         key.midline_x1 = mdl_table.x1(j);
%         key.midline_x2 = mdl_table.x2(j);
%         key.midline_y1 = mdl_table.y1(j);
%         key.midline_y2 = mdl_table.y2(j);
%         insert(sln_image.WholeBrainMidline, key);
%         fprintf('Inserting success for whole brain middle line information!\n');
%         disp(key);
% 
%     end
%      C.commitTransaction;
%      success = 1;
% 
% catch ME
%     if (exist('C', 'var'))
%         C.cancelTransaction;
%     end
%     throw(ME);
% end