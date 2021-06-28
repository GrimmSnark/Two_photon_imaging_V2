function plotOnOffResponseMaps(filepath, thresholdZ, secondCndDimension)

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

if nargin <3 || isempty(secondCndDimension)
    secondCndDimension = 1;
end

% get the orientation groups for each of the second
totalCnds = 1:length(experimentStructure.cndTotal);
orientationsBy2ndDim = reshape(totalCnds,[],secondCndDimension)';


%% get zscores for stim and postim, ie ON / OFF

data = experimentStructure.dFperCndMeanFBS;
dataSD = experimentStructure.dFperCndMeanFBS;

prestimMean = cellfun(@mean,cellfun(@mean,cellfun(@cell2mat,experimentStructure.dFpreStimWindowAverageFBS, 'Un', 0), 'Un', 0));
prestimSD =cellfun(@std,cellfun(@mean,cellfun(@cell2mat,experimentStructure.dFpreStimWindowAverageFBS, 'Un', 0), 'Un', 0));

prestimResponse = 1: experimentStructure.stimOnFrames(1)-2;
stimResponse = experimentStructure.stimOnFrames(1): experimentStructure.stimOnFrames(2);
postStimResponse = experimentStructure.stimOnFrames(2)-1: experimentStructure.stimOnFrames(2)+ 2;
postStimeBase = experimentStructure.stimOnFrames(2)+ 3: experimentStructure.meanFrameLength;

% get postStim ZScore
for cellNo = 1:experimentStructure.cellCount
    for  cnd = 1:length(totalCnds)
        stimZScore(cellNo,cnd) = (mean(data{cellNo}(stimResponse,cnd)) - prestimMean(cellNo))/ prestimSD(cellNo);
        postStimZScore(cellNo,cnd) = (mean(data{cellNo}(postStimResponse,cnd)) - mean(data{cellNo}(postStimeBase,cnd)))/ mean(dataSD{cellNo}(postStimeBase,cnd));
    end
end

stimZScoreCnd = reshape(stimZScore, experimentStructure.cellCount, [], secondCndDimension);
postStimZScoreCnd = reshape(postStimZScore, experimentStructure.cellCount, [], secondCndDimension);

stimZScoreThresholded =  squeeze(any(stimZScoreCnd > thresholdZ, 2));
postStimZScoreThresholded =  squeeze(any(postStimZScoreCnd > thresholdZ, 2));


%% start plotting maps
% gets cell ROI map
cellROIs = experimentStructure.labeledCellROI;

% sets up blank images
cellMap = nan(experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine, secondCndDimension);

for i =1:secondCndDimension
    % sets up blank images
    cellMap = zeros(experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine);
    
    for cell = 1:experimentStructure.cellCount
        stimZTemp = stimZScoreThresholded(cell,i);
        postStimZTemp = postStimZScoreThresholded(cell, i);
        
        if stimZTemp == 0 && postStimZTemp == 0 % non responsive
            cellMap(cellROIs ==cell) = 1 ;
        elseif stimZTemp == 1 && postStimZTemp == 0 % stim on cell
            cellMap(cellROIs ==cell) = 2 ;
        elseif stimZTemp == 0 && postStimZTemp == 1 % stim off cell
            cellMap(cellROIs ==cell) = 3 ;
        elseif stimZTemp == 1 && postStimZTemp == 1 % stim on/off cell
            cellMap(cellROIs ==cell) = 4 ;
        end
    end
    cellMapsTotal(:,:,i) = cellMap;
end


%% Plot maps
for i =1:secondCndDimension
rgbMap = ind2rgb(cellMapsTotal(:,:,i)+1, [1 1 1; 0.5 0.5 0.5 ; 0 1 0; 1 0 0; 1 1 0 ; 1 1 0 ]);
    figMap = imshow(rgbMap);

    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    axis on
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    axis square
    tightfig;
    
    saveas(gcf, [experimentStructure.savePath  'On_Off_Response_Cnd_' num2str(i) '.svg']);
    imwrite(rgbMap, [experimentStructure.savePath  'On_Off_Response_Cnd_' num2str(i) '.tif']);
end

end