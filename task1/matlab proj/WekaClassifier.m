classdef WekaClassifier
    properties
        people;
        files;
        features;
        featurespace;
        nb;
        train;
        type;
    end
    
    methods 
        function obj = WekaClassifier(setup, type, class_selector)
            obj.type = type;
            fprintf('\nbuilding classifier\n');
            
            obj.files = setup.training_set;
            obj.people = setup.people;
            
            fprintf('    extracting features..                           ');
            obj.features = ExtractFeatures(obj.files);
            fprintf('  -> extracted %d features for each sample\n', size(obj.features, 2));
            
            fprintf('    scaling feature-space to unit-size..\n');
            obj.featurespace = [ min(obj.features); max(obj.features) ];
            obj.features = ScaleFeatures(obj.featurespace, obj.features);
            
            fprintf('    training classifier..\n');
            cleaner = use_weka; %#ok<NASGU>
            
            obj.train = prepare_data('train', obj.features, class_selector, obj.files);
            
            
            obj.nb = trainWekaClassifier(obj.train,type);
            
            fprintf('    done!\n');
        end
                
        function classified_as = Classify(obj, f)
            scaled_f = ScaleFeatures(obj.featurespace, f);
                        
            cleaner = use_weka; %#ok<NASGU>
            
            test = prepare_data('test', scaled_f);
            temp_id = wekaClassify(test,obj.nb);
            
            classified_as = zeros([size(temp_id,1),1]);
            
            for i = 1 : length(classified_as)
                temp_str = char(obj.train.classAttribute().value(int32(temp_id(i))));
                temp_str = temp_str(2:end-1);
                classified_as(i) = str2num(temp_str); %#ok<ST2NM>
            end            
        end
    end
end

function data = prepare_data(name, features, class_selector, varargin)
    numvarargs = length(varargin);
    if numvarargs > 1
        error('prepare_data:TooManyInputs', 'requires at most 1 optional inputs');
    end

    optargs = { 0 };
    newVals = cellfun(@(x) ~isempty(x), varargin);
    optargs(newVals) = varargin(newVals);
    [files] = optargs{:};

    featureNames = cell([1,size(features,2)+1]);
    for i = 1 : size(features,2)
        featureNames{i} = sprintf('"Featrue %d"', i);
    end
    featureNames{size(features,2)+1} = '"class"';

    if (isnumeric(files))
        classes = cell([size(features,1),1]);
        for i = 1 : size(features,1)
            classes{i} = sprintf('"%d"',-1);
        end

        data = [num2cell(features), classes];
        data = matlab2weka(name,featureNames,data);
    else
        classes = cell([size(features,1),1]);
        for i = 1 : size(features,1)
            classes{i} = sprintf('"%d"',class_selector(files{i}));
        end

        data = [num2cell(features), classes];
        data = matlab2weka(name,featureNames,data,size(data,2));
    end
end
        
function cleaner = use_weka          
    cd('lib\Weka');
    cleaner = onCleanup(@() cleanup_weka);        
end
function cleanup_weka
    cd('..\..');
end
        
function scaled_f = ScaleFeatures( featurespace, f )
    f_min = repmat(featurespace(1,:), [size(f,1) 1]);
    f_scale = repmat(featurespace(2,:) - featurespace(1,:), [size(f,1) 1]);
    scaled_f = (f - f_min) .* f_scale;
end
