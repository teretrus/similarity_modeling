function Main
    setup =     SetupProject('..\\audio samples\\', 'E*.wav', 0.7);
    c =         Classifier(setup);
                ValidateClassifier(c, setup);
end