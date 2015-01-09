function [ files, people ] = ListFiles( base_path, male_offset, female_offset, include_male, include_female)
    file_infos = dir(base_path);    
    file_count = size(file_infos,1);
    
    people = cell([0,1]);
    samples = zeros([0,1]);
    files = cell([0,1]);
    
    regex = '^(?<prefix>word)[-]E(?<code>[0-9]+)[-](?<example>[0-9]+)[-](?<person>[0-9]+)[-](?<gender>[fm])[-](?<age>[0-9]+)(?<ext>[.]wav)$';

    file_i = 1;
    for i = 1 : file_count
       
       r = regexp(file_infos(i).name, regex, 'names');
             
       if (~isempty(r))
           if ((include_male && r.gender == 'm') || (include_female && r.gender == 'f'))
               files{file_i}.path = file_infos(i).name; 
               files{file_i}.path = strcat(base_path,file_infos(i).name); 
               files{file_i}.sample = str2num(r.code); %#ok<ST2NM>
               files{file_i}.person = str2num(r.person)+ 1; %#ok<ST2NM>
               files{file_i}.gender = r.gender;

               if ( r.gender == 'm' )
                   files{file_i}.person = files{file_i}.person + male_offset;
               end
               if ( r.gender == 'f' )
                   files{file_i}.person = files{file_i}.person + female_offset;
               end

               people = RegisterPerson(people,files{file_i}.person,r.gender,str2num(r.age)); %#ok<ST2NM>

               if (size(samples,1) >= files{file_i}.sample)
                   samples(files{file_i}.sample) = samples(files{file_i}.sample) + 1;
               else
                   samples(files{file_i}.sample) = 1;
               end

               file_i = file_i + 1;
           end
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
        if (people{number}.age ~= age)
            throw(MException('RegisterPerson:IntegrityViolation',sprintf('Person %d was registered two times with different ages (%d, %d).', number, people{number}.age, age)));
        end
    else
        people{number, 1}.id = number;
        people{number, 1}.gender = gender;
        people{number, 1}.age = age;
    end    
end