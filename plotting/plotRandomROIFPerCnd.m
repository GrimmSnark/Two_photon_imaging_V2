function plotRandomROIFPerCnd(filepath, channel2Use, noOrientations, angleMax, secondCndDimension, data2Use, secondCndDimensionLabels )
% Allows a user to choose new ROIs to examine their condition average
% response. Saves the plots and the newly added ROIs into a subfolder
% (addedROIs) within the processed data directory. Does not add newly
% addeed ROIs to experimentStructure. If you are trying to add more cell
% ROIS to the main data structure please use runCaAnalysisWrapper.
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
%          data2Use - specify the type of data to use
%                     rawF- raw fluoresence data
%                     FBS- first before stimulus subtraction (For LCS)
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


%% set defaults

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
    lineCol = 'k';
    scndDimLabels = {'Orientations'};
end


if nargin < 6 || isempty(data2Use)
    data2Use = 'FBS';
end


% sort out second dimension labels....This is still under development
% if there are more than one dimension apart from orientation
if secondCndDimension > 1
    
    % checks if the label field is empty and sets to default
    if nargin < 7 || isempty(secondCndDimensionLabels)
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
    lineCol =distinguishable_colors(length(scndDimLabels), 'w'); % gets number of line colors
end

% get the appropriate magnification for ROI image
screenDim = get(0,'ScreenSize');
if screenDim(3) > 2000
    magSize = 300; % magnification for image viewing in %
else
    magSize = 200; % magnification for image viewing in %
end


%% Create the appropriate images for ROI extraction

% initalize MIJI and get ROI manager open
intializeMIJ;
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();

% finds all the relevant images for ROI chosing
files = dir([experimentStructure.savePath 'STD_Average*']);

if size(files,1) ==1 % if single channel recording
    imageROI = read_Tiffs([experimentStructure.savePath 'STD_Average.tif'],1); % reads in average image
    imageROI = uint16(mat2gray(imageROI)*65535);
%     imageROI = imadjust(imageROI); % saturate image to make neural net prediction better
end

%  if multiple channels load in/ build image
if size(files,1) >1 % if multiple channel recording
    
    % try loading dual image projection, if not there create it
    try
        imageROI = read_Tiffs([experimentStructure.savePath 'Max_Project.tif'],1);
    catch
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
        imageROI = uint16(mat2gray(imageROI)*65535);
        
        % save image
        saveastiff(imageROI, [experimentStructure.savePath 'Max_Project.tif']);
    end
    
    
%     imageROI = imadjust(imageROI); % saturate image to make neural net prediction better
end


% get image to FIJI
MIJImageROI = MIJ.createImage('ROI_image',imageROI,true); %#ok<NASGU> supressed warning as no need to worry about

% set window size and make the image easier to view
WaitSecs(0.2);
ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=10 y=50']);
ij.IJ.run('Enhance Contrast', 'saturated=0.35');

% load in pixel preference images if they exist
pixelSelectivityImages = dir([experimentStructure.savePath 'Pixel Orientation Pref_native*']);

% get all the FIJI stuff for each image
for i =1:length(pixelSelectivityImages)
    eval(['imp' num2str(i) '= ij.IJ.openImage([experimentStructure.savePath  pixelSelectivityImages(' num2str(i) ').name]);']);
    eval(['processor' num2str(i) '= imp' num2str(i) '.getProcessor();']);
end

% create empty stack
pixelPrefStack = ij.ImageStack(imp1.getWidth, imp1.getHeight);

% fill stack with images
for i =1:length(pixelSelectivityImages)
    eval(['pixelPrefStack.addSlice(imp' num2str(i) '.getTitle, processor' num2str(i) ');']);
end

% display stack
stackImagePlusObj = ij.ImagePlus('Pixel Orientation Stack.tif', pixelPrefStack);
stackImagePlusObj.show;
WaitSecs(0.2);
ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=500 y=50']);

% open ROI tool
MIJ.run("Cell Magic Wand Tool");
ij.IJ.runMacro('setTool("rectangle");');

%% Deal with ROI selection

% Check if there are already ROIs selected for this recording

if exist([experimentStructure.savePath 'ROIcells.zip'], 'file')
    disp([experimentStructure.savePath  ' contains a valid ROI file!']);
    RC.runCommand('Open', [experimentStructure.savePath 'ROIcells.zip']); % opens ROI file
    
    % Query user if you want to use previously chosen ROIs
    answer = MFquestdlg([0.5,0.5], 'Would you like to load previously chosen ROIs?', ...
        'Choose your ROIs', ...
        'Yes','No', 'Yes');
    % Handle response
    switch answer
        case 'Yes'
            ROInumber = RC.getCount();
        case 'No'
            ROInumber = 0;
            RC.runCommand('Delete'); % resets ROIs if you select clear all
        case ''

    end
end

RC.runCommand('Show All');

% Sets up diolg box to allow for user input to choose cell ROIs
opts.Default = 'Continue';
opts.Interpreter = 'tex';

questText = [{'Choose new ROIs to analyse'} ...
    {'Select the Cell Magic Want and press "t" to add to ROI manager'} {''} ...
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
        newROINum = RC.getCount();
        AddedROIs = newROINum - ROInumber;
        disp(['You have selected ' num2str(AddedROIs) ' new ROIs, moving on...']);
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

for x = 1:AddedROIs
    % Select cell ROI in ImageJ/FIJI
    fprintf('Processing User Selected ROI number: %d\n',x)
    
    RC.select(ROInumber+x-1); % Select current newly added ROI
    
    % Get the fluorescence timecourse for the ROI using ImageJ's "z-axis profile" function.
    ij.IJ.getInstance().toFront();
    
    plotTrace = ij.plugin.ZAxisProfiler.getPlot(registeredVolMIJI);
    RT(:,1) = plotTrace.getXValues();
    RT(:,2) = plotTrace.getYValues();
    
    ex.rawF(x,:) = RT(:,2);
end


%% Split data into conditions

analysisFrameLength = experimentStructure.meanFrameLength ; % saves the analysis frame length into structure, just FYI

%% chunks up rawF & dF into cell x cnd x trial
for p = 1:AddedROIs % for each new ROI
    for  x =1:length(experimentStructure.cndTotal) % for each condition
        if any(experimentStructure.cndTotal(x)) % checks if there are any trials of that type
            for y =1:length(experimentStructure.cndTrials{x}) % for each trial of that type
                
                currentTrial = experimentStructure.cndTrials{x}(y); % gets current trial number for that cnd
                currentTrialFrameStart = experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial);
                
                %% First frame before stimulus subtraction (FBS) splits, does not require neuropil subraction etc
                % splits rawF into conditions/trials
                ex.rawFperCnd{p}{x}(:,y) = ex.rawF(p,currentTrialFrameStart:currentTrialFrameStart+ (analysisFrameLength-1)); %chunks data and sorts into structure
                
                % calulates per trial DF/F FBS
                rawFCurrentTrial = ex.rawF(p,currentTrialFrameStart:currentTrialFrameStart+ (analysisFrameLength-1)); % gets the raw trial
                rawFCurrentFrameBeforeStim = ex.rawF(p,currentTrialFrameStart+experimentStructure.stimOnFrames(1)-2); % get the FBS values
                ex.dFperCndFBS{p}{x}(:,y) = (rawFCurrentTrial - rawFCurrentFrameBeforeStim)/rawFCurrentFrameBeforeStim; %creates the trial dF/F for FBS
                
                % makes average of prestim window
                ex.rawFpreStimWindow{p}{y,x} = ex.rawFperCnd{p}{x}(1:experimentStructure.stimOnFrames(1)-1,y);
                ex.dFpreStimWindowFBS{p}{y,x} =  ex.dFperCndFBS{p}{x}(1:experimentStructure.stimOnFrames(1)-1,y);
                
                ex.FpreStimWindowAverage{p}{y,x} = mean(ex.rawFpreStimWindow{p}{y,x});
                ex.dFpreStimWindowAverageFBS{p}{y,x} = mean(ex.dFpreStimWindowFBS{p}{y,x});
                
                % stim response and average response per cell x cnd x trial
                ex.rawFstimWindow{p}{y,x} = ex.rawFperCnd{p}{x}(experimentStructure.stimOnFrames(1):experimentStructure.stimOnFrames(2),y);
                ex.dFstimWindowFBS{p}{y,x} =  ex.dFperCndFBS{p}{x}(experimentStructure.stimOnFrames(1):experimentStructure.stimOnFrames(2),y);
                
                ex.FstimWindowAverage{p}{y,x} = mean(ex.rawFstimWindow{p}{y,x});
                ex.dFstimWindowAverageFBS{p}{y,x} = mean(ex.dFstimWindowFBS{p}{y,x});
                
            end
        end
    end
end

%% sets up average traces per cnd and STDs
for i = 1:length(ex.dFperCndFBS) % for each cell
    for x = 1:length(ex.dFperCndFBS{i}) % for each condition
        %% Raw F
        ex.rawFperCndMean{i}(:,x) = mean(ex.rawFperCnd{i}{x}, 2); % means for each cell frame value x cnd
        ex.rawFperCndSTD{i}(:,x) = std(ex.rawFperCnd{i}{x}, [], 2); % std for each cell frame value x cnd
        
        %% First before Stimulus
        ex.dFperCndMeanFBS{i}(:,x) = mean(ex.dFperCndFBS{i}{x}, 2); % means for each cell frame value x cnd
        ex.dFperCndSTDFBS{i}(:,x) = std(ex.dFperCndFBS{i}{x}, [], 2); % std for each cell frame value x cnd
    end
end
%% plotting

for cellNo = 1:AddedROIs
     % create figure
    figHandle = figure('units','normalized','outerposition',[0 0 1 1]);
    
    % get angles for labels
    angles     = linspace(0,angleMax,noOrientations+1);
    angles     = angles(1:end-1);
    
    % check that the condition numbers match up
    cndCheck = noOrientations * secondCndDimension;
    
    if cndCheck ~=length(experimentStructure.cndTotal)
        disp('Wrong no of orientation and secomd dimension conditions (color/spatial freq) entered!!!');
        disp('Please fix and rerun');
        close
        return
    end
    
    
    % get Data
    switch data2Use
        case 'rawF'
            trialTracesMean = ex.rawFperCndMeanFBS{i};
            errorBarTraces = ex.rawFperCndSTDFBS{i};
            ylabelText = 'Raw F';
        
        case 'FBS'
            trialTracesMean = ex.dFperCndMeanFBS{i};
            errorBarTraces = ex.dFperCndSTDFBS{i};
            ylabelText = '\DeltaF/F';
    end
    
    %% plot averages for all conditions
    
    % get max and min data for limiting axes
    maxData = trialTracesMean + errorBarTraces;
    maxData = max(maxData(:));
    minData = trialTracesMean - errorBarTraces;
    minData = min(minData(:));
    
    
    hold on
    prev2ndDim = 0;
    % for each condition
    for x =1:length(experimentStructure.cndTotal)
        
        % get length of traces
        lengthOfData = experimentStructure.meanFrameLength;
        
        % get current second dimension number
        current2ndDim = (x/noOrientations);
        if floor(current2ndDim)~=current2ndDim
            current2ndDim = ceil(current2ndDim);
        end
        
        % get the spacings and labels for the traces
        if current2ndDim< 2
            spacing = 5;
            xlocations(x,:) = ((lengthOfData +lengthOfData* (x-1))- (lengthOfData-1) :lengthOfData + lengthOfData* (x-1)) + spacing*(x-1);
            xlocationMid(x) = xlocations(x,round(lengthOfData/2));
        else
            currentOrientation =  x- ((current2ndDim-1)*noOrientations);
            xlocations(x,:) = xlocations(currentOrientation,:);
        end
        
        % set axis labels if on new 2nd dim axis
        if current2ndDim > prev2ndDim
            
            subFighandle = subplot(secondCndDimension,1,current2ndDim);
            
            ylabel(ylabelText);
            xlabel(sprintf('Stimulus direction (%s)', char(176)));
            ylim([minData maxData]);
            title(['Condition: ' scndDimLabels{current2ndDim}]);
        end
        
        % set labels
        xticks(xlocationMid);
        xticklabels([angles]);
        
        % use appropriate SD error bars
        errorBarsPlot = errorBarTraces (:,x);
        
        % plot trace
        curentLineCol = lineCol(current2ndDim,:);
        shadedErrorBarV2(xlocations(x,:), trialTracesMean(:,x)', errorBarsPlot, 'lineprops' , {'color',[curentLineCol]});
        prev2ndDim = current2ndDim;
    end
    tightfig;
    
    %% save the figures
    if strcmp(data2Use, 'FBS') % if FBS data
            if ~exist([experimentStructure.savePath 'addedROIs\'], 'dir')
                mkdir([experimentStructure.savePath 'addedROIs\']);
            end
            saveas(figHandle, [experimentStructure.savePath 'addedROIs\Orientation Tuning addedROI ' num2str(x) '.tif']);
 
    else % if using rawF data
        
            if ~exist([experimentStructure.savePath 'addedROIs\rawF\'], 'dir')
                mkdir([experimentStructure.savePath 'addedROIs\rawF\']);
            end
            saveas(figHandle, [experimentStructure.savePath 'addedROIs\rawF\Orientation Tuning addedROI ' num2str(x) '.tif']);
    end
    close;
end

%% save added ROIs

% select and delete cell ROIs
RC.setSelectedIndexes(0:ROInumber-1);
RC.runCommand('Delete');

% save only added ROIs
RC.runCommand('Save', [experimentStructure.savePath 'addedROIs\addedROIs.zip']); % saves zip file

MIJ.closeAllWindows

end
