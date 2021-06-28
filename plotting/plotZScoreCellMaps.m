function plotZScoreCellMaps(filepath, thresholdZ)

%% set defaults

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

if nargin <2
    thresholdZ =[];
end

%% start getting data

% gets cell ROI map
cellROIs = experimentStructure.labeledCellROI;

% sets up blank images
cellMap = zeros(experimentStructure.pixelsPerLine);
nonResponsiveMap = cellMap;

zScore = experimentStructure.ZScore;

% map zscores to blank image, if under threshold set to NaN
for cellNo = 1:length(zScore)
    
    if zScore(cellNo) > thresholdZ
        cellMap(cellROIs ==cellNo) = zScore(cellNo);
    else
        cellMap(cellROIs ==cellNo) = NaN;
    end
end

%% create map

% rescales image to 0-1 and applys colormap
cellMapRescale = cellMap/max(cellMap(:));
cellMapRescale = round(cellMapRescale*256);
cellMapRGB = ind2rgb(cellMapRescale,[lcs; 0.5 0.5 0.5] );

figMap = imshow(cellMapRGB);
colormap(lcs);
set(gcf, 'units','normalized','outerposition',[0 0 0.5 1]);
colorBar = colorbar ;
axis on
set(gca,'xtick',[]);
set(gca,'ytick',[])
% colorBar.Limits = [0 round(max(map),1)];
% colorBar.Ticks =  [0. 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6];
colorBar.TickLabels = [linspace(0,round(max(zScore),1), 11)];

saveas(figMap, [experimentStructure.savePath  'ZScore_LCS.tif']);
imwrite(cellMapRGB, [experimentStructure.savePath  'ZScore_LCS_native.tif']);

end
