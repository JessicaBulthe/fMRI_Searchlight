% Function to open a GUI to select a file.
% JB - january 2016

function [file, FileName] = get_file(open_dir, extension, title)

curr_dir = cd;
cd(open_dir);
[FileName, PathName] = uigetfile(extension, title);
cd(curr_dir);

file = [PathName FileName];