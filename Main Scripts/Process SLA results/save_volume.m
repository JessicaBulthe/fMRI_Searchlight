
function save_volume(SubjectID, SubjectDataDir, dir_part, dirs, MeasureDir, volume_to_write)

% make a "basic" volume file
file = dir([SubjectDataDir dir_part filesep '*.nii']);
if size(file,1) == 0
    file = dir([SubjectDataDir dir_part filesep '*.img']);
    file2 = dir([SubjectDataDir dir_part filesep '*.hdr']);
end
copyfile([SubjectDataDir dir_part filesep file.name], dirs.MyThingResultDir);
copyfile([SubjectDataDir dir_part filesep file2.name], dirs.MyThingResultDir);

% write the volume
volume = spm_vol([dirs.MyThingResultDir file.name]);
volume.private.dat(:,:,:) = volume_to_write;
image = spm_read_vols(volume);
volume.fname = [MeasureDir SubjectID '.nii'];
spm_write_vol(volume, image);
