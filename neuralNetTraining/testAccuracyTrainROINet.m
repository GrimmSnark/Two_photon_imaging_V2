function [DiceAccuracySingleImage, DiceAccAverage ] =  testAccuracyTrainROINet(dataDir,netLoc,example2Test)
% Tests the accuracy of the trained ROI extraction net, produces a single
% dice accuracy for one image and the average across all images in the
% dataset
%
% Inputs: dataDir -  string of folder containing the dataset to train with
%
%         netLoc - string of folder to save the trained net (OPTIONAL)
%                   default is a subfolder 'Nets' or dataDir
%
%         example2Test - number of the single image to test, defauylt = 400
%
% Outputs: DiceAccuracySingleImage - Dice accuracy of the single image
%                                    neural net prediction compared to the
%                                    ground truth ROI mask
%
%          DiceAccAverage - Average dice accuracy of all ROI mask
%                           predictions from the enural net compared to the
%                           ground truth ROI masks 

%% defaults

if nargin < 2 || isempty(netLoc)
netLoc = [dataDir '\Nets\']; 
end

if nargin < 3 || isempty(example2Test)
example2Test = 400;
end

%% load the trained net and data 
nets = dir([netLoc '\*.mat']);

net = load([nets(end).folder '\' nets(end).name], 'net');
net = net.net;

 
maskLocation = [dataDir '\masks\']; % ROI mask directory

imageData = imageDatastore(dataDir);
labeledROIDataStore = pixelLabelDatastore(maskLocation, {'Background', 'Cell'}, [0 255]);


%% test the net

% get example cell image
exampleImage = readimage(imageData,example2Test);

% segement based on trained network
patch_seg = semanticseg(exampleImage, net, 'outputtype', 'uint8');
patch_segCat = semanticseg(exampleImage, net, 'outputtype', 'categorical');

% add filter to remove noise
segmentedImage = medfilt2(patch_seg,[3,3]);
segmentedImageCat = categorical(segmentedImage,[1 2], {'Background', 'Cell'});

% overlay net results onto example image
B = labeloverlay(exampleImage,segmentedImage,'Transparency',0.8);
imshow(B)

%  B = labeloverlay(exampleImage,patch_seg,'Transparency',0.8);
%  imshow(B)

% load and display mask for example cell
masks = readimage(labeledROIDataStore, example2Test);
numLookup = [0 255];
maskConvert = numLookup(masks);

figure;
imshow(maskConvert);

DiceAccuracySingleImage = dice(masks,segmentedImageCat);


%% get average Dice accuracy across the dataset

for i = 1:length(imageData.Files)
    trainDataImage = readimage(imageData,i);
    trainDataMask = readimage(labeledROIDataStore,i);
    
    % segement based on trained network
    patch_seg = semanticseg(trainDataImage, net, 'outputtype', 'uint8');
    
    segmentedImage = medfilt2(patch_seg,[3,3]);
    segmentedImageCat = categorical(segmentedImage,[1 2], {'Background', 'Cell'});
    
    DiceAccuracy(:,i) = dice(trainDataMask,segmentedImageCat);
end

DiceAccAverage = mean(DiceAccuracy,2);

end