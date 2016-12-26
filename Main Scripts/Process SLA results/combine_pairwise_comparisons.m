%% Do your thing with pairwise comparisons
% With the SLA_analyses you have one volume image per pairwise comparison.
% However, that is not always what you want in the end. 

% For example, I have four Arabic digits that I do a pairwise comparison
% on. For example, symbol 2 versus symbol 4; symbol 2 vs symbol 6; etc. In
% that way I end up with 6 pairwise comparisons per subject. I would like
% to average across those 6 pairwise comparisons and end up with one volume
% image per subject. 
%
% Another example, for correlation searchlight you might want to not only
% average across certain conditions, but also subtract the diagonal.
% 
% Or even, you might want to correlate your correlation matrix per subject 
% with certain models. 
%
% This script will help you to make your averaging across conditions,
% correlate with a cetain model, ... 
%
% Author: JB - January 2016
% ----------------------------------------------------------------------------

%% Variables for you to adjust 
% Directories 
dirs.ScriptDir = 'E:\Research\Searchlight TDT\'; 
dirs.SLAResultDir = 'E:\Research\Felipe\Searchlight\SLA Results\Visual_retest\'; %'E:\Research\Dyscalculie Studie\fMRI\Searchlight\Results\VoxelRadius 2 + Grey Matter\Raw results\Symbols'; %
dirs.MyThingResultDir = 'E:\Research\Felipe\Searchlight\Analysis\Retest'; %'E:\Research\Searchlight TDT'; %

% Searchlight Variables
SLAvars.Analysis = 'correlation'; % 'correlation' or 'decoding'

%% DO NOT ADJUST ANYTHING BELOW UNLESS YOU KNOW WHAT YOU ARE DOING
% Please, only adjust code below if you know exactly what you are doing. 

% Do preparations, such as check directories on file seperators, make
% result directory if necessary, select which measures you wish to do on 
% the SLA results. 
[dirs, SubjectIDs, mything] = combine_pc_prep(dirs, SLAvars);

% Do the analysis per subject 
analyze_SLA_results(mything, dirs, SubjectIDs);
