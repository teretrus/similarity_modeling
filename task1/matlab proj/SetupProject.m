function setup = SetupProject( base_path, training_set_ratio, male_offset, female_offset, include_male, include_female )
    fprintf('\nsetting up project\n');
    
    fprintf('    reading input-files..                           ');
    [ setup.files, setup.people ] = ListFiles( base_path, male_offset, female_offset, include_male, include_female );  
    
    peopleCount = 0;
    for i = 1 : length(setup.people)
        if (~isempty(setup.people))
            peopleCount = peopleCount + 1;
        end
    end
    
    fprintf('  -> found %d samples (containing %d people)\n', length(setup.files), peopleCount);
    
    
    fprintf('    splitting into training- and validation-set..   ');
    [setup.training_set, setup.validation_set] = SplitSet(setup.files, training_set_ratio);
    fprintf('  -> %d training-sample (~%d%%), %d validation-samples  (~%d%%)\n', length(setup.training_set), round(100*length(setup.training_set)/length(setup.files)), length(setup.validation_set), round(100*length(setup.validation_set)/length(setup.files)));
end

function [training_set, validation_set] = SplitSet(files, training_set_ratio)
    for i = 1 : length(files)
        samples_num(files{i}.sample) = 1; %#ok<AGROW>
    end
    has_sample = 0;
    for i = 1 : length(samples_num)
        if (samples_num(i) ~= 0)
            if (has_sample == 0)
                samples = samples_num(i);
                has_sample = 1;
            else                
                samples = [samples i]; %#ok<AGROW>
            end
        end
    end
    
    people_count = length(files)/length(samples);
    [~,idx]=sort(rand(length(samples),1));
    
    training_sample_count = round(length(samples)*training_set_ratio);
    validation_sample_count = length(samples)-training_sample_count;
    
    training_samples = samples(idx(1:training_sample_count));
    
    training_set = cell([people_count*training_sample_count,1]);
    validation_set = cell([people_count*validation_sample_count,1]);

    training_i = 1;
    validation_i = 1;
    for i = 1 : length(files)
        if (sum(training_samples==files{i}.sample)==0)
            validation_set{validation_i} = files{i};
            validation_i = validation_i + 1;
        else
            training_set{training_i} = files{i};
            training_i = training_i + 1;
        end        
    end
end


