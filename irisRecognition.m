clc;
clear all;
close all;

databasePath = 'iris_database'; 
dbFiles = dir(fullfile(databasePath, '*.bmp')); 

hFig = figure('Name', 'Iris Recognition from IIT Delhi Database', ...
              'NumberTitle', 'off', 'Position', [100, 100, 800, 700], 'Resize', 'off');

uicontrol('Style', 'text', 'String', 'Iris Recognition from IIT Delhi Database', ...
          'Units', 'normalized', 'Position', [0.2, 0.95, 0.6, 0.05], ...
          'FontSize', 14, 'FontWeight', 'bold', 'BackgroundColor', get(hFig, 'Color'), ...
          'HorizontalAlignment', 'center');


hAxesInput = axes('Parent', hFig, 'Units', 'normalized', 'Position', [0.05, 0.5, 0.4, 0.4]);
title(hAxesInput, 'Input'); 

hAxesRecognized = axes('Parent', hFig, 'Units', 'normalized', 'Position', [0.55, 0.5, 0.4, 0.4]);
title(hAxesRecognized, 'Recognized'); 

uicontrol('Parent', hFig, 'Style', 'text', 'String', 'Recognized Image: None', ...
          'Units', 'normalized', 'Position', [0.55, 0.4, 0.4, 0.05], ...
          'FontSize', 10, 'HorizontalAlignment', 'left');

setappdata(hFig, 'databasePath', databasePath);
setappdata(hFig, 'dbFiles', dbFiles);

hAxesInput = axes('Parent', hFig, 'Units', 'normalized', 'Position', [0.05, 0.5, 0.4, 0.4]);

setappdata(hFig, 'hAxesInput', hAxesInput);

hAxesRecognized = axes('Parent', hFig, 'Units', 'normalized', 'Position', [0.55, 0.5, 0.4, 0.4]);

setappdata(hFig, 'hAxesRecognized', hAxesRecognized);

% Create static text for displaying recognized image name
hRecognizedText = uicontrol('Parent', hFig, 'Style', 'text', 'Units', 'normalized', ...
                            'Position', [0.55, 0.4, 0.4, 0.05], ...
                            'String', 'Recognized Image: None', ...
                            'FontSize', 10, 'HorizontalAlignment', 'left');
setappdata(hFig, 'hRecognizedText', hRecognizedText);

% Create buttons for actions
uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'Load Image', ...
          'Units', 'normalized', 'Position', [0.1, 0.2, 0.3, 0.1], ...
          'FontSize', 12, 'Callback', @(src, event) loadImageCallback(hFig));

uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'Add Image to Database', ...
          'Units', 'normalized', 'Position', [0.1, 0.05, 0.3, 0.1], ...
          'FontSize', 12, 'Callback', @(src, event) addImageCallback(hFig));

uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'Delete Image from Database', ...
          'Units', 'normalized', 'Position', [0.6, 0.05, 0.3, 0.1], ...
          'FontSize', 12, 'Callback', @(src, event) deleteImageCallback(hFig));

function loadImageCallback(hFig)
    hAxesInput = getappdata(hFig, 'hAxesInput');
    databasePath = getappdata(hFig, 'databasePath');
    dbFiles = getappdata(hFig, 'dbFiles');

    [fileName, filePath] = uigetfile({'*.bmp;*.png;*.jpg'}, 'Select an Iris Image for Testing');
    if fileName == 0
        return;
    end
    inputImage = imread(fullfile(filePath, fileName));
    
    
    setappdata(hFig, 'loadedImage', inputImage);
    
    
    [~, ~, success, steps] = preprocessAndExtractIrisWithGabor(inputImage, false);
    if ~success
        msgbox('Error in preprocessing the image.', 'Error', 'error');
        return;
    end

    
    for i = 1:length(steps)
        pause(0.5); 
        if ~isempty(steps{i}) && isnumeric(steps{i})
            imshow(steps{i}, [], 'Parent', hAxesInput);
            title(hAxesInput, ['Step ', num2str(i)]);
        else
            disp(['Step ', num2str(i), ' is invalid.']);
        end
    end

    
    [recognizedImage, recognizedName] = recognizeIris(inputImage, databasePath, dbFiles);
    hAxesRecognized = getappdata(hFig, 'hAxesRecognized');
    hRecognizedText = getappdata(hFig, 'hRecognizedText');

    if isempty(recognizedImage)
        msgbox('No match found for the iris.', 'Recognition Result', 'warn');
        imshow([], 'Parent', hAxesRecognized); 
        set(hRecognizedText, 'String', 'Recognized Image: None');
    else
        imshow(recognizedImage, [], 'Parent', hAxesRecognized);
        set(hRecognizedText, 'String', ['Recognized Image: ', recognizedName]);
    end
end

function addImageCallback(hFig)
    
    inputImage = getappdata(hFig, 'loadedImage'); 
    
    if isempty(inputImage)
        msgbox('No image has been loaded for recognition!', 'Error', 'error');
        return;
    end
    
    
    databasePath = getappdata(hFig, 'databasePath');
    dbFiles = getappdata(hFig, 'dbFiles');
    
   
    newFileName = ['image_', datestr(now, 'yyyymmdd_HHMMSS'), '.bmp']; 
    newFilePath = fullfile(databasePath, newFileName);
    
    imwrite(inputImage, newFilePath);
    

    dbFiles = dir(fullfile(databasePath, '*.bmp'));
    setappdata(hFig, 'dbFiles', dbFiles); 
    
  
    msgbox(['Image successfully added to the database as ', newFileName], 'Success');
end



function deleteImageCallback(hFig)
    databasePath = getappdata(hFig, 'databasePath');
    dbFiles = getappdata(hFig, 'dbFiles');

    [fileName, ~] = uigetfile(fullfile(databasePath, '*.bmp'), 'Select an Image to Delete from Database');
    if fileName == 0
        return;
    end
    delete(fullfile(databasePath, fileName));
    dbFiles = dir(fullfile(databasePath, '*.bmp'));
    setappdata(hFig, 'dbFiles', dbFiles); 
    msgbox('Image successfully deleted from the database.', 'Success');
end

% Iris Recognition Function
function [recognizedImage, recognizedName] = recognizeIris(testImage, databasePath, dbFiles)
    recognizedImage = [];
    recognizedName = '';
    minDistance = Inf;

    
    [testGaborFeatures, testSuccess] = preprocessAndExtractIrisWithGabor(testImage, false);
    if ~testSuccess
        return;
    end

    % Compare with database images
    for i = 1:length(dbFiles)
        dbImage = imread(fullfile(databasePath, dbFiles(i).name));
        [dbGaborFeatures, dbSuccess] = preprocessAndExtractIrisWithGabor(dbImage, false);
        if ~dbSuccess
            continue;
        end

        % Compute distance
        distance = norm(testGaborFeatures - dbGaborFeatures);
        if distance < minDistance
            minDistance = distance;
            recognizedImage = dbImage;
            recognizedName = dbFiles(i).name;
        end
    end

    % Check recognition threshold
    if minDistance >= 0.5
        recognizedImage = [];
        recognizedName = '';
    end
end
