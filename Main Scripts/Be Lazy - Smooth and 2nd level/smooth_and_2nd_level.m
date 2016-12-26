%% Be lazy
% Once you have per subject per measure a image file created, you'll need
% to smooth it across subjects. 
%
% When the smoothing is done, a second level analysis is required to get
% an across subject image. 
%
% This could all be done by clicking in 

% Author: JB - January 2016
% ----------------------------------------------------------------------------

%% Adjust these variables: 
% Dirs: 
dirs.ScriptDir = 'E:\Research\Searchlight TDT\'; 
dirs.MyThingResultDir = 'EE:\Research\Felipe\Searchlight\Analysis\AVcongruency_valence\all_diag_minus_all_nondiag';
dirs.Results2ndLevel = 'E:\Research\Felipe\Searchlight\Results\2ndlevel\AVcongruency_valence\';

% Smoothing level
smoothing_level = [8 8 8];

%% Prepare everything
% Check if directories are ending with a filesep ("\" or "/"), if not, add a filesep
if strcmp(dirs.ScriptDir(end), filesep) ~= 1
    dirs.ScriptDir(end+1) = filesep; 
end

if strcmp(dirs.MyThingResultDir(end), filesep) ~= 1
    dirs.MyThingResultDir(end+1) = filesep; 
end

if strcmp(dirs.Results2ndLevel(end), filesep) ~= 1
    dirs.Results2ndLevel(end+1) = filesep; 
end

% Make the MyThingResultDir if it does not exist yet
if exist(dirs.Results2ndLevel, 'dir') ~=7 
    mkdir(dirs.Results2ndLevel);
end


%% Adjust the batch a bit and let it run. 
% load matlabbatch
load([dirs.ScriptDir 'LBP Scripts' filesep 'Be Lazy - Smooth and 2nd level' filesep 'batch_smooth_2ndlevel.mat']);

% adjust smoothing files and level
datafiles = dir([dirs.MyThingResultDir '*.nii']);
for file = 1:size(datafiles,1)
    matlabbatch{1}.spm.spatial.smooth.data(file) = cellstr([dirs.MyThingResultDir datafiles(file).name]);
end

matlabbatch{1}.spm.spatial.smooth.fwhm = smoothing_level; 

% let the batch run
spm_jobman('initcfg');
output_list = spm_jobman('run', matlabbatch);


