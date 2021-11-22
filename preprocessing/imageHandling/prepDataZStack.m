function prepDataZStack(directory)
% This function does basic preprocessing of z series imaging data 
% Input- directory: image data directory for the z series


%% set up
loadMetadata = 1;
experimentStructure = experimentStructureClass;

experimentStructure.experimentType = 'Zstack';

savePath = createSavePath(directory, 1);
experimentStructure.savePath = savePath;

intializeMIJ;

%% load in images
% get imaging meta data and trial data
% start image processing

% do some filepath checks
if ~contains(directory, 'ZSeries')
    directory = dir([directory '\ZSeries*']);
    directory = [directory.folder '\' directory.name];
end

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

if isprop( experimentStructure, 'micronsPerPixel')
    micronsPerPix = experimentStructure.micronsPerPixel(1,1);
else
    micronsPerPix =[];
end

%% save zstack per channel
% splits stack into two channels
if length(channelNo)>1
    % for each color channel
    for q = 1:length(channelNo)
        % moves data to FIJI
        impFIJI = MIJ.createImage('ZStack', volSplit(:,:,:,q), 1);
        
        % names each slice for Z position
        for z = 1:length(experimentStructure.positionsPerFrame)
            impFIJI.getStack().setSliceLabel(['Z: ' num2str(experimentStructure.positionsPerFrame(z,3)) 'um'] , z);
        end
        
        impFIJI.draw;
        
        % saves stack
        ij.io.FileSaver(impFIJI).saveAsTiffStack([savePath 'ZStack' channelNo{q} '.tif']);
        impFIJI.close;
    end
else % for single channel recordings
    % moves data to FIJI
    impFIJI = MIJ.createImage('ZStack', vol, 1);
    
    % names each slice for Z position
    for z = 1:length(experimentStructure.positionsPerFrame)
        impFIJI.getStack().setSliceLabel(['Z: ' num2str(experimentStructure.positionsPerFrame(z,3)) 'um'] , z);
    end
    
    % saves stack
    ij.io.FileSaver(impFIJI).saveAsTiffStack([savePath 'ZStack' channelNo{:} '.tif']);
    impFIJI.close;
end

%% save experimentStructure
save([savePath 'experimentStructure.mat'], 'experimentStructure');

end