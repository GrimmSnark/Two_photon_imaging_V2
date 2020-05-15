function prepData(directory, loadMetadata, registrationType, saveRegMovie, experimentType, channel2register, templateImageForReg, useBrightestFrameAlignment)
% This function does basic preprocessing of t series imaging data including
% meta data, trial data extraction and image registration
% Input- directory: image data directory for the t series
%
%        loadMetadata: flag 1/0 for loading experiment metadata from xml 
%                      file
%
%        registrationType- DFT-based subpixel method ('subMicronMethod')
%                        - non-rigid DFT subpixel registration ('nonRigid')
%                        - Leave blank if you do NOT want to register
%
%        saveRegMovie: flag for save registered movie file, not necessary
%        and takes up time/space 0 = not saved, 1 = saved
%
%        experimentType: String of experiment type, ie 'orientation' etc
%        decides whether to load trial data and in what format
%
%        channel2register: can speicfy channel to register the stack with
%        if there are more than one recorded channel
%
%        templateImageForReg: 2D image array which is used for registering
%        tif stack (used for multiple tif stacks in the same recording
%        session), leave blank ([]), if not in use
%
%        useBrightestFrameAlignment: 1/0 flag to use average of brightest
%        frames in stack for image registration template

%% set up
experimentStructure = experimentStructureClass;

% no of images to use for average
noOfImagesForAlignment = 100;

% checks to see if this image run is an experiment, ie needs trial event
% extraction
if ~isempty(experimentType)
    experimentFlag = 1;
    experimentStructure.experimentType = experimentType;
else
    experimentFlag = 0;
    experimentStructure.experimentType = [];
end

savePath = createSavePath(directory, 1);
experimentStructure.savePath = savePath;

%% load in images
% get imaging meta data and trial data
% start image processing

experimentStructure.prairiePath = [directory '\']; % sets folder path for raw data

% reads in imaging data
[experimentStructure, vol]= prepImagingData(experimentStructure, loadMetadata);

% check number of channels in imaging stack
channelIndxStart = strfind(experimentStructure.filenamesFrame{1}, '_Ch');
for i =1:length(experimentStructure.filenamesFrame)
    channelIdentity{i} = experimentStructure.filenamesFrame{i}(channelIndxStart:channelIndxStart+3);
end
channelNo = unique(channelIdentity);

% splits stack into two channels
if length(channelNo)>1
    volSplit =  reshape(vol,size(vol,1),size(vol,2),[], length(channelNo));
end

if isfield( experimentStructure, 'micronsPerPixel')
    micronsPerPix = experimentStructure.micronsPerPixel(1,1);
else
    micronsPerPix =[];
end

%% load in trial data 
if experimentFlag == 1
    experimentStructure = prepTrialData(experimentStructure);
end

%% check if there is a mismatch between trial data size and imaging data size and restrict event data

% get imaging data size
if length(channelNo)> 1
    imagingSize = size(vol,3)/2;
else
    imagingSize = size(vol,3);
end

% get trial event length in frames
trialInfoSize = experimentStructure.EventFrameIndx.TRIAL_END(end);

% if the event frame size is largerr that the data, restrict block number
% used to that smaller than imaging data
if trialInfoSize> imagingSize
    
    % find block change trials
    changeBlocks = find(experimentStructure.block(2:end,2)- experimentStructure.block(1:end-1,2)) +1;
    
    % find block change smaller than imaging size
    lastImagingTrial = find(imagingSize<experimentStructure.EventFrameIndx.TRIAL_END);
    lastImagingTrial = lastImagingTrial(1)-1;
    
    % find last full imaging block
    lastImagingBlock = find(lastImagingTrial < changeBlocks)-1;
    
    
    % restrict all events to the max of last imaging block
    lastCndNo = changeBlocks(lastImagingBlock)-1;
    
    experimentStructure.cndTotal = ones(size( experimentStructure.cndTotal)) * lastImagingBlock;
    experimentStructure.block(lastCndNo+1:end,:) = [];
    
    for cc = 1:length(experimentStructure.cndTrials)
        experimentStructure.cndTrials{cc} = experimentStructure.cndTrials{cc}(experimentStructure.cndTrials{cc} <= lastCndNo);
    end
    
    for qq = 1:length(experimentStructure.nonEssentialEvent)
        experimentStructure.nonEssentialEvent{2,qq} = experimentStructure.nonEssentialEvent{2,qq}(:,:,1:lastCndNo);
    end
    
    eventFields = fieldnames(experimentStructure.EventFrameIndx);
    for aa = 1:length(eventFields)
        experimentStructure.EventFrameIndx.(eventFields{aa}) = experimentStructure.EventFrameIndx.(eventFields{aa})(1:lastCndNo);
    end
end

%% Image motion correction and registration

if length(channelNo)> 1 % choose one channel to register if multiple exist
    %% two channels
    
    % Register imaging data and save registered image stack
    if ~isempty(registrationType)
        % if we want to use the brightness average
        if useBrightestFrameAlignment
            % get image brightness in stack
            imageBrightness = squeeze(mean(volSplit(:,:,:,channel2register),[1,2]));
            
            % sort image brightness
            [~, imageBrightnessIndx] = sort(imageBrightness);
            % make average image based on noOfImages brightest images
            templateImageForReg = uint16(mean(volSplit(:,:,imageBrightnessIndx(1:noOfImagesForAlignment-1),channel2register),3));
            
        end
        
        disp(['Starting image registration on Channel ' num2str(channel2register)]);
        [vol,xyShifts, options_nonrigid] = imageRegistration(volSplit(:,:,:,channel2register), [], micronsPerPix, [], templateImageForReg);
        experimentStructure.xyShifts = xyShifts;
        experimentStructure.options_nonrigid = options_nonrigid;
    end
    % deal with first channel
    experimentStructure =  createSummaryImages(experimentStructure,vol, saveRegMovie, experimentFlag, channelNo{channel2register});
    
    % deal with second channel
    indForOtherChannel = find(~strcmp(channelNo, channelNo{channel2register}));
    vol = shiftImageStack(volSplit(:,:,:,indForOtherChannel),xyShifts([2 1],:)'); % Apply actual shifts to tif stack
    experimentStructure =  createSummaryImages(experimentStructure,vol, saveRegMovie, experimentFlag,channelNo{indForOtherChannel});
else
    %% If single channel stack
    
    if ~isempty(registrationType)
        % if we want to use the brightness average
        if useBrightestFrameAlignment
            % get image brightness in stack
            imageBrightness = squeeze(mean(vol,[1,2]));
            
            % sort image brightness
            [~, imageBrightnessIndx] = sort(imageBrightness);
            % make average image based on noOfImages brightest images
            templateImageForReg = uint16(mean(vol(:,:,imageBrightnessIndx(1:noOfImagesForAlignment-1)),3));
        end
        
        disp(['Starting image registration on Channel ' num2str(channel2register)]);
        [vol,xyShifts, options_nonrigid] = imageRegistration(vol,registrationType, micronsPerPix, [], templateImageForReg);
        experimentStructure.xyShifts = xyShifts;
        experimentStructure.options_nonrigid = options_nonrigid;
    end
    
    experimentStructure =  createSummaryImages(experimentStructure,vol, saveRegMovie, experimentFlag);  
end
%% save experimentStructure
save([savePath 'experimentStructure.mat'], 'experimentStructure');

end