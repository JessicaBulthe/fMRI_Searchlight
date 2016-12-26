%% Calculate average across couple of SLA file.
% JB - january 2016


function [average] = calculate_average(comparisons, SubjectDataDir)

for comp = 1:size(comparisons,2)
    [result] = get_SLA_file([SubjectDataDir char(comparisons(comp))]);
    
    % check if summatrix already exists
    % if not, create the variable with the right dimensions
    if exist('summatrix', 'var') == 0
        dim = size(result);
        summatrix = zeros(dim(1), dim(2), dim(3));
    end
    
    % add the result to the summatrix
    summatrix = summatrix + result;
    
    % clear variable
    clear result;
end

average = summatrix/size(comparisons,2);
