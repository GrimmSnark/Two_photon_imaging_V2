function pixelwiseOrientationSelectivity(folder2Process, noOrientations, angleMax, secondCndDimension, useSTDorMean, channel2Use)
% Function which plots orientation selectivty maps from STD or mean stim
% images
%
% Inputs: folder2Process - processed data folder containing the
%                          experimentStructure.mat, or the fullfile to the 
%                          experimentStructure.mat
%
%         noOrientations - number of orientations tested in the experiment
%                          ie 4/8 etc, default = 8
%
%         angleMax - 360 or 180 for the Max angle tested, default = 360
%
%         secondCndDimension - number of conditions in the second 
%                              dimension, e.g. colors tested, ie 1 for 
%                              black/white, 4 monkey color paradigm, or
%                              number of spatial frequencies etc
%                              default = 1
%
%         useSTDorMean - 0/1 flag for using STD (1) or mean (2) per
%                        condition array for calculations
%                        (OPTIONAL) default = 1 (STD image)
%
%         channel2Use: can specify channel to analyse if there are more 
%                      than one recorded channel
%                      (OPTIONAL) default = 2 (green channel)

%% set defaults

% Allows for the folder2Process to be not the one set in
% experimentStructure.savePath
try
    load(folder2Process, '-mat');
    filePath2Use = dir(filepath);
    experimentStructure.savePath = [filePath2Use.folder '\'] ; 
catch
    load([folder2Process '\experimentStructure.mat']);
    experimentStructure.savePath = [folder2Process '\']; 
end

if nargin <2 || isempty(noOrientations)
    noOrientations = 8;
end

if nargin <3 || isempty(angleMax)
    angleMax = 360;
end

if nargin <4 || isempty(secondCndDimension)
    secondCndDimension = 1;
end

if nargin <5 || isempty(useSTDorMean)
    useSTDorMean = 1;
end

if nargin < 6 || isempty(channel2Use)
    channel2Use = 2;
end

%% Set orientations and conditions appropriately

% get correct number of angles
angles = linspace(0, angleMax, noOrientations+1);

% Plot across full range of angles
anglesUsed2Plot = [0 45 90 135 180];

% angles used to calculate metrics should only be those presented
angles = angles(1:end-1);

% multiple angles by 2 to remove directionality
angles = angles*2;

% duplicate out angles to match number of second dimension, ie
% color/spatial freq etc
if secondCndDimension > 1
    angles = repmat(angles, 1, secondCndDimension);
end


%% get data

% get the appropriate entry to use for calculations
if useSTDorMean ==1
    data2Use = 'stimSTDImageCND';
else
    data2Use = 'stimMeanImageCND';
end

% check number of channels in imaging stack
channelIndxStart = strfind(experimentStructure.filenamesFrame{1}, '_Ch');
for i =1:length(experimentStructure.filenamesFrame)
    channelIdentity{i} = experimentStructure.filenamesFrame{i}(channelIndxStart:channelIndxStart+3);
end
channelNo = unique(channelIdentity);

if length(channelNo)>1
    channelIndentifer = channelNo{channel2Use};
    data2Use = [data2Use channelIndentifer];
    disp(['Using Channel '  num2str(channel2Use) ' for orientation pixel calculation']);
end

% get means per cnd
for cnd = 1:length(experimentStructure.cndTotal)
    eval(['imageData(:,:,cnd) = mean(experimentStructure.' data2Use '(:,:,cnd,:), 4);']);
end

% get the orientation groups for each of the second
totalCnds = 1:length(experimentStructure.cndTotal);
orientationsBy2ndDim = reshape(totalCnds,[],secondCndDimension)';

%% Start calculations
% normalise to max pixel val
imageDataNorm = (imageData / max(imageData(:)));

% reshape into pixel x conditions
imageDataNormReshape = reshape(imageDataNorm,[], length(experimentStructure.cndTotal));

% align angles to each condition for each pixel
pixelAngleArray = cat(3,repmat(angles,length(imageDataNormReshape),1), imageDataNormReshape);


% get the pixel angle pref and magnitude of response across the 2nd stim
% dimension

for x = 1:size(orientationsBy2ndDim,1)
    tempArray = pixelAngleArray(:,orientationsBy2ndDim(x,:),:);
    parfor pixelNo = 1:length(pixelAngleArray)
        outStruct = mean_vector_direction_magnitude(squeeze(tempArray(pixelNo,:,:)));
        pixelPrefArray(pixelNo,:, x) = [outStruct.mean_angle_degrees/2 outStruct.mean_magnitude]; % divide the angle by 2 to bring back into range
    end
end

%% Plot images per second order condition, ie color

for z = 1:secondCndDimension
    %% plot orientation pref image
    % reshape into orientation image
    orientationPrefImage = reshape(pixelPrefArray(:,1,z), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine);
    % rescale into colormap
    orientationPrefImageConverted = (orientationPrefImage/180)*256;
    figure('Position' ,[3841,417,1280,951.333333333333])
    imHandle = imagesc(orientationPrefImageConverted);
    figHandle = imgcf;
    colormap(ggb1)
    clbar = colorbar;
    clbar.Ticks = linspace(0,255, length(anglesUsed2Plot));
    clbar.TickLabels = anglesUsed2Plot;
    axis square
    saveas(figHandle, [experimentStructure.savePath 'Pixel Orientation Pref_Cnd_' num2str(z) '.tif']);
    imwrite(orientationPrefImageConverted, ggb1, [experimentStructure.savePath 'Pixel Orientation Pref_native_Cnd_' num2str(z) '.tif']);
    
    
    close;
    %% plot orientation selectivity image
    % reshape into orientation images
    orientationAmplitudeImage =  reshape(pixelPrefArray(:,2,z), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine);
    
    % correct for NaN and Inf values
    orientationAmplitudeImage(isnan(orientationAmplitudeImage)) = 0;
    
    valuesInAmpMap = unique(sort(orientationAmplitudeImage(:)));
    
    if valuesInAmpMap(end) == Inf
        maxVal =  valuesInAmpMap(end-1);
    else
        maxVal =  valuesInAmpMap(end);
    end
    
    orientationAmplitudeImage(orientationAmplitudeImage == Inf) = maxVal;
    
    % rescale and write Amplitude map in LCS colors
    orientationAmplitudeImageRGB = convertIndexImage2RGB(orientationAmplitudeImage,lcs);
    
    imwrite(orientationAmplitudeImage, [experimentStructure.savePath 'Pixel Orientation Selectivity_native_Cnd_' num2str(z) '.tif'])
    imwrite(orientationAmplitudeImageRGB, [experimentStructure.savePath 'Pixel Orientation Selectivity_native_Cnd_' num2str(z) '_LCS.tif']);
end
end