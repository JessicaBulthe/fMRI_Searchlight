%% Do SLA analyses 
% This script runs a searchlight analyses on the subjects and pairwise
% comparisons that you want to. 

% Please carefully read the comments and the tutorial that are included
% before adjusting anything. 

% This scripts are an adjustment by Jessica Bulthé of The Decoding Toolbox.
% Please refer to The Decoding Toolbox if you are using these scripts. This
% is only fair towards the people who have invested/risked their mental health
% for making this toolbox and making the SLA so fast that you can run the
% analyses on your computer. 

% Author: JB - January 2016
% -------------------------------------------------------------------------

%% Variables for you to adjust 
% Directories 
dirs.ScriptDir = 'C:\Users\u0069828\Google Drive\Research\Searchlight TDT\'; 
dirs.DataDir = 'C:\Users\u0069828\Google Drive\Research\Dyscalculie Studie\fMRI\Statistiek';
dirs.ResultDir = 'C:\Users\u0069828\Desktop\SLA\Digits\'; 

% Searchlight Variables
SLAvars.Analysis = 'decoding'; % 'correlation' or 'decoding'
SLAvars.Radius_Unit = 'voxels'; % 'voxels' or 'mm'
SLAvars.Radius_Size =  2;   % if 2 => 27 voxels in one sphere
SLAvars.Mask_Use = 'Grey Matter'; % 'Grey Matter' or 'Whole Brain' 

%% DO NOT ADJUST ANYTHING BELOW UNLESS YOU KNOW WHAT YOU ARE DOING
% Please, only adjust code below if you know exactly what you are doing. 
% 1. Do preparations
[dirs, cfg, labelnames, SubjectIDs] = do_SLA_preps(dirs, SLAvars);

% 2. If you have selected 'Grey Matter', check if coregistration is already
% done. If not, do coregistration. 
if strcmp(SLAvars.Mask_Use, 'Grey Matter')
    [Mask] = coregister_mask_beta(dirs, SubjectIDs);
end

% 3. Do the SLA for every subject and every pairwise comparison
run_SLA(SubjectIDs, labelnames, dirs, cfg, Mask);


