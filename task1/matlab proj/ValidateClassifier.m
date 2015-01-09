function ValidateClassifier(classifier, setup, caption, detail_caption, output_path, class_selector, class_name_selector)

    fprintf('\nvalidating classifier\n');
        
    files = setup.validation_set;
    
    fprintf('    extracting features..                           ');
    features = ExtractFeatures(files);
    fprintf('  -> extracted %d features for each sample\n', size(features, 2));
    
    fprintf('    classifying..                                   ');
    classified_as = classifier.Classify(features);
    
    errors = 0;
    
    ground_truth = zeros([length(files),1]);
    classes = zeros([0,1]);
    
    for i = 1 : length(files)
        ground_truth(i) = class_selector(files{i});
        
        classes(class_selector(files{i})) = 1;
        
        if (class_selector(files{i}) ~= classified_as(i) )
            errors = errors + 1;
        end
    end
    
    decicion_values = zeros([length(files),length(classes)]);
    
    for i = 1 : length(files)
        decicion_values(i,classified_as(i)) = 1;
    end
    
    density = get(0,'ScreenPixelsPerInch');
    rez = 1200;
    resolution = [1080 1920];
    
    
    f = figure('Name', sprintf('ROC curves of %s',caption)); hold all;
    colormap('jet'); 
    cmap = colormap;
    
    h = zeros(0,1);
    
    for class_i = 1:length(classes)
        [X,Y] = perfcurve(ground_truth, decicion_values(:,class_i), class_i);  
        hold on;
        h(class_i) = plot(X,Y,'Color', cmap(int8(class_i*size(cmap,1)/length(classes)),:), 'DisplayName', class_name_selector(class_i));
    end
        
    hold all;
    legend(h);

    hold all;
    xlabel('Precision (false positive)');
    hold all;
    ylabel('Recall (true positive)');
    
    hold all;
    title(sprintf('ROC curves of %s',detail_caption));
    
    set(f, 'Position', [0 0 1920 1080]);
    set(f, 'paperunits','inches');
    set(f, 'papersize', density ./ resolution);
    set(f, 'paperposition',[0 0  density ./ resolution]);
   
    %http://stackoverflow.com/questions/12160184/how-to-save-a-figure-in-matlab-from-the-command-line
    
    %hold all;
    %print(f, [output_path 'task1.roc.jpg'],'-djpeg',['-r',num2str(rez)],'-opengl');
    %close(f);
    
    
    f = figure('Name', sprintf('ROC curves of %s - Separately',caption)); hold all;
    colormap('jet'); 
    cmap = colormap;
        
    for class_i = 1:length(classes)
        subplot(5,3,class_i);
        hold all;
        [X,Y] = perfcurve(ground_truth, decicion_values(:,class_i), class_i);  
        hold all;
        h = plot(X,Y,'Color', cmap(int8(class_i*size(cmap,1)/length(classes)),:), 'DisplayName', class_name_selector(class_i));
        
        hold all;
        legend(h);
        
        hold all;
        title(sprintf('ROC curves of %s - Class %d',detail_caption, class_i));

        hold all;
        xlabel('Precision (false positive)');
        hold all;
        ylabel('Recall (true positive)');
    end
    
    set(f, 'Position', [0 0 1920 1080]);
    set(f, 'paperunits','inches');
    set(f, 'papersize', density ./ resolution);
    set(f, 'paperposition',[0 0  density ./ resolution]);
   
    %hold all;
    %print(f, [output_path 'task1.roc.separate.jpg'],'-djpeg',['-r',num2str(rez)],'-opengl');
    %close(f);
    
    fprintf('  -> %d %% success (%d errors)!\n\n', round(100*(length(files)-errors)/length(files)), errors);
end