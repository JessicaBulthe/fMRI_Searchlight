% Function to get the voxels that have a value for all the pairwise
% comparisons 

% JB - January 2016

function voxelcoord = get_voxel_coords(all_results)

sub_all_results = all_results;
sub_all_results(sub_all_results == 0) = NaN;
av = mean(sub_all_results,4);
av_isnan = isnan(av);
[r,c,v] = ind2sub(size(av_isnan),find(av_isnan == 0));
voxelcoord = [r,c,v];