function createSVGROIFile(experimentStructure, backgroundImg)
% Creates a svg file from imagej ROIs ( must already be open through MIJI),
% good for making figures
% Inputs: experimentStructure
%         backgroundImg - image to plot on, ie Pixel Orientation image etc
%         (optional)

% Gets image size
imgSize = [experimentStructure.pixelsPerLine experimentStructure.pixelsPerLine];

% sets background image to use, either specificed or blank
if nargin <2
  finalImage = zeros(imgSize);
else
   finalImage =  backgroundImg;
end

% get ROI instance (ROI zip should already be open)
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();

% gets ROI as arrays
 roiObjects = RC.getRoisAsArray;
 
% creates figure to plot on
figHandle = figure;
    imshow(finalImage);
  
    % gets ROI numbers
nROIs = length(roiObjects);
contour = cell(nROIs, 1);
for i=1:nROIs
    labeledROI = zeros(imgSize);
    % Get center location for ROI object
    X = roiObjects(i).getXBase-1; % add one because MATLAB arrays start at 1, while Java arrays start at 0.
    Y = roiObjects(i).getYBase-1;
    
    % Get local mask for ROI object
    localCellMask = roiObjects(i).getMask();
    height = localCellMask.getHeight();
    width  = localCellMask.getWidth();
    boundedPixels = double(localCellMask.getPixels());
    localCellImg = reshape(boundedPixels,[width,height]);
    localCellImg(localCellImg==-1) = i;
    
    % HACK HACK
    if X<0
        X = 0;
    end
    
    if Y < 0
        Y = 0;
    end
    
    % Only adds elements that are non zero, stops bounding box overlap
    localCellImg = localCellImg';
    for x=1:numel(localCellImg)
        if localCellImg(x) ~=0
            [currentW, currentH] = ind2sub([ height width],x);
            labeledROI(Y+currentW,X+currentH) = localCellImg(x);
        end
    end
    
    % gets outline of ROI
    contour(i) = bwboundaries(labeledROI);
    
    % plots outline of ROIs
    tempOutline = contour{i};
    hold on
    plot(tempOutline(:,2), tempOutline(:,1), 'b', 'LineWidth', 1)

end

saveas(figHandle, [experimentStructure.savePath 'ROIsSVG.svg']);
close;
end