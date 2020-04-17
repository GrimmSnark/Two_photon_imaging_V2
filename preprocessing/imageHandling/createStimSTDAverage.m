function [stimSTDSum, preStimSTDSum, stimMeanSum , preStimMeanSum ,experimentStructure] = createStimSTDAverage(experimentStructure, vol,channelIdentifier)
% Function to create STD sum images for prestim and stim times
% Input- experimentStructure: structure for this experiement
%
%        vol: registered 3D image stack
%        
%        channelIdentifier: OPTIONAL, string for identifying channel if
%        multiple exist
%
% Output- stimSTDSum: 2D image of summed STDs for stim trial window period
%
%         preStimSTDSum: 2D image of summed STDs for prestim trial window 
%                        period
%
%         stimMeanSum: 2D image of summed Means for stim trial window 
%                      period
%
%         preStimMeanSum: 2D image of summed Means for prestim trial window
%                         period
%
%         experimentStructure: modified experimentStructure

if nargin<3
    channelIdentifier =[];
end

disp('Starting stim STD image calculation');
cndLength = length(experimentStructure.cndTrials);
for  cnd =1:cndLength % for each condition
    
     disp(['On Condition ' num2str(cnd) ' of ' num2str(length(experimentStructure.cndTrials))]);
    trialNo = length(experimentStructure.cndTrials{cnd}); % for each trial of that type
    parfor iter =1:trialNo
        
        currentTrial = experimentStructure.cndTrials{cnd}(iter); % gets current trial number for that cnd
        currentStimChunk = experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_OFF(currentTrial);
        stimChunkLength = length(currentStimChunk);
        currentPreStimChunk = experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial):experimentStructure.EventFrameIndx.PRESTIM_OFF(currentTrial);
        
    %% Stim Window
        reshapedVol = reshape(vol(:,:,currentStimChunk), [], stimChunkLength);
        sizeReshapedVol = size(reshapedVol, 1);
        stdArray = arrayfun(@(I) std2(reshapedVol(I,:)), [ 1, 1:sizeReshapedVol]);
        stdArray = stdArray(1:end-1);
        stdArray = reshape(stdArray, experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine);
        stimSTDImageCND(:,:, cnd, iter) = stdArray;
        
        meanArray = mean(vol(:,:,currentStimChunk),3);
        stimMeanImageCND(:,:, cnd, iter) = meanArray; % adds the image to the grand array
        
         %% Prestim Window
        reshapedVol = reshape(vol(:,:,currentPreStimChunk), [], length(currentPreStimChunk));
        stdArray = arrayfun(@(I) std2(reshapedVol(I,:)), [ 1, 1:size(reshapedVol, 1)]);
        stdArray = reshape(stdArray(1:end-1), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine);
        preStimSTDImageCND(:,:, cnd, iter) = stdArray;
        
        meanArray = mean(vol(:,:,currentPreStimChunk),3);
        preStimMeanImageCND(:,:, cnd, iter) = meanArray
    end
    
end
%% create STDs
% reshape arrays to 2D images
stimSTDImage = reshape(stimSTDImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);
stimSTDSum = rescale(sum(stimSTDImage, 3))*65535; % rescales to 16 bit image without clipping or loss...
stimSTDSum = uint16(stimSTDSum);

preStimSTDImage = reshape(preStimSTDImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);
preStimSTDSum = rescale(sum(preStimSTDImage, 3))*65535;
preStimSTDSum = uint16(preStimSTDSum);

%% create averages
stimMeanImage = reshape(stimMeanImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);
stimMeanSum = rescale(sum(stimMeanImage, 3))*65535; % rescales to 16 bit image without clipping or loss...
stimMeanSum = uint16(stimMeanSum);

preStimMeanImage = reshape(preStimMeanImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);
preStimMeanSum = rescale(sum(preStimMeanImage, 3))*65535;
preStimMeanSum = uint16(preStimMeanSum);

% add to experimentStructure

eval(['experimentStructure.stimSTDImageCND' channelIdentifier ' = uint16(gather(stimSTDImageCND));'])
eval(['experimentStructure.preStimSTDImageCND' channelIdentifier ' = uint16(gather(preStimSTDImageCND));' ])

eval(['experimentStructure.stimMeanImageCND' channelIdentifier ' = uint16(gather(stimMeanImageCND));' ])
eval(['experimentStructure.preStimMeanImageCND' channelIdentifier ' = uint16(gather(preStimMeanImageCND));'])

end
