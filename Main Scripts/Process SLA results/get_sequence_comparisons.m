% Function to get the sequence of the conditions

% JB - January 2016

function seq_comp = get_sequence_comparisons(mything)

comp = 1;
for row = 1:size(mything.sequence_conds,1)-1
    for col = row+1:size(mything.sequence_conds,1)
        c1 = mything.unique_conditions{mything.sequence_conds==row};
        c2 = mything.unique_conditions{mything.sequence_conds==col};
        seq_comp{comp} = [c1 '_' c2];
        comp = comp+1;
    end
end