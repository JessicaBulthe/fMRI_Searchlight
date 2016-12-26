%% Do the analysis that you want 
% In this script, all the calculations for the measures that you have made
% will be done. It will save for every measure, for every subject a volume
% file in your result directory. 

% JB - January 2016

function analyze_SLA_results(mything, dirs, SubjectIDs)

%% ResultDir
[~, mything.measuresname, ~] = fileparts(mything.measuresname);
dirs.MyThingResultDir = [dirs.MyThingResultDir mything.measuresname filesep];

%% For decoding
if strcmp(mything.analysis, 'decoding')
    for subject = 1:size(SubjectIDs, 2)
        % Get current SubjectID
        SubjectID = char(SubjectIDs(subject));
        
        % The DataDir for that SubjectID
        SubjectDataDir = [dirs.SLAResultDir SubjectID filesep];
        
        for measure = 1:size(mything.average_names,2)
            % calculate average for diag comparisons
            [average] = calculate_average(mything.average_across{measure}, SubjectDataDir);
                        
            % Subtract -0.50 from the averages
            [r,c,v] = ind2sub(size(average),find(average ~= 0));
            minus_chancelevel = NaN(size(average));
            for voxel = 1:size(r,1)
                minus_chancelevel(r(voxel),c(voxel),v(voxel)) = average(r(voxel),c(voxel),v(voxel))-0.50;
            end
            
            minus_chancelevel(minus_chancelevel == 0) = NaN;
            
            % save the volume
            MeasureDir = [dirs.MyThingResultDir mything.average_names{measure} filesep];
            if exist(MeasureDir, 'dir') ~= 7
                mkdir(MeasureDir);
            end
            
            save_volume(SubjectID, SubjectDataDir, char(mything.average_across{measure}(1)), dirs, MeasureDir, minus_chancelevel);
        end % end measure
    end % end subject

%% For correlation
elseif strcmp(mything.analysis, 'correlation')
    if isfield(mything, 'average_diag_across') == 1
        for subject = 1:size(SubjectIDs, 2)
            % Get current SubjectID
            SubjectID = char(SubjectIDs(subject));

            % The DataDir for that SubjectID
            SubjectDataDir = [dirs.SLAResultDir SubjectID filesep];

            for measure = 1:size(mything.average_names,2)
                % calculate average for diag comparisons
                [averages.diag] = calculate_average(mything.average_diag_across{measure}, SubjectDataDir);

                % calculate average for nondiag comparisons
                [averages.nondiag] = calculate_average(mything.average_nondiag_across{measure}, SubjectDataDir);

                % calculate the difference
                averages.diag(averages.diag == 0) = NaN;
                averages.nondiag(averages.nondiag == 0) = NaN;
                averages.difference = averages.diag - averages.nondiag;
%                 averages.difference(isnan(averages.difference) == 1) = 0;

                % do fisher correlations if requested
                if strcmp(mything.fisher_or_not, 'Yes')
                    averages.difference = .5*log((1+averages.difference)./(1-averages.difference));
                end

                % save the volume
                MeasureDir = [dirs.MyThingResultDir mything.average_names{measure} filesep];
                if exist(MeasureDir, 'dir') ~= 7
                    mkdir(MeasureDir);
                end

                save_volume(SubjectID, SubjectDataDir, char(mything.average_diag_across{measure}(1)), dirs, MeasureDir, averages.difference);

            end % end measure
        end % end subject
    end % end if average_diag_across

    if isfield(mything, 'modelsfile') == 1
        for subject = 1:size(SubjectIDs, 2)
            % Get current SubjectID
            SubjectID = char(SubjectIDs(subject));

            % The DataDir for that SubjectID
            SubjectDataDir = [dirs.SLAResultDir SubjectID filesep];

            % Load model
            load(mything.modelsfile);

            % Vectorize models in correct order
            vector_models = vectorize_models(models);

            % Sequence conditions
%             sequence_comparisons = get_sequence_comparisons(mything);
            sequence_comparisons = mything.average_nondiag_across{1};
            
            % Get all the results for on subject
            for comp = 1:size(sequence_comparisons,2)
                [all_results(:,:,:,comp)] = get_SLA_file([SubjectDataDir sequence_comparisons{comp}]);
            end

            % Get the voxels that have a value for all the pairwise comparisons 
            voxelcoord = get_voxel_coords(all_results);

            % For every voxel get the correlation between conditions and model
            RSA_results = zeros(size(all_results,1), size(all_results,2), size(all_results,3), size(models,3));
            RSA_results(:,:,:,:) = NaN; 
            for model = 1:size(models,3)
                for voxel = 1:size(voxelcoord,1)
                    neural_corr(:,1) = all_results(voxelcoord(voxel,1), voxelcoord(voxel,2), voxelcoord(voxel,3), :);
                    RSA_corr = corr(neural_corr, vector_models(:,model));

                    % do fisher correlations if requested
                    if strcmp(mything.fisher_or_not, 'Yes')
                        RSA_corr = .5*log((1+RSA_corr)./(1-RSA_corr));
                    end

                    RSA_results(voxelcoord(voxel,1), voxelcoord(voxel,2), voxelcoord(voxel,3), model) = RSA_corr;
                end
            end

            % Save the results
            for model = 1:size(models,3)
                MeasureDir = [dirs.MyThingResultDir 'RSA' filesep 'Model ' num2str(model) filesep];
                if exist(MeasureDir, 'dir') ~= 7
                    mkdir(MeasureDir);
                end

                save_volume(SubjectID, SubjectDataDir, sequence_comparisons{1}, dirs, MeasureDir, RSA_results(:,:,:,model));
            end
            
            clear all_results RSA_results voxelcoord
        end % for subject
    end % end if modelsfile
end % if decoding or correlation