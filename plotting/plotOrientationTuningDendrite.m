function plotOrientationTuningDendrite(experimentStructure,dendriteStructure, cellNo, noOrientations, angleMax, plotPrefCndTraces, secondCndDimension,  useSTDorSEM, axisLims, secondCndDimensionLabels )
% plots and saves figure for cells with preferred stimulus average (with
% individual trial and the average responses for each condition.
%
% Inputs:  exFilepath - processed data folder containing the
%                     experimentStructure.mat, or the fullfile to the
%                     experimentStructure.mat OR the structure itself
%
%          denFilepath - processed data folder containing the
%                     experimentStructure.mat, or the fullfile to the
%                     experimentStructure.mat OR the structure itself
%
%          cellNo- number or vector of numbers for cells to plot
%
%          noOrientations - number of orientations tested in the experiment
%                          ie 4/8 etc, default = 8
%
%          angleMax - 360 or 180 for the Max angle tested, default = 360
%
%          secondCndDimension - number of conditions in the second
%                               dimension, e.g. colors tested, ie 1 for
%                               black/white, 4 monkey color paradigm, or
%                               number of spatial frequencies etc
%                               default = 1
%
%          plotPrefCndTraces - 0/1 flag to plot preferred condition and
%                              indivdual traces in subplot (1). If set to 0
%                              only plots the condition averages.
%                              default = 1
%
%          useSTDorSEM - 0/1 flag for using STD (1) or SEM (2) for error
%                        bars (OPTIONAL) default = 1 (STD error bars)
%
%          axisLims - Set y-axis limits for plots [min max]
%
%          secondCndDimensionLabels - This should be a cell string array
%                                     for labels of the second dimension.
%                                     Only used if secondCndDimension > 1.
%                                     Can either be string cell array size
%                                     of secondCndDimension OR a single
%                                     label which indicates a set of
%                                     values, ie 'NHP_Color' sets the
%                                     labels from
%                                     PTBOrientationColorValuesMonkeyV2.mat


%% set defaults

if nargin < 3 || isempty(cellNo)
    try
        cellNo = 1:dendriteStructure.cellCount;
    catch
        disp('No Cell ROIs found, please choose ROIs first!!!');
        return
    end
end

if nargin < 4 || isempty(noOrientations)
    noOrientations = 8;
end

if nargin < 5 || isempty(angleMax)
    angleMax = 360;
end

if nargin < 6 || isempty(plotPrefCndTraces)
    plotPrefCndTraces = 1;
end

if nargin < 7 || isempty(secondCndDimension)
    secondCndDimension = 1;
    lineCol = 'k';
    scndDimLabels = {'Orientations'};
end

if nargin < 8 || isempty(useSTDorSEM)
    useSTDorSEM = 1;
end

if nargin < 9 || isempty(axisLims)
    axisLims = [];
end

% sort out second dimension labels....This is still under development
% if there are more than one dimension apart from orientation
if secondCndDimension == 1
    
    scndDimLabels = {'Orientations'};
    lineCol = 'k';
    
elseif secondCndDimension > 1
    
    % checks if the label field is empty and sets to default
    if nargin < 10 || isempty(secondCndDimensionLabels)
        secondCndDimensionLabels = {'NHP_Color'};
    end
    
    % if the labels are set by string cell array function input
    if length(secondCndDimensionLabels)>1
        scndDimLabels = secondCndDimensionLabels;
    else % if indivdual marker i.e 'NHP_color' or standard set of variables switches through cases
        switch secondCndDimensionLabels{:}
            case 'NHP_Color'
                [~, scndDimLabels] = PTBOrientationColorValuesMonkeyV2;
                scndDimLabels = scndDimLabels(2:end);
        end
    end
    lineCol =distinguishable_colors(length(scndDimLabels), 'w'); % gets number of line colors
end

%% Create plots

for i =cellNo
    
    % create figure
    figHandle = figure('units','normalized','outerposition',[0 0 1 1]);
    
    % get angles for labels
    angles     = linspace(0,angleMax,noOrientations+1);
    angles     = angles(1:end-1);
    
    % check that the condition numbers match up
    cndCheck = noOrientations * secondCndDimension;
    
    if cndCheck ~=length(experimentStructure.cndTotal)
        disp('Wrong no of orientation and secomd dimension conditions (color/spatial freq) entered!!!');
        disp('Please fix and rerun');
        close
        return
    end
    
    % get data
    stimResponseTrialAverage = cell2mat(dendriteStructure.dFstimWindowAverageFBS{i});
    prestimResponse = cell2mat(dendriteStructure.dFpreStimWindowAverageFBS{i});
    trialTraces     = dendriteStructure.dFperCndFBS{i};
    trialTracesMean = dendriteStructure.dFperCndMeanFBS{i};
    errorBarTraces = dendriteStructure.dFperCndSTDFBS{i};
    
    % get preferred condition
    stimResponseAverage = mean(stimResponseTrialAverage,1);
    [~, preferredStimulus] = max(stimResponseAverage);
    
    % test if significant response
    prefResponses = stimResponseTrialAverage(:,preferredStimulus);
    blankPrefResponses = prestimResponse(:,preferredStimulus);
    
    pVal = ranksum(prefResponses, blankPrefResponses);
    
    if pVal < 0.05
        sigText = 'Sig Response';
    else
        sigText = 'Non-sig Response';
    end
    
    % get pref stim data
    responsePreferred = trialTraces{1, preferredStimulus};
    responseMeanPreferred = trialTracesMean(:,preferredStimulus);
    
    
    % get time alignment for single traces
    timeFrame = ((1: experimentStructure.meanFrameLength) * experimentStructure.framePeriod) - experimentStructure.stimOnFrames(1)*experimentStructure.framePeriod;
    
    % Get preferred secondary condition
    [prefOrientation, prefScndDim] = ind2sub([noOrientations secondCndDimension],preferredStimulus);
    
    % get label for preferred secondary condition
    prefScndDimTest = scndDimLabels{prefScndDim};
    
    %% plot preferred stim responses
    if plotPrefCndTraces ==1
        % Show response timcourse for preferred response
        subplot(1,2,1);
        plot(timeFrame,responseMeanPreferred,'-r','lineWidth',3);
        hold on;
        plot(timeFrame,responsePreferred,'--k','Color',0.25*[1,0,0]);
        
        % Add figure labels
        legend({'Average response','Trial responses'},'Location','northwest');
        xlim([min(timeFrame) max(timeFrame)]);
        set(gca,'Box','off');
        xticks([0 5, 10]);
        title(sprintf('Preferred response at %d%s Condition: %s for cell %d: %s (p= %0.5g)',angles(prefOrientation),char(176),prefScndDimTest,i, sigText, pVal));
        ylabel('\DeltaF/F')
        xlabel('Time (seconds)')
    end
    
    
    %% plot averages for all conditions
    
    % get max and min data for limiting axes
    if isempty(axisLims)
        if useSTDorSEM == 1
            maxData = trialTracesMean + errorBarTraces;
            maxData = max(maxData(:));
            minData = trialTracesMean - errorBarTraces;
            minData = min(minData(:));
        elseif useSTDorSEM ==2
            maxData = trialTracesMean + (errorBarTraces/2);
            maxData = max(maxData(:));
            minData = trialTracesMean - (errorBarTraces/2);
            minData = min(minData(:));
        end
    else
        minData = axisLims(1);
        maxData = axisLims(2);
    end
    
    
    hold on
    prev2ndDim = 0;
    % for each condition
    for x =1:length(stimResponseAverage)
        
        % get length of traces
        lengthOfData = experimentStructure.meanFrameLength;
        
        % get current second dimension number
        current2ndDim = (x/noOrientations);
        if floor(current2ndDim)~=current2ndDim
            current2ndDim = ceil(current2ndDim);
        end
        
        % get the spacings and labels for the traces
        if current2ndDim< 2
            spacing = 5;
            xlocations(x,:) = ((lengthOfData +lengthOfData* (x-1))- (lengthOfData-1) :lengthOfData + lengthOfData* (x-1)) + spacing*(x-1);
            xlocationMid(x) = xlocations(x,round(lengthOfData/2));
        else
            currentOrientation =  x- ((current2ndDim-1)*noOrientations);
            xlocations(x,:) = xlocations(currentOrientation,:);
        end
        
        % set axis labels if on new 2nd dim axis
        if current2ndDim > prev2ndDim
            % switches the plots if only displaying condition averages
            if plotPrefCndTraces == 1
                subFighandle = subplot(secondCndDimension,2,current2ndDim*2);
            else
                subFighandle = subplot(secondCndDimension,1,current2ndDim);
            end
            
            ylabel('\DeltaF/F')
            xlabel(sprintf('Stimulus direction (%s)', char(176)));
            ylim([minData maxData]);
            title(['Condition: ' scndDimLabels{current2ndDim}]);
        end
        
        % set labels
        xticks(xlocationMid);
        xticklabels([angles]);
        
        % use appropriate error bars
        if useSTDorSEM == 1
            errorBarsPlot = errorBarTraces (:,x);
        elseif useSTDorSEM ==2
            errorBarsPlot = errorBarTraces (:,x)/ (sqrt(experimentStructure.cndTotal(x)));
        end
        
        % plot trace
        curentLineCol = lineCol(current2ndDim,:);
        shadedErrorBarV2(xlocations(x,:), trialTracesMean(:,x)', errorBarsPlot, 'lineprops' , {'color',[curentLineCol]});
        prev2ndDim = current2ndDim;
        
        % add zero line
        if rem(x,noOrientations) == 0
            hline(0,'k--','');
        end
    end
    tightfig;
    
    %% save the figures
    if useSTDorSEM == 1
        if ~exist([experimentStructure.savePath 'RawLinePic\dendrites\STDs\'], 'dir')
            mkdir([experimentStructure.savePath 'RawLinePic\dendrites\STDs\']);
        end
        saveas(figHandle, [experimentStructure.savePath 'RawLinePic\dendrites\STDs\Orientation Tuning Cell ' num2str(i) '.tif']);
        saveas(figHandle, [experimentStructure.savePath 'RawLinePic\dendrites\STDs\Orientation Tuning Cell ' num2str(i) '.svg']);
    elseif useSTDorSEM == 2
        if ~exist([experimentStructure.savePath 'RawLinePic\dendrites\SEMs\'], 'dir')
            mkdir([experimentStructure.savePath 'RawLinePic\dendrites\SEMs\']);
        end
        saveas(figHandle, [experimentStructure.savePath 'RawLinePic\dendrites\SEMs\Orientation Tuning Cell ' num2str(i) '.tif']);
        saveas(figHandle, [experimentStructure.savePath 'RawLinePic\dendrites\SEMs\Orientation Tuning Cell ' num2str(i) '.svg']);
    end
    
    close;
end
end