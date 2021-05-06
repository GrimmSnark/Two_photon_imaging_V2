function plotStitchImage2P(directory, startDirNo, saveFlag)

%% set defaults
if nargin < 2 || isempty(startDirNo)
    startDirNo = 1;
end

if nargin < 3 || isempty(saveFlag)
    saveFlag = 1;
end

%% get data
subFolders = returnSubFolderList(directory);

for i = startDirNo:length(subFolders)
    %% set up
    experimentStructure = experimentStructureClass;
    experimentStructure.prairiePath = [subFolders(i).folder '\' subFolders(i).name '\' ];
    
    if saveFlag == 1
        experimentStructure.savePath = createSavePath(experimentStructure.prairiePath, 1,1);
        
        saveFolders = returnSubFolderList(experimentStructure.savePath);
        
        if ~isempty(saveFolders)
            experimentStructure.savePath = [saveFolders(1).folder '\' saveFolders(1).name '\']; 
        else
            experimentStructure.savePath = createSavePath(experimentStructure.prairiePath, 1);
        end
    end
    
    experimentStructure = prepImagingMetaData(experimentStructure);
    
    % get recording loc
    recordingLocations(i,:) = experimentStructure.currentPostion;
    
    % read in imaging data
    im2Show= readMultipageTifFiles(experimentStructure.prairiePath);
    
    % see how many channels are present
    % check number of channels in imaging stack
    channelIndxStart = strfind(experimentStructure.filenamesFrame{1}, '_Ch');
    for q =1:length(experimentStructure.filenamesFrame)
        channelIdentity{i,q} = experimentStructure.filenamesFrame{q}(channelIndxStart:channelIndxStart+3);
    end
    channelNo(i,:) = unique(channelIdentity);
    
    
    im2Show = uint16(mat2gray(im2Show) * 65535);
    options.overwrite = true;
    
    if saveFlag == 1
        for zz = 1:size(im2Show,3)
            saveastiff(im2Show(:,:,zz), [experimentStructure.savePath '\' experimentStructure.filenamesFrame{zz}], options);
        end
    end
    
    imagingVol(:,:,:,i) = im2Show;
end

% % plot data
% imageSize = experimentStructure.linesPerFrame/2;
% figH = figure;
% hold on
% for ee = 1:size(imagingVol,3)
%     for w = 1:size(recordingLocations,1)
%         
%         xData = [recordingLocations(w,1)- imageSize recordingLocations(w,1)+ imageSize ];
%         yData = [recordingLocations(w,2)- imageSize recordingLocations(w,2)+ imageSize ];
%         
%         
%         imshow(imagingVol(:,:,ee,w), 'XData',xData,'YData',yData);
%         hold on
%     end
% end
end