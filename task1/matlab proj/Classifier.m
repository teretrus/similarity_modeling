classdef Classifier
    properties
        people;
        files;
        features;
        featurespace;
        kd_tree;
    end
    
    methods 
        function obj = Classifier(setup)
            fprintf('\nbuilding classifier\n');
            
            obj.files = setup.training_set;
            obj.people = setup.people;
            
            fprintf('    extracting features..                           ');
            obj.features = ExtractFeatures(obj.files);
            fprintf('  -> extracted %d features for each sample\n', size(obj.features, 2));
            
            fprintf('    scaling feature-space to unit-size..\n');
            obj.featurespace = [ min(obj.features); max(obj.features) ];
            obj.features = ScaleFeatures(obj.featurespace, obj.features);
            
            fprintf('    building kd-tree..\n');
            obj.kd_tree = createns(obj.features);
            
            fprintf('    done!\n');
        end
                
        function person_id = Classify(obj, f)
            scaled_f = ScaleFeatures(obj.featurespace, f);
            file_id = knnsearch(obj.kd_tree, scaled_f);
            
            person_id = zeros(size(file_id));
            
            for i = 1 : length(file_id)
                person_id(i) = obj.files{file_id(i)}.person;
            end
        end
    end
end

        
function scaled_f = ScaleFeatures( featurespace, f )
    f_min = repmat(featurespace(1,:), [size(f,1) 1]);
    f_scale = repmat(featurespace(2,:) - featurespace(1,:), [size(f,1) 1]);
    scaled_f = (f - f_min) .* f_scale;
end
