%% Do preparations for doing your thing on the SLA results

% Author: JB - January 2015 

function [dirs, SubjectIDs, mything] = combine_pc_prep(dirs, SLAvars)

%% Check if directories are ending with a filesep ("\" or "/"), if not, add a filesep
if strcmp(dirs.ScriptDir(end), filesep) ~= 1
    dirs.ScriptDir(end+1) = filesep; 
end

if strcmp(dirs.SLAResultDir(end), filesep) ~= 1
    dirs.SLAResultDir(end+1) = filesep; 
end

if strcmp(dirs.MyThingResultDir(end), filesep) ~= 1
    dirs.MyThingResultDir(end+1) = filesep; 
end

%% Make the MyThingResultDir if it does not exist yet
if exist(dirs.MyThingResultDir, 'dir') ~=7 
    mkdir(dirs.MyThingResultDir);
end

%% Add ScriptDir to the searchpath of Matlab 
addpath(genpath(dirs.ScriptDir));

%% Get SubjectIDs
% Select subjects for which you want to do the SLA
subjects = dir(dirs.SLAResultDir);
SubjectIDs = {subjects(3:end).name};

%% Get the pairwise comparisons that are done
pairwise_comparisons = dir([dirs.SLAResultDir SubjectIDs{1}]);
pairwise_comparisons = {pairwise_comparisons(3:end).name};

%% Select what you want to do 
select_previous = questdlg('Would you like to load a previous measure file?', 'New or not', 'Yes','No, I will make new measures.','Yes');

if strcmp(select_previous, 'Yes')
    [measures_file, name] = get_file(dirs.MyThingResultDir, '*.mat', 'Select the mat-file containing the measures:');
    load(measures_file);
    mything.measuresname = name;
    
    add_more = questdlg('Would you like to add a couple of new measures to the file?', 'New or not', 'Yes','No','Yes');
end

if strcmp(select_previous, 'No, I will make new measures.') || strcmp(add_more, 'Yes')
    mything.analysis = SLAvars.Analysis;

    % If you have a decoding SLA, you can only average across couple or all
    % pairwise comparisons.
    if strcmp(SLAvars.Analysis, 'decoding')
        options = {'I wish to select out which pairwise comparisons should be averaged', 'Average across all pairwise comparisons'};
        [chosen_options,~] = listdlg('PromptString', 'What average do you wish to calculate: ', 'SelectionMode', 'multiple', 'ListString', options, 'ListSize', [500 500]); 

        if isfield(mything, 'average_across') == 0
            mything.average_across = [];
            mything.average_names = [];
        end

        for option = 1:size(chosen_options,2)
            switch chosen_options(option)
                case 1
                    if size(chosen_options,2) == 2
                        uiwait(msgbox('First, let us make the handmade averages.'));
                    end

                    add_average = 'yes';
                    while strcmp(add_average, 'yes')
                        % select pairwise comparisons
                        [selection,~] = listdlg('PromptString', 'Select all pairwise comparisons you want to average across: ', 'SelectionMode', 'multiple', 'ListString', pairwise_comparisons, 'ListSize', [500 500]);

                        % add to labelnames
                        mything.average_across{end+1} = cellstr(pairwise_comparisons(selection));

                        % Give name
                        AverageName = inputdlg('Give a name to this pairwise comparison');
                        mything.average_names{end+1} = char(AverageName);

                        % ask whether you want to add another pairwise comparison
                        add_average = questdlg('Would you like to add another average?', 'Add one more?', 'yes','no','yes');
                    end

                    uiwait(msgbox(['The following averages have been added: ' mything.average_names], 'Message', 'modal'));                

                case 2
                    mything.average_across{end+1} = pairwise_comparisons; 
                    mything.average_names{end+1} = 'all_pairwise_comparisons'; 

                    uiwait(msgbox('The average of all pairwise comparisons has been added.', 'Message', 'modal'));
            end
        end

    % if you have done a correlation analysis, you might want to subtract
    % average of non-diagonal from average of diagonal for all conditions, or
    % only for couple of conditions, or even correlate the correlation matrix
    % with a model
    elseif strcmp(SLAvars.Analysis, 'correlation')
        options = {'Subtract all non-diagonal from all diagonal', 'Subtract a couple certain non-diagonal from certain diagonal', 'Calculate the correlation with a certain model (RSA)'};
        [chosen_options,~] = listdlg('PromptString', 'What do you want to do with the correlations? You can select multiple options:', 'SelectionMode', 'multiple', 'ListString', options, 'ListSize', [500 500]); 

        % get out "diagonal" and "nondiagonal" comparisons
        diag_pairwise_comparisons = [];
        nondiag_pairwise_comparisons = [];
        for pc = 1:size(pairwise_comparisons,2)
            underscore = find(pairwise_comparisons{pc} == '_');
            if strcmp(pairwise_comparisons{pc}(1:underscore(round(size(underscore,2)/2))-1), pairwise_comparisons{pc}(underscore(round(size(underscore,2)/2))+1:end))
                diag_pairwise_comparisons{end+1} = pairwise_comparisons{pc};
            else
                nondiag_pairwise_comparisons{end+1} = pairwise_comparisons{pc};
            end
        end

        % ask what you want to do
        if isfield(mything, 'average_diag_across') == 0
            mything.average_diag_across = [];
            mything.average_nondiag_across = [];
            mything.average_names = [];
        end

        for option = 1:size(chosen_options, 2)
            switch chosen_options(option)
                case 1  % all diag minus nondiag
                    mything.average_diag_across{1} = diag_pairwise_comparisons; 
                    mything.average_nondiag_across{1} = nondiag_pairwise_comparisons; 
                    mything.average_names{1} = 'all_diag_minus_all_nondiag';

                    uiwait(msgbox('The comparison of all diagonal minus all nondiagonal has been added.', 'Message', 'modal'));

                case 2  % select couple of comparisons
                    if chosen_options(1) == 1
                        uiwait(msgbox('Now, you can make your own comparisons between diagonal and non-diagonal.', 'Message', 'modal'));
                    end

                    add_comp = 'yes';
                    while strcmp(add_comp, 'yes')
                        % select diag and nondiag comparisons
                        [diag,~] = listdlg('PromptString', 'Select the diagonal comparisons you wish to average across: ', 'SelectionMode', 'multiple', 'ListString', diag_pairwise_comparisons, 'ListSize', [500 500]);
                        [nondiag,~] = listdlg('PromptString', 'Select the non-diagonal comparisons you wish to average across: ', 'SelectionMode', 'multiple', 'ListString', nondiag_pairwise_comparisons, 'ListSize', [500 500]);

                        % add to labelnames
                        mything.average_diag_across{end+1} = cellstr(diag_pairwise_comparisons(diag));
                        mything.average_nondiag_across{end+1} = cellstr(nondiag_pairwise_comparisons(nondiag));

                        % Give name
                        AverageName = inputdlg('Give a name to this average(diag) - average(nondiag) measure:');
                        mything.average_names{end+1} = char(AverageName);

                        % ask whether you want to add another pairwise comparison
                        add_comp = questdlg('Would you like to add another comparison between average(diag) - average(nondiag)?', 'Add one more?', 'yes','no','yes');
                    end 

                    uiwait(msgbox(['The following comparisons of diagonal minus nondiagonal have been added: ' mything.average_names], 'Message', 'modal'));

                case 3  % select the models
                    uiwait(msgbox('In the next window, select the mat-file containing all the models with which you want to correlate your SLA results.', 'Message', 'modal'));
                    [mything.modelsfile, ~] = get_file(dirs.ScriptDir, '*.mat', 'Select the mat-file containing the models:');
                    mything.sim_or_dis = questdlg('Do your correlations have to be transformed to dissimilarities?', 'Similarity or not?', 'Yes','No','Yes');

                    all_conditions = [];
                    for pc = 1:size(pairwise_comparisons,2)
                        underscore = find(pairwise_comparisons{pc} == '_');
                        all_conditions{end+1} = pairwise_comparisons{pc}(1:underscore(round(size(underscore,2)/2))-1);
                    end
                    mything.unique_conditions = unique(all_conditions);
                    
                    for cond = 1:size(mything.unique_conditions,2)
                        inp = inputdlg(['Which column does the condition ' char(mything.unique_conditions(cond)) ' in the models. Give in a number.']);
                        sequence_conds(cond,1) = str2double(cell2mat(inp));
                    end
                    mything.sequence_conds = sequence_conds;
            end  
        end
        
        if isfield(mything, 'fisher_or_not') == 0
            mything.fisher_or_not = questdlg('Do you want to transform the correlations to Fisher correlations?', 'Fisher or not?', 'Yes','No','Yes');
        end
    end
    
    % save the new measures file
    [measuresfile, mything.measuresname] = save_file(dirs.MyThingResultDir, 'Give a name for the file in which you wish to save these measures:', '.mat');
    save(measuresfile, 'mything');
end


