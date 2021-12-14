function countOverlapROIsFromFIJI(experimentDayFilepath)
% Counts number of cells which are indicated as being dual channel by their
% ROI color
%
% NOT USED ANYMORE
%%
% initalize MIJI and get ROI manager open
intializeMIJ;


% get the folders to process
folders2Process = dir([experimentDayFilepath '\**\experimentStructure.mat']);

for i = 1:length(folders2Process)
    
    RM = ij.plugin.frame.RoiManager();
    RC = RM.getInstance();
    
    folder2Process = [folders2Process(i).folder '\'];
    
    load([folder2Process '\experimentStructure.mat']);
    
    if exist([folder2Process 'ROIcells.zip'], 'file')
        disp([folder2Process  ' contains a valid ROI file!']);
        RC.runCommand('Open', [folder2Process 'ROIcells.zip']); % opens ROI file
    end
    
    channelOverlapFlag = zeros(experimentStructure.cellCount,1);
    
    for x = 1:experimentStructure.cellCount
        % Select cell ROI in ImageJ/FIJI
        fprintf('Processing Cell %d\n',x)
        
        % Get cell ROI name and parse out (X,Y) coordinates
        RC.select(x-1); % Select current cell
        currentROI = RC.getRoi(x-1);
        
        % get the channel overlap identity
        try
            ROIColor = [currentROI.getStrokeColor.getRed, currentROI.getStrokeColor.getGreen, currentROI.getStrokeColor.getBlue];
        catch
            ROIColor = [0 255 255];
        end
        
        if ROIColor == [255 0 0]
            channelOverlapFlag(x,1) = 1;
        else
            channelOverlapFlag(x,1) = 0;
        end
    end
   
    experimentStructure.ChannelOverlap = channelOverlapFlag;
    save([experimentStructure.savePath '\experimentStructure.mat'], 'experimentStructure', '-v7.3');
    
    MIJ.closeAllWindows; 
    
end
end