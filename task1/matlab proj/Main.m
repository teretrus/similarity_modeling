function Main
    setup =     SetupProject('..\\audio samples\\', 0.7);
    c =         Classifier(setup);
                ValidateClassifier(c, setup);
end