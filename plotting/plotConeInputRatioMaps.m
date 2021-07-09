function plotConeInputRatioMaps(filepath, thresholdZ)
% Plots and saves RGB image of index preference for L vs M and S vs LM
% ratios
% Input:    experimentStructure
%           mapType- string variable of the index to use, ie 'OSI',
%           'ratioLM', 'ratioLMS'

% gets the experimentStructure
if ~isobject(filepath)
    try
        load(filepath, '-mat');
        filePath2Use = dir(filepath);
        experimentStructure.savePath = [filePath2Use.folder '\'] ;
    catch
        if exist([filepath '\experimentStructure.mat'], 'file' )
            load([filepath '\experimentStructure.mat']);
            experimentStructure.savePath = [filepath '\'];
        else
            folder2Try = dir([filepath '\**\experimentStructure.mat']);
            load([folder2Try.folder '\experimentStructure.mat']);
        end
    end
else % if variable is the experimentStructure
    experimentStructure = filepath;
    clearvars filepath
end


if nargin<2
    thresholdZ =[];
end

%% get data 

% gets cell ROI map
cellROIs = experimentStructure.labeledCellROI;

% sets up blank images
cellMap = ones(experimentStructure.pixelsPerLine) *-1;

zScore = experimentStructure.ZScore;

% LM map
% map zscores to blank image, if under threshold set to NaN

LMVaues = experimentStructure.ConeInputRatioLM;
for cellNo = 1:length(zScore)
    
    if zScore(cellNo) > thresholdZ
        cellMap(cellROIs ==cellNo) = LMVaues(cellNo);
% cellMap(cellROIs ==cellNo) = 0;
    else
        cellMap(cellROIs ==cellNo) = NaN;
    end
end
cellMapLM = cellMap;

% S/LM map
% map zscores to blank image, if under threshold set to NaN

% sets up blank images
cellMap = ones(experimentStructure.pixelsPerLine) *-1;

S_LMVaues = experimentStructure.ConeInputRatioS_LM;
for cellNo = 1:length(zScore)
    
    if zScore(cellNo) > thresholdZ
        cellMap(cellROIs ==cellNo) = S_LMVaues(cellNo);
    else
        cellMap(cellROIs ==cellNo) = NaN;
    end
end
cellMapS_LM = cellMap;

% get cell boundary lines

boundaries = cell(experimentStructure.cellCount,1);

%iterate through ROI number to get them in appropriate order
for i = 1: length(boundaries)
    tempImageROI = cellROIs;
    tempImageROI(tempImageROI~=i) = 0;
    tempBounds = bwboundaries(tempImageROI, 4, 'noholes');
    boundaries(i,1) =tempBounds(1);
end

boundaryMap = nan(experimentStructure.pixelsPerLine);
%iterate through ROI number to get them in appropriate order
for i = 1: length(boundaries)
    bound2Plot = boundaries{i};
    ind = sub2ind(size(boundaryMap),bound2Plot(:,1),bound2Plot(:,2));
    boundaryMap(ind) = 0;
end
 boundaryMap = repmat(boundaryMap,1, 1, 3);

%% create map

% LM map
cellMapLMRescale = round(cellMapLM*256);
cellMapLMRescale(cellMapLMRescale ==0) = 2;
% cellMapLM_RGB = ind2rgb(cellMapLMRescale, [LvMLog_colMap ;0.5 0.5 0.5]);
cellMapLM_RGB = ind2rgb(cellMapLMRescale, [LvM_colMap ;0.5 0.5 0.5]);

cellMapLM_RGB(boundaryMap==0) = 0;
% plots index map and applies LCS colors
figMap = imshow(cellMapLM_RGB);
hold on
map2Display = LvM_colMap;
% map2Display = LvMLog_colMap;
colormap(map2Display(2:end,:));


set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
colorBar = colorbar ;
axis on
set(gca,'xtick',[]);
set(gca,'ytick',[])
colorBar.TickLabels = [linspace(-1,1, 11)];

saveas(figMap, [experimentStructure.savePath 'Cone Input Map LM.tif']);
imwrite(cellMapLM_RGB, [experimentStructure.savePath 'Cone Input Map LM_native.tif']);

% saveas(figMap, [experimentStructure.savePath 'Cone Input Map Log LM.tif']);
% imwrite(cellMapLM_RGB, [experimentStructure.savePath 'Cone Input Map Log LM_native.tif']);

close();




% S/LM map
cellMapS_LMRescale = round(cellMapS_LM*256);
cellMapS_LMRescale(cellMapS_LMRescale ==0) = 2;

% cellMapS_LM_RGB = ind2rgb(cellMapS_LMRescale, [SvLMlog_colMap ;0.5 0.5 0.5]);
cellMapS_LM_RGB = ind2rgb(cellMapS_LMRescale, [SvLM_colMap ;0.5 0.5 0.5]);

cellMapS_LM_RGB(boundaryMap==0) = 0;
% plots index map and applies LCS colors
figMap = imshow(cellMapS_LM_RGB);
hold on

% map2Display = SvLMlog_colMap;
map2Display = SvLM_colMap;
colormap(map2Display(2:end,:));


set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
colorBar = colorbar ;
axis on
set(gca,'xtick',[]);
set(gca,'ytick',[])
colorBar.TickLabels = [linspace(-1,1, 11)];

% saveas(figMap, [experimentStructure.savePath 'Cone Input Map Log S_LM.tif']);
% imwrite(cellMapS_LM_RGB, [experimentStructure.savePath 'Cone Input Map Log S_LM_native.tif']);

saveas(figMap, [experimentStructure.savePath 'Cone Input Map S_LM.tif']);
imwrite(cellMapS_LM_RGB, [experimentStructure.savePath 'Cone Input Map S_LM_native.tif']);

close();

end