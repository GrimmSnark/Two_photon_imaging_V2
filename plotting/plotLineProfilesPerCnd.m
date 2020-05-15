function plotLineProfilesPerCnd(filepath, channel2Use, noOrientations, angleMax, secondCndDimension, secondCndDimensionLabels)
% Plots images of line dynamics over average condition trials in both
% normalized response (to the max in the recording) and log scaled image
% responses
%
% Inputs:  filepath - processed data folder containing the
%                     experimentStructure.mat, or the fullfile to the
%                     experimentStructure.mat OR the structure itself
%
%          channel2Use: can specify channel to register the stack with
%                            if there are more than one recorded channel
%                           (OPTIONAL) default = 2 (green channel)
%
%          noOrientations - number of orientations tested in the experiment
%                          ie 4/8 etc, default = 8
%
%          angleMax - 360 or 180 for the Max angle tested, default = 360
%
%          secondCndDimension - number of conditions in the second
%                               dimension, e.g. colors tested, ie 1 for
%                               black/white, 4 monkey color paradigm, or
%                               number of spatial frequencies etc
%                               default = 1
%
%
%          secondCndDimensionLabels - This should be a cell string array
%                                     for labels of the second dimension.
%                                     Only used if secondCndDimension > 1.
%                                     Can either be string cell array size
%                                     of secondCndDimension OR a single
%                                     label which indicates a set of
%                                     values, ie 'NHP_Color' sets the
%                                     labels from
%                                     PTBOrientationColorValuesMonkeyV2.mat

%% set default

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

if nargin < 2 || isempty(channel2Use)
    channel2Use = 2;
end

if nargin < 3 || isempty(noOrientations)
    noOrientations = 8;
end

if nargin < 4 || isempty(angleMax)
    angleMax = 360;
end

if nargin < 5 || isempty(secondCndDimension)
    secondCndDimension = 1;
    scndDimLabels = {'Orientations'};
end


% sort out second dimension labels....This is still under development
% if there are more than one dimension apart from orientation
if secondCndDimension > 1
    
    % checks if the label field is empty and sets to default
    if nargin < 6 || isempty(secondCndDimensionLabels)
        secondCndDimensionLabels = {'NHP_Color'};
    end
    
    % if the labels are set by string cell array function input
    if length(secondCndDimensionLabels)>1
        scndDimLabels = secondCndDimensionLabels;
    else % if indivdual marker i.e 'NHP_color' or standard set of variables switches through cases
        switch secondCndDimensionLabels{:}
            case 'NHP_Color'
                [~, scndDimLabels] = PTBOrientationColorValuesMonkeyV2;
                scndDimLabels = scndDimLabels(2:end);
        end
    end
end


% get the appropriate magnification for ROI image
screenDim = get(0,'ScreenSize');
if screenDim(3) > 2000
    magSize = 300; % magnification for image viewing in %
else
    magSize = 200; % magnification for image viewing in %
end

%% Create the appropriate images for ROI extraction

% finds all the relevant images for ROI chosing
files = dir([experimentStructure.savePath 'STD_Average*']);

if size(files,1) ==1 % if single channel recording
    imageROI = read_Tiffs([experimentStructure.savePath 'STD_Average.tif'],1); % reads in average image
    imageROI = uint16(mat2gray(imageROI)*65535);
    %     imageROI = imadjust(imageROI); % saturate image to make neural net prediction better
end

% initalize MIJI and get ROI manager open
intializeMIJ;
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();


%  if multiple channels, build the average image for ROI extraction
if size(files,1) >1 % if multiple channel recording
    
    % This section uses mostly ImageJ/FIJI code, ie java
    
    % open both images in FIJI
    impChan1 = ij.IJ.openImage([experimentStructure.savePath 'STD_Average_Ch1.tif']);
    impChan2 = ij.IJ.openImage([experimentStructure.savePath 'STD_Average_Ch2.tif']);
    
    % get processor for each images
    chan1Process = impChan1.getProcessor();
    chan2Process = impChan2.getProcessor();
    
    % do background subbtraction to clean up the image a bit
    ij.plugin.filter.BackgroundSubtracter().rollingBallBackground(chan1Process, 50, 0, 0 ,0,0,0);
    ij.plugin.filter.BackgroundSubtracter().rollingBallBackground(chan2Process, 50, 0, 0 ,0,0,0);
    
    % make a stack of the images
    chanStack = ij.ImageStack(chan1Process.getWidth, chan1Process.getHeight);
    chanStack.addSlice(impChan1.getTitle, chan1Process);
    chanStack.addSlice(impChan2.getTitle, chan2Process);
    
    chanStackImagePlus = ij.ImagePlus('Channel Stack', chanStack);
    
    % do a max projection across the images, get the brightest cells
    % regardless of the channel
    maxIntensityImp = ij.plugin.ZProjector.run(chanStackImagePlus, 'max');
    maxIntensityImp.show;
    
    % get the image matrix and rescale to use the full 16bit
    imageROI = MIJ.getImage('MAX_Channel Stack');
    MIJ.close;
    imageROI = uint16(mat2gray(imageROI)*65535);
    
    % save image
    if ~exist([experimentStructure.savePath 'Max_Project.tif'])
        saveastiff(imageROI, [experimentStructure.savePath 'Max_Project.tif']);
    end
    
    %     imageROI = imadjust(imageROI); % saturate image to make neural net prediction better
end


% get image to FIJI
MIJImageROI = MIJ.createImage('ROI_image',imageROI,true); %#ok<NASGU> supressed warning as no need to worry about
ij.process.ImageConverter(MIJImageROI).convertToRGB;


% load in pixel preference images if they exist
pixelPrefImages = dir([experimentStructure.savePath 'Pixel Orientation Pref_native*']);

% get all the FIJI stuff for each image
for i =1:length(pixelPrefImages)
    eval(['imp' num2str(i) '= ij.IJ.openImage([experimentStructure.savePath pixelPrefImages(' num2str(i) ').name]);']);
    eval(['processor' num2str(i) '= imp' num2str(i) '.getProcessor();']);
end

% create empty stack
pixelPrefStack = ij.ImageStack(imp1.getWidth, imp1.getHeight);

% fill stack with images
for i =1:length(pixelPrefImages)
    eval(['pixelPrefStack.addSlice(imp' num2str(i) '.getTitle, processor' num2str(i) ');']);
end

% display stack
stackImagePlusObj = ij.ImagePlus('Pixel Orientation Stack.tif', pixelPrefStack);
stackImagePlusObj.show; 
ij.process.ImageConverter(stackImagePlusObj).convertToRGB;


% load in pixel selectivity images if they exist
pixelSelectivityImages = dir([experimentStructure.savePath 'Pixel Orientation Selectivity_native*LCS.tif']);

% get all the FIJI stuff for each image
for i =1:length(pixelSelectivityImages)
    eval(['imp' num2str(i) '= ij.IJ.openImage([experimentStructure.savePath pixelSelectivityImages(' num2str(i) ').name]);']);
    eval(['processorSelect' num2str(i) '= imp' num2str(i) '.getProcessor();']);
end

% create empty stack
pixelSelectivityStack = ij.ImageStack(imp1.getWidth, imp1.getHeight);

% fill stack with images
for i =1:length(pixelSelectivityImages)
    eval(['pixelSelectivityStack.addSlice(imp' num2str(i) '.getTitle, processorSelect' num2str(i) ');']);
end

% display stack
stackImagePlusObjSelect = ij.ImagePlus('Pixel Pref Stack.tif', pixelSelectivityStack);
stackImagePlusObjSelect.show; 
ij.process.ImageConverter(stackImagePlusObjSelect).convertToRGB;


MIJ.run("Concatenate...", "  title=[Full Stack] open image1=ROI_image image2=[Pixel Orientation Stack.tif] image3=[Pixel Pref Stack.tif]");
% set window size and make the image easier to view
WaitSecs(0.2);
ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=10 y=50']);
ij.IJ.run('Enhance Contrast', 'saturated=0.35');

% open ROI tool
MIJ.run("Cell Magic Wand Tool");
ij.IJ.runMacro('setTool("line");');

%% Deal with ROI selection

% Check if there are already ROIs selected for this recording

if exist([experimentStructure.savePath 'RawLinePic\LineROIs.zip'], 'file')
    disp([experimentStructure.savePath  ' contains a valid ROI file!']);
    RC.runCommand('Open', [experimentStructure.savePath 'RawLinePic\LineROIs.zip']); % opens ROI file
    
    % Query user if you want to use previously chosen ROIs
    answer = MFquestdlg([0.5,0.5], 'Would you like to load previously chosen line ROIs?', ...
        'Choose your ROIs', ...
        'Yes','No', 'Yes');
    % Handle response
    switch answer
        case 'Yes'
            
        case 'No'
            RC.runCommand('Delete'); % resets ROIs if you select clear all
        case ''
            
    end
end

RC.runCommand('Show All');

% Sets up diolg box to allow for user input to choose cell ROIs
opts.Default = 'Continue';
opts.Interpreter = 'tex';

questText = [{'Choose new ROIs to analyse'} ...
    {'Use the line tool to select lines and press "t" to add to ROI manager'} {''} ...
    {'If you are happy to move on with analysis click  \bfContinue\rm'} ...
    {'Or click  \bfExit Script\rm or X out of this window to exit script'}];

response = questdlg(questText, ...
    'Check and choose ROIs', ...
    'Continue', ...
    'Exit Script', ...
    opts);


% deals with repsonse
switch response
    case 'Continue' % if continue, goes on with analysis
        ROInumber = RC.getCount();
        disp(['You have selected ' num2str(ROInumber) ' new ROIs, moving on...']);
    case 'Exit Script' % if you want to exit and end
        MIJ.closeAllWindows;
        return
    case ''
        MIJ.closeAllWindows;
        return
end

%% Get the raw data

vol = readMultipageTifFiles(experimentStructure.prairiePath);

% check number of channels in imaging stack
channelIndxStart = strfind(experimentStructure.filenamesFrame{1}, '_Ch');
for i =1:length(experimentStructure.filenamesFrame)
    channelIdentity{i} = experimentStructure.filenamesFrame{i}(channelIndxStart:channelIndxStart+3);
end
channelNo = unique(channelIdentity);

% chooses correct channel to analyse in multichannel recording
if length(channelNo)>1
    volSplit =  reshape(vol,size(vol,1),size(vol,2),[], length(channelNo));
    vol = volSplit(:,:,:,channel2Use);
end

% apply imageregistration shifts
if isprop(experimentStructure, 'options_nonrigid') && ~isempty(experimentStructure.options_nonrigid) % if using non rigid correctionn
    registeredVol = apply_shifts(vol,experimentStructure.xyShifts,experimentStructure.options_nonrigid);
elseif  ~isempty(experimentStructure.xyShifts)
    registeredVol = shiftImageStack(vol,experimentStructure.xyShifts([2 1],:)'); % Apply actual shifts to tif stack
else % if there are no motion correction options, ie the image stack loaded is already motion corrected
    registeredVol = vol;
end
% transfers to FIJI
registeredVolMIJI = MIJ.createImage( 'Registered Volume', registeredVol,true);


roiLines = RC.getRoisAsArray(); % get pointers to all line ROIs

for x = 1:ROInumber
    % Select cell ROI in ImageJ/FIJI
    fprintf('Processing User Selected ROI number: %d\n',x)
    
    pointsOnLine = roiLines(x).getContainedPoints();
    
    for i = 1:length(pointsOnLine)
        pointsOnLineCoordinates(i,:) = [ pointsOnLine(i).getX pointsOnLine(i).getY ];
        registeredVolMIJI.setRoi(pointsOnLineCoordinates(i,1), pointsOnLineCoordinates(i,2)-(x-1),1,1);
        
        plotF = ij.plugin.ZAxisProfiler.getPlot(registeredVolMIJI);
        RT(:,1) = plotF.getXValues();
        RT(:,2) = plotF.getYValues();
        zProfilesPerPixel{x}(:,i)= RT(:,2);
    end
end

%% Split data into conditions

analysisFrameLength = experimentStructure.meanFrameLength ;

%% chunks up rawF into cell x cnd x trial
runningMax = 0;
runningMin = 1;
for p = 1:ROInumber % for each new ROI
    for  x =1:length(experimentStructure.cndTotal) % for each condition
        if any(experimentStructure.cndTotal(x)) % checks if there are any trials of that type
            for y =1:length(experimentStructure.cndTrials{x}) % for each trial of that type
                
                currentTrial = experimentStructure.cndTrials{x}(y); % gets current trial number for that cnd
                currentTrialFrameStart = experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial);
                
                % splits rawF into conditions/trials
                rawFperCnd{p}{x}(:,:,y) = zProfilesPerPixel{p}(currentTrialFrameStart:currentTrialFrameStart+ (analysisFrameLength-1),:); %chunks data and sorts into structure
            end
        end
        % make averages per condition
        rawFperCndAverages{p}(:,:,x) = mean(rawFperCnd{p}{x},3);
    end
    
    if max(rawFperCndAverages{p}(:)) > runningMax
        runningMax =  max(rawFperCndAverages{p}(:));
    end
    
    if min(rawFperCndAverages{p}(:)) < runningMin
        runningMin =  min(rawFperCndAverages{p}(:));
    end
end

logMin = log(runningMin);

% normalize to max of all average responses across all lines
for p = 1:ROInumber % for each new ROI
    rawFperCndAveragesNorm{p} = rawFperCndAverages{p}/runningMax;
    rawFperCndAveragesLogNorm{p} = (log(rawFperCndAverages{p})-logMin)/(log(2^13)-logMin);
end
%% plotting


createLinePlots(experimentStructure, rawFperCndAveragesNorm , noOrientations, angleMax,secondCndDimension, scndDimLabels,  0);
createLinePlots(experimentStructure, rawFperCndAveragesLogNorm , noOrientations, angleMax,secondCndDimension, scndDimLabels, 1);


RC.runCommand('Save', [experimentStructure.savePath 'RawLinePic\LineROIs.zip']); % saves zip file
MIJ.closeAllWindows
end
