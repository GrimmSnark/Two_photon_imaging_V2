function createUNetForROIExtraction(dataDir, saveLoc, viewTestImages)
% master script for creating and training neural net for cell ROI
% extraction
%
% Inputs: dataDir -  string of folder containing the dataset to train with
%
%         saveLoc - string of folder to save the trained net (OPTIONAL)
%                   default is a subfolder 'Nets' or dataDir
%         
%         viewTestImages - 0/1 flag to view some fo the data used in train
%         with the ROI maks overlaid, 0= do not show, 1 = show (Default =0)




% dataDir = 'D:\Data\2P_Data\Processed\Mouse\neuralNetTestv3'; % data directory
% maskLocation = 'D:\Data\2P_Data\Processed\Mouse\neuralNetTestv3\masks'; % ROI mask directory
% saveLoc = 'D:\Data\2P_Data\Processed\Mouse\neuralNetTestv3\Nets'; % save directory for neural nets

% dataDir = 'D:\Data\2P_Data\Processed\Mouse\neuralNetData\neuralNetCovid19\'; % data directory
% maskLocation = 'D:\Data\2P_Data\Processed\Mouse\neuralNetData\neuralNetCovid19\masks\'; % ROI mask directory
% saveLoc = 'D:\Data\2P_Data\Processed\Mouse\neuralNetData\neuralNetCovid19\Nets\'; % save directory for neural nets
% 


%% defaults

if nargin < 2 || isempty(saveLoc)
saveLoc = [dataDir '\Nets\']; 
end

if nargin < 3 || isempty(viewTestImages)
viewTestImages = 0;
end

maskLocation = [dataDir '\masks\']; % ROI mask directory
patchSize = 256;
testImageNo = 8;
%% load data
imageData = imageDatastore(dataDir);
imageData.ReadSize = 1;

%% get the ROI masks
labeledROIDataStore = pixelLabelDatastore(maskLocation, {'Background', 'Cell'}, [0 255]);

% extract 'patches' gets the data into the right format for processing
dsTrain = randomPatchExtractionDatastore(imageData, labeledROIDataStore, patchSize ,'PatchesPerImage', 20);
dsTrain.MiniBatchSize = 10;

% subset for validation (I know this is double dipping)
num2Validate = 100;
dsValidate = partition(dsTrain,num2Validate,1);

%examine dsTrain
if viewTestImages == 1
    minibatch = preview(dsTrain);
    inputs = minibatch.InputImage;
    responses = minibatch.ResponsePixelLabelImage;
    test = cat(2,inputs,responses);
  
    for x = 1:testImageNo 
    C(:,:,:,x) = labeloverlay(mat2gray(test{x,1}),test{x,2},'Transparency',0.8);
    end
    
    montage(C);
    pause
end

%% build neural net
    inputTileSize = [patchSize patchSize]; % based on the patch extraction size
    numClasses = 2;
    lgraph = unetLayersV2(inputTileSize, numClasses, 'EncoderDepth', 5);
    
    % taken from example 3D segementation MRI
    outputLayer = dicePixelClassificationLayer('Name','Dice Layer Output');
    lgraph = replaceLayer(lgraph,'Segmentation-Layer',outputLayer);
    
    disp(lgraph.Layers)
    
    
    % train options
    initialLearningRate = 0.01;
    maxEpochs = 100;
    minibatchSize = 16;
    l2reg = 0.001;
    
    options = trainingOptions('rmsprop',...
        'ExecutionEnvironment', 'auto', ...
        'InitialLearnRate',initialLearningRate, ...
        'L2Regularization',l2reg,...
        'MaxEpochs',maxEpochs,...
        'MiniBatchSize',minibatchSize,...
        'ValidationData',dsValidate, ...
        'ValidationFrequency',100, ...
        'LearnRateSchedule','piecewise',...
        'Shuffle','every-epoch',...
        'CheckpointPath',[saveLoc '\checkpoint\'], ...
        'GradientThresholdMethod','l2norm',...
        'GradientThreshold',0.05, ...
        'Plots','training-progress', ...
        'VerboseFrequency',50);
    
    
    %% run the net
    modelDateTime = datestr(now,'dd-mmm-yyyy-HH-MM-SS');
    [net,info] = trainNetwork(dsTrain,lgraph,options);
    save([saveLoc '\2P_ROINet_Patch256-' modelDateTime '-Epoch-' num2str(maxEpochs) '.mat'],'net','options');
end