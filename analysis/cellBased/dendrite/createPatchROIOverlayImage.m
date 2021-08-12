function [overlayImage] = createPatchROIOverlayImage(imagePath, ROIType)

%% load in ROIs/images

parentDir = returnParentFolder(imagePath);
switch ROIType
    
    case 1 % cell ROIs
        roiPath = dir([parentDir '\ROIcells.zip']);
        fontSize = 6;
        offsetVal = 3;
    case 2 % dendrite ROIs
        roiPath = dir([parentDir '\**\dendriteROIs.zip']);
        fontSize = 20;
        offsetVal = 10;
end

roiPath = [roiPath.folder '\' roiPath.name];


% load in pointers to ROI manager
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();


% load in ROI file
if exist(roiPath)
    RC.runCommand('Open', roiPath); % opens zip file
else
    disp(['No ROI file found in "' folders2Process.folder '" Please run chooseROIs.m']);
    return
end
ROInumber = RC.getCount();

% read image in
image2Overlay = read_Tiffs(imagePath);

%% create Patch overlay

ROIobjects = RC.getRoisAsArray;
cellROIs = ROIobjects(1:ROInumber);

[labeledCellROI, centerXY] = createLabeledROIFromImageJPixels([size(image2Overlay)], cellROIs);

numROIs = max(labeledCellROI(:));
boundaries = cell(numROIs,1);
%iterate through ROI number to get them in appropriate order
for i = 1: numROIs
    tempImageROI = labeledCellROI;
    tempImageROI(tempImageROI~=i) = 0;
    tempBounds = bwboundaries(tempImageROI, 4, 'noholes');
    boundaries(i,1) =tempBounds(1);
end
% sets color map for the cell ROIs

cmap = distinguishable_colors(numROIs+1,{'w','k'});
cmap(1,:) = [0,0,0];
app.cmap = cmap;


image2Display = mat2gray(imadjust(image2Overlay));
imageHandle = imshow(image2Display, 'Border','tight', 'InitialMagnification',300);
figHandle = gcf;

% build patch structure

for i =1:numROIs
    patch(gca,boundaries{i,1}(:,2), boundaries{i,1}(:,1), app.cmap(i+1, :), 'FaceAlpha', 0.7);
    
    %                 patch(app.ImageAxes,boundaries{i,1}(:,2), boundaries{i,1}(:,1), app.cmap(i+1, :), 'FaceAlpha', 0.3, ...
    %                     'ButtonDownFcn', @(src,evnt)plotMouseClickvApp(app,src,evnt));
end

% add number labels
for i =1:numROIs
numberTextHandle = handle(text(...
        'String', sprintf('%i',i),...
        'FontSize', fontSize , ...
        'FontWeight','bold',...
        'BackgroundColor',[.1 .1 .1 .3],...
        'Margin',1,...
        'Position', round([centerXY(i,1), centerXY(i,2)]) - [0 offsetVal],...
        'Parent', gca,...
        'Color',cmap(i+1, :)));
end

overlayImage = getframe(gca);
overlayImage = overlayImage.cdata;
close;

RM.close;

end