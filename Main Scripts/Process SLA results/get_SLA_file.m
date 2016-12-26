%% Get SLA result file

function [result] = get_SLA_file(directory)

% search the nifti file
file = dir([directory filesep '*.nii']);
if size(file,1) == 0
    file = dir([directory filesep '*.img']);
end

% load the nifti file and switch left to right
loaded_file = load_nii([directory filesep file.name]);
matrix = flipdim(loaded_file.img, 1);
result = matrix(:,:,:);