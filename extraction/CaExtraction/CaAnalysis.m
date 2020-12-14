function CaAnalysis(recordingDir, channel2Use)
% function which runs main analysis on calcium imaging data recorded on
% prairie bruker system. This function requires user input to define cell
% ROIs and calculates dF/F with neuropil subtraction. Also splits dF traces
% into cell x cnd x trials and calculates mean and std per cell per cnd
%
% Inputs-  recordingDir: filepath for folder to process, can be processed
%                        or raw filepath
%
%          channel2Use: can specify channel to analyse if there are more
%                       than one recorded channel
%                      (OPTIONAL) default = 2 (green channel)
%
% Output- experimentStructure: structure containing all experiment info


%% set defaults

if nargin <2 || isempty(channel2Use)
    channel2Use = 2; % sets default channel to use if in multi channel recording
end

%% create appropriate filepaths
% check folder is the the processed version
folders2Process = dir([recordingDir '\experimentStructure.mat']);

% tries to fix if we happened to use the raw data path
if isempty(folders2Process)
    filePath = createSavePath(recordingDir,1,1);
    folders2Process = dir([filePath '\experimentStructure.mat']);
    folders2Process = folders2Process(end);
end


%% start analysis

% load in pointers to ROI manager
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();


% load in ROI file
if exist([folders2Process.folder '\ROIcells.zip'])
    RC.runCommand('Open', [folders2Process.folder '\ROIcells.zip']); % opens zip file
else
    disp(['No ROI file found in "' folders2Process.folder '" Please run chooseROIs.m']);
    return
end
ROInumber = RC.getCount();
disp(['You have selected ' num2str(ROInumber) ' ROIs, moving onto analysis']);

% calculate average cell ROI radius
averageROIRadius = calculateNeuropilRoiRadius(RC.getRoisAsArray);

% get cell ROI radius, match neuropil ROI radius
generateNeuropilROIs(RC.getRoisAsArray,(averageROIRadius*4)); % generates neuropil surround ROIs

%% load in experimentStructure and begin trace extraction

% load experimentStructure
load([folders2Process.folder '\experimentStructure.mat']);


% feeds in data into experiement structure
experimentStructure.cellCount = ROInumber;
ROIobjects = RC.getRoisAsArray;
cellROIs = ROIobjects(1:ROInumber);
neuropilROIs = ROIobjects(ROInumber+1:end);
experimentStructure.labeledCellROI = createLabeledROIFromImageJPixels([experimentStructure.pixelsPerLine experimentStructure.pixelsPerLine], cellROIs);
experimentStructure.labeledNeuropilROI = createLabeledROIFromImageJPixels([experimentStructure.pixelsPerLine experimentStructure.pixelsPerLine], neuropilROIs);
experimentStructure.averageROIRadius = averageROIRadius;

% does calcium trace extraction
experimentStructure = CaExtraction(experimentStructure, channel2Use);

%% Split up traces into condition structure and save structure
experimentStructure = splitDFIntoConditions(experimentStructure);

% Clean up windows
MIJ.closeAllWindows;

%% if dual channel recording, checks for cell expression in both channels

% % check number of channels in imaging stack
% channelIndxStart = strfind(experimentStructure.filenamesFrame{1}, '_Ch');
% for i =1:length(experimentStructure.filenamesFrame)
%     channelIdentity{i} = experimentStructure.filenamesFrame{i}(channelIndxStart+3);
% end
% 
% channelNo = unique(channelIdentity);
% channelNo = cellfun(@str2double,channelNo);
% 
% if length(channelNo) > 1
%     channel2Check= channelNo(channelNo ~= channel2Use);
%     checkDualChannelExpression(experimentStructure, channel2Check);
% end

end