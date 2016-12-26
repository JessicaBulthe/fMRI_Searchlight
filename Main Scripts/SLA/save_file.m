% Function to open a GUI to save a file.
% JB - january 2016

function [file, fileName] = save_file(savedir, title, extension)

curr_dir = cd;
cd(savedir); 

fileName = inputdlg(title);
fileName = char(fileName);
if strcmp(fileName(end-3:end), extension)
    file = [savedir fileName];
else
    file=[savedir fileName '.mat'];
end

cd(curr_dir);
