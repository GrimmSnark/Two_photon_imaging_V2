function plotCellOrienationPref(filepath, noOrientations, angleMax, secondCndDimension , dataType, zScoreThreshold)
% Creates a RGB image of maximal response for orientation pref for every
% cell based on the DF/F signal
%
% Inputs: filepath - processed data folder containing the
%                     experimentStructure.mat, or the fullfile to the
%                     experimentStructure.mat OR the structure itself
%
%         noOrientations - number of orientations tested in the experiment
%                          ie 4/8 etc, default = 8
%
%         secondCndDimension - number of conditions in the second 
%                              dimension, e.g. colors tested, ie 1 for 
%                              black/white, 4 monkey color paradigm, or
%                              number of spatial frequencies etc
%                              default = 1
%
%          data2Use - specify the type of data to use
%                     FBS- first before stimulus subtraction (For LCS)
%                     Neuro_corr- Neuropil corrected based subtraction
%
%          zScoreThreshold - z score threshold to classify cell as visually
%                            responsive, default == 4

%% set defaults

% Allows for the folder2Process to be not the one set in
% experimentStructure.savePath

if ~isstruct(filepath) % variable is filepath
    try
        load(filepath, '-mat');
        filePath2Use = dir(filepath);
        experimentStructure.savePath = [filePath2Use.folder '\'] ;
    catch
        load([filepath '\experimentStructure.mat']);
        experimentStructure.savePath = [filepath '\'];
    end
else % if variable is the experimentStructure
    experimentStructure = filepath;
    clearvars filepath
end


if nargin <2 || isempty(noOrientations)
    noOrientations = 8;
end

if nargin <3 || isempty(angleMax)
    angleMax = 360;
end

if nargin <4 || isempty(secondCndDimension)
    secondCndDimension = 1;
end


if nargin <5 || isempty(dataType)
    dataType = 'FBS';
end

if nargin <5 || isempty(zScoreThreshold)
    zScoreThreshold = 4;
end


% check that the condition numbers match up
cndCheck = noOrientations * secondCndDimension;

if cndCheck ~=length(experimentStructure.cndTotal)
    disp('Wrong no of orientation and secomd dimension conditions (color/spatial freq) entered!!!');
    disp('Please fix and rerun');
    close
    return
end


%% Set up maps and get data

% get data
switch dataType
    case 'FBS'
        data = experimentStructure.dFstimWindowAverageFBS;
         responseFlagText = 'responsiveCellFlag';
        textTag = '_FBS';
    case 'Neuro_corr'
        data = experimentStructure.dFstimWindowAverage;
         responseFlagText = 'responsiveCellFlagFISSA';
        textTag = 'Neuro_corr';     
end

% get angles for labels
orientations     = linspace(0,angleMax,noOrientations+1);
orientations     = orientations(1:end-1);

% set up maps
cellROIs = experimentStructure.labeledCellROI;
cellMap = zeros(experimentStructure.pixelsPerLine);
nonResponsiveMap = cellMap;

orientationColLevels = round(linspace(1, 256, length(orientations)));


dataMean = cellfun(@mean,(cellfun(@cell2mat,data, 'Un', false)), 'Un', false);

% get preferred orientation per cell
for i = 1:experimentStructure.cellCount
    [~,prefCnd(i)] = max(dataMean{i});
    [prefOrientationNo(i), pref2ndDimCnd(i)] = ind2sub([noOrientations secondCndDimension],prefCnd(i));
end

for i = 1:experimentStructure.cellCount
    try % try to use new z score metric
        if experimentStructure.ZScore(i) > zScoreThreshold
            cellMap(cellROIs ==i) = orientationColLevels(prefOrientationNo(i));
        else
            nonResponsiveMap(cellROIs ==i) = 255;
        end
        
    catch % if not use old thershold metric
        if eval(['experimentStructure.' responseFlagText '(' num2str(i) ') ~=0'])
            cellMap(cellROIs ==i) = orientationColLevels(prefOrientationNo(i));
        else
            nonResponsiveMap(cellROIs ==i) = 255;
        end
    end
end

% create RGB images
cellMap(cellMap==0) = NaN;
cellMapRGB = ind2rgb(cellMap,[ggb1; 1 1 1]);


figure
nonResponsCont = im2bw(nonResponsiveMap);
nonResponsCont = ~nonResponsCont;
nonResponsCont = cat(3, nonResponsCont, nonResponsCont, nonResponsCont);
cellMapRGB(nonResponsCont == 0) = 0.5;

colormap(ggb1);
figMap = imshow(cellMapRGB);
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
colorBar = colorbar ;
axis on
set(gca,'xtick',[]);
set(gca,'ytick',[])
% colorBar.Limits = [0 round(max(map),1)];
 colorBar.Ticks =  [linspace(0,1,noOrientations)];
colorBar.TickLabels = orientations;

saveas(figMap, [experimentStructure.savePath  'orientation_Pref' textTag '.tif']);
imwrite(cellMapRGB, [experimentStructure.savePath 'orientation_Pref_native' textTag '.tif']);
close();
end