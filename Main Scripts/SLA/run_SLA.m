%% Run the SLA for every subject, for every pairwise comparison

% Author: JB - January 2015 


function run_SLA(SubjectIDs, labelnames, dirs, cfg, Mask)

%% Run the analysis per subject
for s = 1:size(SubjectIDs,2)
    % Get current SubjectID
    SubjectID = char(SubjectIDs(s));

    %% Run the analyses per classification pair
    for classification_pair = 1:size(labelnames,2)
        clc;

        % SubjectSpecific directories
        SubjectDataDir = [dirs.DataDir SubjectID filesep dirs.selected_model];
        SubjectResultDir = [dirs.ResultDir SubjectID filesep char(labelnames{classification_pair}(1)) '_' char(labelnames{classification_pair}(2)) filesep];
        
        % Make Result Directory if it doesn't exist yet
        if exist(SubjectResultDir, 'dir') ~= 7
            mkdir(SubjectResultDir);
        end
        
        % Where should results be saved?
        cfg.results.dir = SubjectResultDir;

        % Specify the directory to your SPM.mat and all related beta images
        beta_dir = SubjectDataDir;

        % Specify the specific labels 
        labelname1 = char(labelnames{classification_pair}(1));
        labelname2 = char(labelnames{classification_pair}(2));
        
        % Specify the mask 
        if exist('Mask', 'var') == 1
            cfg.files.mask = Mask;
        else
            maskfile = dir([beta_dir 'mask.*']);
            cfg.files.mask = [beta_dir maskfile(1).name];
        end

        % The following function extracts all beta names and corresponding run
        % numbers from the SPM.mat. 
        regressor_names = design_from_spm(beta_dir);

        % Now with the names of the labels, we can extract the filenames and the 
        % run numbers of each label. The labels will be 1 and -1.
        cfg = decoding_describe_data(cfg,{labelname1 labelname2},[1 -1],regressor_names,beta_dir);

        % This creates the leave-one-run-out cross validation design:
        cfg.design = make_design_cv(cfg);
        
        % Show information
        disp(['Subject: ' SubjectID]);
        disp(['Classification: ' labelname1 ' vs ' labelname2]);
       
        % Do the decoding
        results = decoding(cfg);
        
        % Close design fig
        close(gcf);
        
        % Clear certain variables
        fields = {'files', 'design'};
        cfg = rmfield(cfg, fields);
    end
end
