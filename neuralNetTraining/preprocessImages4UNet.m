function preprocessImages4UNet(imagesDir)
% Creates ROI masks used in training the neural net and expands the data
% set through rotations and flips of both the images and masks.
%
% Inputs: imagesDir - string of folder containing the original data to 
%                     train with

% imagesDir = 'D:\Data\2P_Data\Processed\Mouse\neuralNetTestv2\'; % data directory
% maskDir = 'D:\Data\2P_Data\Processed\Mouse\neuralNetTestv2\masks\'; % ROI mask directory
% saveDir = 'D:\Data\2P_Data\Processed\Mouse\neuralNetTestv3\';

%% Defaults

parentFolder = dir(imagesDir);

maskDir = [parentFolder(1).folder '\masks'];
saveDir =parentFolder(1).folder;


%% load in example image
tiffList = dir([imagesDir '*tif']);
exampleImage = read_Tiffs([tiffList(1).folder '\' tiffList(1).name]);

%% creates ROI masks
% create image ROI masks
intializeMIJ;
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();

roiFiles = dir([imagesDir '\*.zip']);

for i = 1:length(roiFiles)
    RC.runCommand('Open', [roiFiles(i).folder '\' roiFiles(i).name]); % opens zip file
    ROIobjects = RC.getRoisAsArray;
    labeledROI(:,:,i) = createLabeledROIFromImageJPixels([size(exampleImage)] ,ROIobjects);
    RC.runCommand('Delete'); % resets ROIs if you select clear all
end

% binarize to 8bit
labeledROI(labeledROI>0) = 255;

% save masks to then use as datastore
options.overwrite = true;
for x = 1:size(labeledROI, 3)
    saveastiff(labeledROI(:,:,x), [imagesDir '\Mask_' sprintf( '%03d' ,x) '.tif' ], options);
end

%% manipulate data

% load data back it
images = readMultipageTifFiles(imagesDir);
masks = readMultipageTifFiles(maskDir, 'uint8');

imagesExpanded = images;
masksExpanded = masks;


% expand images by rotating 90, 180, 270 (x3 image data size)
rotations = [90 180 270];

for i =1:length(rotations)
    rotatedImages = rot90(images,i);
    rotatedMasks = rot90(masks,i);
    
    imagesExpanded = cat(3,imagesExpanded,rotatedImages);
    masksExpanded = cat(3,masksExpanded,rotatedMasks);
end

% flip vertical and horizontal (x4 image data size)
imagesFlip1 = flip(imagesExpanded,1);
imagesFlip2 = flip(imagesExpanded,2);

masksFlip1 = flip(masksExpanded,1);
masksFlip2 = flip(masksExpanded,2);


imagesExpanded = cat(3,imagesExpanded,imagesFlip1, imagesFlip2);
masksExpanded = cat(3,masksExpanded,masksFlip1, masksFlip2);


% double those images by normalizing LUT values to 0-1 x 255
normImages = uint16(round(mat2gray(imagesExpanded) * 65535));

% saturate image to make neural net prediction better
adjustedImages = imadjust(imagesExpanded);

% collate all the images
imagesExpanded = cat(3,imagesExpanded,normImages, adjustedImages);
masksExpanded = cat(3, masksExpanded, masksExpanded, masksExpanded);


% save Images
for x = 1:size(imagesExpanded,3)
    saveastiff(imagesExpanded(:,:,x), [saveDir 'image_' sprintf( '%04d' ,x) '.tif' ]);
    saveastiff(masksExpanded(:,:,x), [saveDir '\masks\mask_' sprintf( '%04d' ,x) '.tif' ]);
end
end