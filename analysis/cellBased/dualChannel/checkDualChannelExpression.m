function checkDualChannelExpression(data, channel2Check)
% checks whether cell ROIs are visible in both channels of recording, ie
% whether recorded cells show structral marker (PV etc)
%
% Inputs:  data - Can be the experimentStructure.mat, the processed data 
%                 folder containing the experimentStructure.mat, or the 
%                 fullfile to the experimentStructure.mat
%
%         channel2Check: Specify channel number to check for dual 
%                        expression, ie 1 (red channel)/ 2(green channel)
               

%% Defaults

% get data in
if ~isstruct(data) % variable is filepath
    try
        load(data, '-mat');
    catch
        load([data '\experimentStructure.mat']);
    end
else % if variable is the experimentStructure
    experimentStructure = data;
    clearvars data
end

% load in pointers to ROI manager
try
     MIJ.closeAllWindows;
    RM = ij.plugin.frame.RoiManager();
    RC = RM.getInstance();
catch
    intializeMIJ;
    RM = ij.plugin.frame.RoiManager();
    RC = RM.getInstance();
end

%% get ROIS
% load in ROI file
if exist([experimentStructure.savePath '\ROIcells.zip'])
    RC.runCommand('Open', [experimentStructure.savePath '\ROIcells.zip']); % opens zip file
else
    disp(['No ROI file found in "' experimentStructure.savePath '" Please run chooseROIs.m']);
    return
end
ROInumber = RC.getCount();
disp(['You have selected ' num2str(ROInumber) ' ROIs, moving onto analysis']);


%% get the image to check
% get image to check for coexpression
image = read_Tiffs([experimentStructure.savePath 'Average_Ch' num2str(channel2Check) '.tif']);


% transfers to FIJI
channel2CheckFIJI = MIJ.createImage( 'Channel to Check', image,true);

% create neuropil ROIs
generateNeuropilROIs(RC.getRoisAsArray,(experimentStructure.averageROIRadius*3)); % generates neuropil surround ROIs

%% get pixel values for cells and neuropil
for x = 1:experimentStructure.cellCount
    % Select cell ROI in ImageJ
    fprintf('Processing Cell %d\n',x)
    
    % Get cell ROI name and parse out (X,Y) coordinates
    currentROI = RC.getRoi(x-1);
    pointsROI = currentROI.getContainedPoints;
    
    % gets the cell and matching neuropil ROI
    for isNeuropilROI = 0:1
        
        pointsROI = currentROI.getContainedPoints;
        pixelValues = [];
        for cc = 1:length(pointsROI)
            pixelValues(cc,:) = channel2CheckFIJI.getPixel(pointsROI(cc).x, pointsROI(cc).y) ;
        end
        
        pixelValues = pixelValues(:,1);
        
        if isNeuropilROI
            neuropilPixels{x} = pixelValues;
            neuropilPixelsMean(x) = mean(pixelValues);
            neuropilPixelsStd(x) = std(pixelValues);
        else
            cellPixels{x} = pixelValues;
            cellPixelsMean(x) = mean(pixelValues);
            currentROI = RC.getRoi(x-1 +experimentStructure.cellCount ); % Now select the associated neuropil ROI
        end
    end
end


%% for each cell/neuropil pair check if signficantly different
cellIdent = zeros(size(cellPixelsMean));
for d = 1:experimentStructure.cellCount
    if cellPixelsMean(d) > 2*neuropilPixelsMean(d) - neuropilPixelsStd(d)
        cellIdent(d) = 1;
    end
    %     prob(d) = ranksum(cellPixels{d},neuropilPixels{d});
end

cellIdent = cellIdent';

experimentStructure.ChannelOverlap = cellIdent;

MIJ.closeAllWindows;

%% Save the updated experimentStructure
save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');

end