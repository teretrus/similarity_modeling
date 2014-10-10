function [features] = ExtractFeatures(files)
    featrues = zeros([length(files), 0]); %#ok<NASGU>
    
    for i = 1 : length(files)
       features(i, :) = ExtractFeaturesSingleFile(files{i}.path); %#ok<AGROW>
    end
end

function features = ExtractFeaturesSingleFile(file)
    [x, fs] = audioread(file);
    x0 = x(:,1);
    
    cd('lib\\Matlab Audio Analysis Library');
    cleaner = onCleanup(@() cd ('..\\..'));
    
    features = stFeatureExtraction(x0, fs, length(x0)/fs, 1/fs)';
end