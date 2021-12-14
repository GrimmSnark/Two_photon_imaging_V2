function [diffSTDImageSum, diffMeanImageSum,experimentStructure] = createStimVSPrestimSTDDiffGPU(vol, experimentStructure, channelIdentifier)
% Function to create STD and mean sum images for prestim and stim times
% Input: vol- registered 3D image stack
%        experimentStructure- structure for this experiement
%        channelIdentifier- OPTIONAL, string for identifying channel if
%        multiple exist
%
% Output: diffSTDImageSum- 2D array of difference STDs for stim trial
%                          window period vs prestim blank
%         diffMeanImageSum- 2D array of difference Means for for stim trial
%                          window period vs prestim blank
%         experimentStructure - modified experimentStructure

%%
if nargin<3
    channelIdentifier =[];
end

%%
volGPU = gpuArray(vol);
disp('Starting stim STD image calculation');

for  cnd =1:length(experimentStructure.cndTrials) % for each condition
    
    disp(['On Condition ' num2str(cnd) ' of ' num2str(length(experimentStructure.cndTrials))]);
    
    for iter =1:length(experimentStructure.cndTrials{cnd}) % for each trial of that type
        
        currentTrial = experimentStructure.cndTrials{cnd}(iter); % gets current trial number for that cnd
        currentStimChunk = experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_OFF(currentTrial);
        stimChunkLength = length(currentStimChunk);
        currentPreStimWindow = experimentStructure.EventFrameIndx.STIM_ON(currentTrial)-(stimChunkLength+1):experimentStructure.EventFrameIndx.STIM_ON(currentTrial)-2;
        preStimChuckLength = length(currentPreStimWindow);
        %% Stim Window
        if ~any(currentPreStimWindow < 0)
            reshapedVolGPU = double(reshape(volGPU(:,:,currentStimChunk), [], length(currentStimChunk))); % reshapes array into pixel by frame array
            mean_x = sum(reshapedVolGPU,2)/stimChunkLength;
            xc = reshapedVolGPU - mean_x;
            stdArrayGPU  = sqrt(sum(xc .* xc, 2)) / sqrt(stimChunkLength - 1);
            
            stdArrayGPU = reshape(stdArrayGPU(1:end), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine); % reshapes into std image 512 x 512
            stimSTDImageCND(:,:, cnd, iter) = stdArrayGPU; % adds the image to the grand array
            
            meanArrayGPU = reshape(mean_x(1:end), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine); % reshapes into mean image 512 x 512
            stimMeanImageCND(:,:, cnd, iter) = meanArrayGPU; % adds the image to the grand array
            
            %% Prestim Window
            reshapedVolGPU = double(reshape(volGPU(:,:,currentPreStimWindow), [], preStimChuckLength)); % reshapes array into pixel by frame array
            mean_x = sum(reshapedVolGPU,2)/preStimChuckLength;
            xc = reshapedVolGPU - mean_x;
            stdArrayGPU  = sqrt(sum(xc .* xc, 2)) / sqrt(preStimChuckLength - 1);
            
            stdArrayGPU = reshape(stdArrayGPU(1:end), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine); % reshapes into std image 512 x 512
            preStimSTDImageCND(:,:, cnd, iter) = stdArrayGPU; % adds the image to the grand array
            
            meanArrayGPU = reshape(mean_x(1:end), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine); % reshapes into mean image 512 x 512
            preStimMeanImageCND(:,:, cnd, iter) = meanArrayGPU; % adds the image to the grand array
        end
    end
end
% reshape arrays to 2D images

%% create STDs
stimSTDImage = reshape(stimSTDImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);
preStimSTDImage = reshape(preStimSTDImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);

diffSTDImage = stimSTDImage-preStimSTDImage;
diffSTDImageSum = rescale(sum(diffSTDImage, 3))*65535;
diffSTDImageSum = uint16(gather(diffSTDImageSum));

%% create averages
stimMeanImage = reshape(stimMeanImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);
preStimMeanImage = reshape(preStimMeanImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);

diffMeanImage = stimMeanImage - preStimMeanImage;
diffMeanImageSum = rescale(sum(diffMeanImage, 3))*65535;
diffMeanImageSum = uint16(gather(diffMeanImageSum));


%% add to experimentStructure

if ~isempty(channelIdentifier) % if multiple channels in recording
    
    % uses eval code to address the experimentStructure variables
    % properly, sorry I know this is messy but it will work....
    
    try % try if experimentStructure is struct
    eval(['experimentStructure.diffSTDImageCND' channelIdentifier ' = gather(stimSTDImageCND);'])
    eval(['experimentStructure.diffMeanImageCND' channelIdentifier ' = gather(stimMeanImageCND);' ])
    catch % deals with if it is a class object
        experimentStructure.addprop(['diffSTDImageCND' channelIdentifier]);
        experimentStructure.addprop(['diffMeanImageCND' channelIdentifier]);
        
        eval(['experimentStructure.diffSTDImageCND' channelIdentifier ' = gather(stimSTDImageCND);'])
        eval(['experimentStructure.diffMeanImageCND' channelIdentifier ' = gather(stimMeanImageCND);' ])
    end
    
else
    try % try if experimentStructure is struct
        experimentStructure.diffSTDImageCND = gather(stimSTDImageCND);
        experimentStructure.diffMeanImageCND = gather(stimMeanImageCND);
    catch  % deals with if it is a class object
        experimentStructure.addprop('diffSTDImageCND');
        experimentStructure.addprop('diffMeanImageCND');
        
        experimentStructure.diffSTDImageCND = gather(stimSTDImageCND);
        experimentStructure.diffMeanImageCND = gather(stimMeanImageCND);
        
    end
end

end