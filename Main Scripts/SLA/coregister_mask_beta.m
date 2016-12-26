%% Coregister grey matter mask to beta dimension
% This script will coregister the standard grey matter mask from the WFU
% PickAtlas to the dimensions of your beta-images. This is necessary to
% avoid this error during the searchlight: "Matrix dimensions do not match
% between mask and functional data." 

% Author: JB - January 2015 

function [Mask] = coregister_mask_beta(dirs, SubjectIDs)

%% Check if coregistered mask does not exist yet, make it 
if exist([dirs.YourSLA 'rgrey_matter_mask.nii'], 'file') ~= 2
    % load the standard coregistration batch
    load([dirs.ScriptDir 'LBP Scripts' filesep 'SLA' filesep 'Coregister Mask to Beta Dim' filesep 'coregister_batch.mat']);

    % get a beta-file of your study
    betafile = dir([dirs.DataDir SubjectIDs{1} filesep dirs.selected_model 'beta_0001.*']);
    matlabbatch{1}.spm.spatial.coreg.write.ref = cellstr([dirs.DataDir SubjectIDs{1} filesep dirs.selected_model betafile(end).name ',1']);

    % get the mask pathway
    matlabbatch{1}.spm.spatial.coreg.write.source = cellstr([dirs.ScriptDir 'LBP Scripts' filesep 'SLA' filesep 'Coregister Mask to Beta Dim' filesep 'grey_matter_mask.nii']);

    % start batch
    spm_jobman('initcfg');
    output_list = spm_jobman('run', matlabbatch);

    % save batch
    save([dirs.YourSLA 'Coregister_Batch.mat'], 'matlabbatch');

    % move the coregistered mask to your specific SLA folder
    movefile([dirs.ScriptDir 'LBP Scripts' filesep 'SLA' filesep 'Coregister Mask to Beta Dim' filesep 'rgrey_matter_mask.nii'], dirs.YourSLA);
end

%% Save pathway
Mask = [dirs.YourSLA 'rgrey_matter_mask.nii'];
