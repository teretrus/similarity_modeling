function Task2
    clear;
    javaclasspath('lib\Weka\weka.jar');   
          
    class_selector = @(f) GenderId(f.gender);  
    class_name_selector = @(c) GenderName(c);
            
    setup =     SetupProject('..\\audio samples\\words\\', 0.5, 0, 15, true, true);                
    c =         WekaClassifier(setup, 'functions.MultilayerPerceptron', class_selector);
                ValidateClassifier(c, setup, 'Task 2', sprintf('Task 2\nmales and females'), '..\\output\\', class_selector, class_name_selector);

    clear; 
    javarmpath('lib\Weka\weka.jar');      
end

function [gender] = GenderName(id)
    if ( id == 1)
        gender = 'Female';
    else
        gender = 'Male';
    end
end

function [id] = GenderId(gender)
    if ( gender == 'f')
        id = 1;
    else
        id = 2;
    end
end