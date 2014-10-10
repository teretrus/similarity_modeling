function setup = SetupProject( base_path, pattern, training_set_ratio )
    fprintf('\nsetting up project\n');
    
    fprintf('    reading input-files..                           ');
    [ setup.files, setup.people ] = ListFiles( base_path, pattern );  
    fprintf('  -> found %d samples (containing %d people)\n', length(setup.files), length(setup.people));
    
    
    fprintf('    splitting into training- and validation-set..   ');
    [setup.training_set, setup.validation_set] = SplitSet(setup.files, training_set_ratio);
    fprintf('  -> %d training-sample, %d validation-samples\n', length(setup.training_set), length(setup.validation_set));
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

function [ files, people ] = ListFiles( base_path, pattern )
    file_infos = dir(strcat(base_path,pattern));    
    file_count = size(file_infos,1);

    files = cell([file_count,1]);
    
    people = cell([0,1]);
    samples = zeros([0,1]);
    
    for i = 1 : file_count
       files{i}.path = file_infos(i).name; 
       
       r = regexp(files{i}.path, '^E([0-9][0-9])-([0-9])-([mw])-([0-9]+)', 'tokens');
                     
       files{i}.path = strcat(base_path,file_infos(i).name); 
       files{i}.sample = str2num(r{1}{1}); %#ok<ST2NM>
       files{i}.person = str2num(r{1}{2})+ 1; %#ok<ST2NM>
       
       people = RegisterPerson(people,files{i}.person,r{1}{3},str2num(r{1}{4})); %#ok<ST2NM>
       
       if (size(samples,1) >= files{i}.sample)
           samples(files{i}.sample) = samples(files{i}.sample) + 1;
       else
           samples(files{i}.sample) = 1;
       end
    end
    
    for i = 1 : size(people,1)
        if (isempty(people{i}))
            %throw(MException('ListFiles:IntegrityViolation',sprintf('Person %d was not registered (but people with higher ids exist).', i)));
        end
    end
    for i = 1 : size(samples,1)
        if (samples(i) ~= size(people,1) && samples(i) ~= 0)
            %throw(MException('ListFiles:IntegrityViolation',sprintf('Sample %d is missing for some people (%d times found, %d times expected).', i, samples(i), size(people,1))));
        end
    end
end

function people = RegisterPerson( people, number, gender, age)
    exists = 0;
    
    if (size(people,1) >= number)
        if (~isempty(people{number}))
            exists = 1;
        end
    end

    if (exists)
        if (people{number}.gender ~= gender)
            throw(MException('RegisterPerson:IntegrityViolation',sprintf('Person %d was registered two times with different genders (%s, %s).', number, people{number}.gender, gender)));
        end
        if (people{number}.age ~= age)
            throw(MException('RegisterPerson:IntegrityViolation',sprintf('Person %d was registered two times with different ages (%d, %d).', number, people{number}.age, age)));
        end
    else
        people{number, 1}.id = number;
        people{number, 1}.gender = gender;
        people{number, 1}.age = age;
    end    
end