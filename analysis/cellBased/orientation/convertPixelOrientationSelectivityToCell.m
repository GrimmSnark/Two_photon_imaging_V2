function convertPixelOrientationSelectivityToCell(filepath, noOrientations, angleMax,secondCndDimension, useSTDorMean, channel2Use)
% Function which plots orientation selectivty maps from STD or mean stim
% images and averges them across the full cell ROI
%
% Inputs: filepath - processed data folder containing the
%                     experimentStructure.mat, or the fullfile to the
%                     experimentStructure.mat OR the structure itself
%
%         noOrientations - number of orientations tested in the experiment
%                          ie 4/8 etc, default = 8
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
%
% USAGE: convertPixelOrientationSelectivityToCell('D:\Data\2P_Data\Processed\Monkey\M10_Sully_BF797C\run_11_OIST\TSeries-04042019-0932-012\20200423154339\', 6,180,4,2);
%% set defaults

% Allows for the folder2Process to be not the one set in
% experimentStructure.savePath

% gets the experimentStructure
if ~isobject(filepath)
    try
        load(filepath, '-mat');
        filePath2Use = dir(filepath);
        experimentStructure.savePath = [filePath2Use.folder '\'] ;
    catch
        load([filepath '\experimentStructure.mat']);
        experimentStructure.savePath = [filepath '\'];
    end
else % if variable is the experimentStructure
    experimentStructure = filepath;
    clearvars filepath
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


% set up cell ROI images
cellROIs = experimentStructure.labeledCellROI;
cellMapOrientation = zeros(experimentStructure.pixelsPerLine);
cellMapSelectivity = zeros(experimentStructure.pixelsPerLine);

%% Set orientations and conditions appropriately

% get correct number of angles
angles = linspace(0, angleMax, noOrientations+1);

% angles used to calculate metrics should only be those presented
angles = angles(1:end-1);

% multiple angles by 2 to remove directionality
angles = angles*2;

% Plot across full range of angles
anglesUsed2Plot = [0 45 90 135 180];

% duplicate out angles to match number of second dimension, ie
% color/spatial freq etc
if secondCndDimension > 1
    angles = repmat(angles, 1, secondCndDimension);
end

%% get the data

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

%% Analyses images per second order condition, ie color
for z = 1:secondCndDimension
    
    % reshape into orientation images
    orientationSelectivityImage = reshape(pixelPrefArray(:,1,z), 512, 512);
    orientationAmplitudeImage =  reshape(pixelPrefArray(:,2,z), 512, 512);
    
    
    % correct for NaN and Inf values
    orientationAmplitudeImage(isnan(orientationAmplitudeImage)) = 0;
    valuesInAmpMap = unique(sort(orientationAmplitudeImage(:)));
    
    if valuesInAmpMap(end) == Inf
        maxVal =  valuesInAmpMap(end-1);
    else
        maxVal =  valuesInAmpMap(end);
    end
    
    orientationAmplitudeImage(orientationAmplitudeImage == Inf) = maxVal;
    
    % for each cell average the orientation indexes
    for dd = 1:experimentStructure.cellCount
        % get the index for the pixels within each cell and average them
        % for pref angle and selectivity amplitude
        cellAverageOri(dd) = circ_rad2ang(circ_mean(circ_ang2rad(orientationSelectivityImage(cellROIs == dd))));
        cellSelectivityAmp(dd) = mean(orientationAmplitudeImage(cellROIs == dd));
        
        
        % set average map values per ROI
        cellMapOrientation(cellROIs ==dd) = cellAverageOri(dd);
        cellMapSelectivity(cellROIs ==dd) = cellSelectivityAmp(dd); 
    end
    
    % fill grand arrays
    grandAverageOri(:,z) = cellAverageOri(dd);
    grandAverageSelectivity(:,z) = cellSelectivityAmp(dd);
    cellMapSelectivityPer2ndDim(:,:,z) = cellMapSelectivity;
    
    % rescale into appropriate color levels
    cellMapOrientationConverted = (cellMapOrientation/180)* 256;
    cellMapOrientationConverted(cellMapOrientationConverted==0) = NaN; % set background to Nan
    cellMapOrientationRGB = ind2rgb(round(cellMapOrientationConverted),[ggb1 ; 1 1 1]); % sets the colors to the levels in ggb1 and the NaN to 1
    
    % save Orientation Pref maps
    colormap(ggb1);
    figMap = imshow(cellMapOrientationRGB);
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    colorBar = colorbar ;
    axis on
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    axis square
    tightfig;
    colorBar.Ticks = linspace(0,1, length(anglesUsed2Plot));
    colorBar.TickLabels = anglesUsed2Plot;
    
    saveas(figMap, [experimentStructure.savePath  'Pixel Cell Orientation Pref_Cnd_' num2str(z) '.tif']);
    imwrite(cellMapOrientationRGB, [experimentStructure.savePath 'Pixel Cell Orientation Pref_native_Cnd_' num2str(z) '.tif']);
    
    close();
end

%% Save orientation selectivity maps

% rescales to global max
cellMapSelectivityPerColorRescaled = cellMapSelectivityPer2ndDim/max(cellMapSelectivityPer2ndDim(:));
cellMapSelectivity256 = cellMapSelectivityPerColorRescaled*length(lcs);

for z = 1:secondCndDimension
    cellMapSelectivityRGB = ind2rgb(round(cellMapSelectivity256(:,:,z)), lcs);
    
    % convert to 8bit rgb
    cellMapSelectivityRGB = uint8(floor(cellMapSelectivityRGB*256));
    imwrite(cellMapSelectivityRGB, [experimentStructure.savePath 'Pixel Cell Orientation Selectivity_native_Cnd_' num2str(z) '_LCS.tif']);
    
end

%% Add stuff to experimentStructure

% deals with class object stuff
try
    experimentStructure.pixelCellOrienationAverage = grandAverageOri;
    experimentStructure.pixelCellOrientationSelectivity = grandAverageSelectivity;
catch
    experimentStructure.addprop('pixelCellOrienationAverage');
    experimentStructure.addprop('pixelCellOrientationSelectivity');
   
    experimentStructure.pixelCellOrienationAverage = grandAverageOri;
    experimentStructure.pixelCellOrientationSelectivity = grandAverageSelectivity;
end
save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure', '-v7.3');
end
