function ValidateClassifier(classifier, setup)

    fprintf('\nvalidating classifier\n');
        
    files = setup.validation_set;
    
    fprintf('    extracting features..                           ');
    features = ExtractFeatures(files);
    fprintf('  -> extracted %d features for each sample\n', size(features, 2));
    
    fprintf('    classifying..                                   ');
    classified_as = classifier.Classify(features);
    
    errors = 0;
    
    for i = 1 : length(files)
        if ( files{i}.person ~= classified_as(i) )
            errors = errors + 1;
        end
    end
    
    fprintf('  -> %d %% success (%d errors)!\n\n', round(100*(length(files)-errors)/length(files)), errors);
end