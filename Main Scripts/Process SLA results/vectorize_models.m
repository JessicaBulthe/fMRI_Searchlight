% Function to vectorize models

function vector_models = vectorize_models(models)

for model = 1:size(models,3)
    element = 1;
    for row = 1:size(models(:,:,model),1)-1
        for col = row+1:size(models(:,:,model),2)
            vector_models(element,model) = models(row,col,model);
            element = element+1;
        end
    end
end