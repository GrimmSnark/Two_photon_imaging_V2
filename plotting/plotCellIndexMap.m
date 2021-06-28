function plotCellIndexMap(experimentStructure, mapType, limitVal)
% Plots and saves RGB image of index preference for a variety of indices
% Input:    experimentStructure
%           mapType- string variable of the index to use, ie 'OSI',
%           'ratioLM', 'ratioLMS'

if nargin<3
    limitVal =[];
end

% gets cell ROI map
cellROIs = experimentStructure.labeledCellROI;

% sets up blank images
cellMap = zeros(experimentStructure.pixelsPerLine);
nonResponsiveMap = cellMap;

% checks if field exists
if isfield(experimentStructure, mapType)
    map = eval(['experimentStructure.' mapType]);
    
    if ~isempty(limitVal)
        map(map>limitVal) = limitVal;
    end
    
    % runs through all cells
    for i = 1:experimentStructure.cellCount
        % sorts between responsive and non-responsive cells
        if ~isnan(map(i))
            cellMap(cellROIs ==i) = map(i);
        else
            nonResponsiveMap(cellROIs ==i) = 255;
        end
    end
else
    disp('Attempting to plot non-existant field!!')
    return
end

%% create map

% rescales image to 0-1 and applys colormap
cellMapRescale = cellMap/max(cellMap(:));
cellMapRescale = round(cellMapRescale*256);
cellMapRGB = ind2rgb(cellMapRescale,lcs);

% creates nonresponsive RGB image map
nonResponsCont = im2bw(nonResponsiveMap);
nonResponsCont = ~nonResponsCont;
nonResponsCont = cat(3, nonResponsCont, nonResponsCont, nonResponsCont);

% adds non responsive to RGB index map and sets the color to grey
cellMapRGB(nonResponsCont == 0) = 0.5;

% plots index map and applies LCS colors
figMap = imshow(cellMapRGB);
colormap(lcs);
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
colorBar = colorbar ;
axis on
set(gca,'xtick',[]);
set(gca,'ytick',[])
% colorBar.Limits = [0 round(max(map),1)];
% colorBar.Ticks =  [0. 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6];
colorBar.TickLabels = [linspace(0,round(max(map),1), 11)];

%% saves images for display and at native size
if isempty(limitVal)
    saveas(figMap, [experimentStructure.savePath mapType '.tif']);
    imwrite(cellMapRGB, [experimentStructure.savePath mapType '_native.tif']);
else
    saveas(figMap, [experimentStructure.savePath mapType '_limited.tif']);
    imwrite(cellMapRGB, [experimentStructure.savePath mapType '_native_limited.tif']);
end
close();
end