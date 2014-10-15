function Main
    clear;
    javaclasspath('lib\Weka\weka.jar');   
            
            
    setup =     SetupProject('..\\audio samples\\', 0.7);
    %c =         Classifier(setup);
    %            ValidateClassifier(c, setup);
                
    %c =         WekaClassifier(setup, 'bayes.NaiveBayes');
    %            ValidateClassifier(c, setup);
                
    c =         WekaClassifier(setup, 'functions.MultilayerPerceptron');
                ValidateClassifier(c, setup);
                               
    clear; 
    javarmpath('lib\Weka\weka.jar');      
end