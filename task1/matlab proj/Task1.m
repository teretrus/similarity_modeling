function Task1
    clear;
    javaclasspath('lib\Weka\weka.jar');   
           
    class_selector = @(f) f.person;
    class_name_selector = @(c) sprintf('Person %d', c);
            
    setup =     SetupProject('..\\audio samples\\words\\', 0.5, 0, 0, false, true);                
    c =         WekaClassifier(setup, 'functions.MultilayerPerceptron', class_selector);
                ValidateClassifier(c, setup, 'Task 1', sprintf('Task 1\nfemales only'), '..\\output\\', class_selector, class_name_selector);
                               
    clear; 
    javarmpath('lib\Weka\weka.jar');      
end