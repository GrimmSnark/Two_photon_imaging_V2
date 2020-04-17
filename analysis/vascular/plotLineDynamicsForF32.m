function plotLineDynamicsForF32(MIJImageROI,registeredVolMIJI, experimentStructure, plotAverageGraphs, numLines)
% Subfunction called by lineAnalysisForBloodVessels which actually plots
% line selection averages per condition in a stim on locked time series.
roiLine = MIJImageROI.getRoi();
pointsOnLine = roiLine.getContainedPoints();

if ~isempty(numLines)
    for q =1:numLines
        for i = 1:length(pointsOnLine)
            pointsOnLineCoordinates(i,:) = [ pointsOnLine(i).getX pointsOnLine(i).getY ];
            registeredVolMIJI.setRoi(pointsOnLineCoordinates(i,1), pointsOnLineCoordinates(i,2)-(q-1),1,1);
            
            plotF = ij.plugin.ZAxisProfiler.getPlot(registeredVolMIJI);
            RT(:,1) = plotF.getXValues();
            RT(:,2) = plotF.getYValues();
            zProfilesPerPixel(i,:,q)= RT(:,2);
        end
    end
    zProfilesPerPixel = mean(zProfilesPerPixel,3);
else
    for i = 1:length(pointsOnLine)
    pointsOnLineCoordinates(i,:) = [ pointsOnLine(i).getX pointsOnLine(i).getY ];
    registeredVolMIJI.setRoi(pointsOnLineCoordinates(i,1), pointsOnLineCoordinates(i,2),1,1);
    
    plotF = ij.plugin.ZAxisProfiler.getPlot(registeredVolMIJI);
    RT(:,1) = plotF.getXValues();
    RT(:,2) = plotF.getYValues();
    zProfilesPerPixel(i,:)= RT(:,2);
    
end
    
end


stimOnLine = zeros(length(zProfilesPerPixel), 1);

% stimOnLine(experimentStructure.EventFrameIndx.STIM_ON) = max(zProfilesPerPixel(:)/2);
% markedZProfilesPerPixel = [stimOnLine zProfilesPerPixel'];
% axisLabel  = imagesc(markedZProfilesPerPixel);
% axis equal
% scrollplot('axis', 'xy');
% colormap(lcs);

% checks if meanFrameLength exists, if not calculates it
if ~isfield(experimentStructure , 'meanFrameLength')
    experimentStructure.meanFrameLength = ceil(mean(experimentStructure.EventFrameIndx.TRIAL_END - experimentStructure.EventFrameIndx.PRESTIM_ON));
    save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');
end

% checks if stimOnFrames exists, if not calculates it
if ~isfield(experimentStructure , 'stimOnFrames')
    experimentStructure.stimOnFrames = [ceil(mean(experimentStructure.EventFrameIndx.STIM_ON - experimentStructure.EventFrameIndx.PRESTIM_ON))+1 ...
            ceil(mean(experimentStructure.EventFrameIndx.STIM_OFF - experimentStructure.EventFrameIndx.PRESTIM_ON))-1];
    save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');
end

% get time point increment for 5 sec
 frameEq5sec = 5/experimentStructure.framePeriod;
        

for cnd = 1:length(experimentStructure.cndTotal)
    cndIndexs = find(experimentStructure.cnd(:,2) == cnd);
    for trial = 1:length(cndIndexs)
        framStimStart = experimentStructure.EventFrameIndx.STIM_ON(cndIndexs(trial))-floor(frameEq5sec);
        
        if framStimStart>0
        cndLines(cnd,trial,:,:) = zProfilesPerPixel(:,framStimStart:(framStimStart + experimentStructure.meanFrameLength) -1);
        else
            cndLines(cnd,trial,:,:) = nan(size(zProfilesPerPixel,1),length(framStimStart:(framStimStart + experimentStructure.meanFrameLength) -1));
        end
    end
end

cndLineMeans = squeeze(nanmean(cndLines,2));
% figHandle = figure('units','normalized','outerposition',[0 0 1 1]);

% cndLineMeans = cndLineMeans([2 3 6 7],:,:);
maxVal = max(cndLineMeans(:));
minVal = min(cndLineMeans(:));
figHandle = figure('units','normalized','outerposition',[0 0 0.8 1]);
for plotNo = 1:size(cndLineMeans,1)
    colormap(lcsNew);

    subplot(2, 4, plotNo);
    handeIm = imagesc(squeeze(cndLineMeans(plotNo,:,:))');
    
    imageCndMean = squeeze(cndLineMeans(plotNo,:,:))';
    imageCndMeanRGB = convertIndexImage2RGB(imageCndMean, lcsNew);
    
    imwrite(imageCndMeanRGB, [experimentStructure.savePath  'RawLinePlot\Line_condNo' num2str(plotNo) '.tif']);


%     imagesc(imgaussfilt(squeeze(cndLineMeans(plotNo,:,:))',1));
%     tempImg = squeeze(cndLineMeans(plotNo,:,:))';
%    rgbTempImg = convertIndexImage2RGB(tempImg, lcs, minVal, maxVal);
%  
%     imwrite(rgbTempImg, [experimentStructure.savePath ' Cnd ' num2str(plotNo) ' Line Plot .tiff']);
    title(['Condition: ' num2str(plotNo)]);
    
    tickPositions =[experimentStructure.stimOnFrames(1):frameEq5sec:size(cndLineMeans, 3)];
    if experimentStructure.stimOnFrames(1)< floor(frameEq5sec)+1
        tickPositions = [1 tickPositions];
        ylabelValueFirst = ceil(experimentStructure.framePeriod*  experimentStructure.stimOnFrames(1));
        ylabelValues = [- ylabelValueFirst 0:5:((length(tickPositions)-1)*5)];
        ylabelValues = ylabelValues(1:end-1);
    else
        firstPos =  experimentStructure.stimOnFrames(1)-floor(frameEq5sec);
        tickPositions = [firstPos tickPositions];
        ylabelValues = [-5:5:((length(tickPositions)-1)*5)];
        ylabelValues = ylabelValues(1:end-1);
    end
    
    
    yticks(tickPositions);
    yticklabels(ylabelValues);
    
    lineSize = length(cndLineMeans(1,:,1));
    lineSizeinMicron = round(lineSize * experimentStructure.micronsPerPixel(1), -1);
    increment = experimentStructure.micronsPerPixel(1)*10;
    middleXTickValue = lineSize/2;
    
    currentTick = middleXTickValue;
    runningtotal = [];
    while currentTick > 0
        runningtotal = [runningtotal currentTick] ;
        currentTick = currentTick-increment;
    end
    
    runningtotal2 = middleXTickValue+ increment;
    currentTick = runningtotal2;
    while currentTick < lineSize
        currentTick = currentTick+increment;
        runningtotal2 = [runningtotal2 currentTick];
    end
    
    xtickVals = [fliplr(runningtotal) runningtotal2(1:end-1)];
    xticks(xtickVals)
    xticklabels(-20:10:20);
    
end

tightfig;
WaitSecs(0.1);
set(figHandle, 'units','normalized','outerposition',[0 0 0.8 1]);
set(figHandle, 'units','normalized','outerposition',[0 0 0.8 1]);
saveas(figHandle, [experimentStructure.savePath 'Vessel Line Plot X1_' num2str(pointsOnLineCoordinates(1,1)) ' Y1_' num2str(pointsOnLineCoordinates(1,2)) ' X2_' num2str(pointsOnLineCoordinates(end,1)) ' Y2_' num2str(pointsOnLineCoordinates(end,2)) '.png']);
saveas(figHandle, [experimentStructure.savePath 'Vessel Line Plot X1_' num2str(pointsOnLineCoordinates(1,1)) ' Y1_' num2str(pointsOnLineCoordinates(1,2)) ' X2_' num2str(pointsOnLineCoordinates(end,1)) ' Y2_' num2str(pointsOnLineCoordinates(end,2)) '.svg']);

if plotAverageGraphs ==1
%     bins = [1 8 ;20 27; 53 60] ;
%     % get the mean over the time bins (5s apart from prestim, NB prestim might be shorter than 5s)
%     for x = 1:length(bins)
%         meanTraces(:,:,x) = mean(cndLineMeans(:,:,bins(x,1):(bins(x,2))),3);
%     end
%     
%     figure('units','normalized','outerposition',[0 0 1 1]);
%     % for each color
%     for condNo = 1:size(meanTraces,1)
%         subplot(1, size(meanTraces,1),condNo)
%            title(['Condition: ' num2str(condNo)]);
%            hold on
%            for bin = 1:size(meanTraces,3)
%                 plot(meanTraces(condNo,:,bin));
%            end
%             legend({'PresStim', 'Stim', 'PostStim'});
%     end
%     saveas(gcf, [experimentStructure.savePath 'Vessel Line Graph X1_' num2str(pointsOnLineCoordinates(1,1)) ' Y1_' num2str(pointsOnLineCoordinates(1,2)) ' X2_' num2str(pointsOnLineCoordinates(end,1)) ' Y2_' num2str(pointsOnLineCoordinates(end,2)) '.png']);

   bins = [1 8 ;20 27; 53 60] ;
    % get the mean over the time bins (5s apart from prestim, NB prestim might be shorter than 5s)
    for x = 1:length(bins)
        meanTraces(:,:,x) = mean(cndLineMeans(:,:,bins(x,1):(bins(x,2))),3);
    end
    
    figure('units','normalized','outerposition',[0 0 0.6 0.4]);
    % for each stim Cnd
    titletext = {'PresStim', 'Stim', 'PostStim'};
    for condNo = 1:size(meanTraces,3)
         legendText =[];
        subplot(1, size(meanTraces,3),condNo)
        title(titletext{condNo});
           hold on
           for stimCnd = 1:size(meanTraces,1)
                legendText = [legendText ' '' Condition: ' num2str(stimCnd) ' '','];
                plot(meanTraces(stimCnd,:,condNo));
           end
             eval(['legend({' legendText(1:end-1) '});']);
    end
    saveas(gcf, [experimentStructure.savePath 'Vessel Line Graph X1_' num2str(pointsOnLineCoordinates(1,1)) ' Y1_' num2str(pointsOnLineCoordinates(1,2)) ' X2_' num2str(pointsOnLineCoordinates(end,1)) ' Y2_' num2str(pointsOnLineCoordinates(end,2)) 'V2.png']);
    savefig(gcf, [experimentStructure.savePath 'Vessel Line Graph X1_' num2str(pointsOnLineCoordinates(1,1)) ' Y1_' num2str(pointsOnLineCoordinates(1,2)) ' X2_' num2str(pointsOnLineCoordinates(end,1)) ' Y2_' num2str(pointsOnLineCoordinates(end,2)) 'V2.fig']);




end

% close;
end
