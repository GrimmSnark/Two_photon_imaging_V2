function [stimSTDSum, preStimSTDSum, stimMeanSum , preStimMeanSum ,experimentStructure] = createStimSTDAverageGPU(experimentStructure, vol, channelIdentifier)
% Function to create STD sum images for prestim and stim times on the GPU,
% much faster if available to use
%
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


volGPU = gpuArray(vol);
disp('Starting stim STD image calculation');

for  cnd =1:length(experimentStructure.cndTrials) % for each condition
    
    disp(['On Condition ' num2str(cnd) ' of ' num2str(length(experimentStructure.cndTrials))]);
    
    for iter =1:length(experimentStructure.cndTrials{cnd}) % for each trial of that type
        
        currentTrial = experimentStructure.cndTrials{cnd}(iter); % gets current trial number for that cnd
        currentStimChunk = experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_OFF(currentTrial);
        stimChunkLength = length(currentStimChunk);
        currentPreStimChunk = experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial):experimentStructure.EventFrameIndx.PRESTIM_OFF(currentTrial);
        preStimChuckLength = length(currentPreStimChunk);
        %% Stim Window
        reshapedVolGPU = double(reshape(volGPU(:,:,currentStimChunk), [], length(currentStimChunk))); % reshapes array into pixel by frame array
        mean_x = sum(reshapedVolGPU,2)/stimChunkLength;
        xc = reshapedVolGPU - mean_x;
        stdArrayGPU  = sqrt(sum(xc .* xc, 2)) / sqrt(stimChunkLength - 1);
        
        stdArrayGPU = reshape(stdArrayGPU(1:end), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine); % reshapes into std image 512 x 512
        stimSTDImageCND(:,:, cnd, iter) = stdArrayGPU; % adds the image to the grand array
        
        meanArrayGPU = reshape(mean_x(1:end), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine); % reshapes into mean image 512 x 512
        stimMeanImageCND(:,:, cnd, iter) = meanArrayGPU; % adds the image to the grand array
        
        %% Prestim Window
        reshapedVolGPU = double(reshape(volGPU(:,:,currentPreStimChunk), [], length(currentPreStimChunk))); % reshapes array into pixel by frame array
        mean_x = sum(reshapedVolGPU,2)/preStimChuckLength;
        xc = reshapedVolGPU - mean_x;
        stdArrayGPU  = sqrt(sum(xc .* xc, 2)) / sqrt(preStimChuckLength - 1);
        
        stdArrayGPU = reshape(stdArrayGPU(1:end), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine); % reshapes into std image 512 x 512
        preStimSTDImageCND(:,:, cnd, iter) = stdArrayGPU; % adds the image to the grand array
        
        meanArrayGPU = reshape(mean_x(1:end), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine); % reshapes into mean image 512 x 512
        preStimMeanImageCND(:,:, cnd, iter) = meanArrayGPU; % adds the image to the grand array
        
    end
end
% reshape arrays to 2D images

%% create STDs
stimSTDImage = reshape(stimSTDImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);
stimSTDSum = rescale(sum(stimSTDImage, 3))*65535; % rescales to 16 bit image without clipping or loss...
stimSTDSum = uint16(gather(stimSTDSum));

preStimSTDImage = reshape(preStimSTDImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);
preStimSTDSum = rescale(sum(preStimSTDImage, 3))*65535;
preStimSTDSum = uint16(gather(preStimSTDSum));

%% create averages
stimMeanImage = reshape(stimMeanImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);
stimMeanSum = rescale(sum(stimMeanImage, 3))*65535; % rescales to 16 bit image without clipping or loss...
stimMeanSum = uint16(gather(stimMeanSum));

preStimMeanImage = reshape(preStimMeanImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);
preStimMeanSum = rescale(sum(preStimMeanImage, 3))*65535;
preStimMeanSum = uint16(gather(preStimMeanSum));


%% add to experimentStructure
% uses eval code to address the experimentStructure variables
% properly, sorry I know this is messy but it will work....
eval(['experimentStructure.stimSTDImageCND' channelIdentifier ' = uint16(gather(stimSTDImageCND));'])
eval(['experimentStructure.preStimSTDImageCND' channelIdentifier ' = uint16(gather(preStimSTDImageCND));' ])

eval(['experimentStructure.stimMeanImageCND' channelIdentifier ' = uint16(gather(stimMeanImageCND));' ])
eval(['experimentStructure.preStimMeanImageCND' channelIdentifier ' = uint16(gather(preStimMeanImageCND));'])

end