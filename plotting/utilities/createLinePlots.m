function createLinePlots(experimentStructure, data , noOrientations, angleMax,secondCndDimension, scndDimLabels, logFlag )
% Subfunction with used by plotLineProfilesPerCnd to create the actual
% plots.
%
% Inputs:  experimentStructure - class object holding all the experiment
%                                info
%
%          data - data to plot for evey line
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
%          scndDimLabels - This should be a cell string array
%                          for labels of the second dimension. Only used if
%                          secondCndDimension > 1. Can either be string 
%                          cell array size of secondCndDimension OR a 
%                          single label which indicates a set of values, 
%                          ie 'NHP_Color' sets the labels from
%                          PTBOrientationColorValuesMonkeyV2.mat
%
%          logFlag - 0/1 which changes the identifer flag for the log image
%                    0 = not log, normal linear scale
%                    1 = log identifer

%% choose data ident
if logFlag == 1
    identText = 'Line_Log_';
else
    identText = 'Line_';
end

% get angles for labels
angles     = linspace(0,angleMax,noOrientations+1);
angles     = angles(1:end-1);

%% go through the data plots
for p = 1:length(data) % for each line
    
    figHandle =figure('units','normalized','outerposition',[0 0 1 0.7]);
    
    data2Plot = uint8(data{p} * 256);
    % for each condition
    for cndNo = 1:length(experimentStructure.cndTotal)
        
        [currentOrientation, current2ndDim] = ind2sub([noOrientations,secondCndDimension],cndNo);
        
        %create subplot
        subplot(secondCndDimension, noOrientations, cndNo);
        
        
        %plot image
        imageCndMeanRGB = ind2rgb(data2Plot(:,:,cndNo), lcs);
        imshow(imageCndMeanRGB);
        
        title(['Condition: ' scndDimLabels{current2ndDim} '   ' num2str(angles(currentOrientation))]);
        
        % get time point increment for 5 sec
        frameEq5sec = 5/experimentStructure.framePeriod;
        
        %% format the axis
        axis on
        % y axis
        yticks(experimentStructure.stimOnFrames(1)+1:frameEq5sec: size(imageCndMeanRGB,1));
        yticklabels(0:5:35);
        hline([experimentStructure.stimOnFrames+1], 'g--');
        ylabel('Time since Stim On (s)');
        
        % x axis
        lineSize = size(imageCndMeanRGB,2);
        increment = experimentStructure.micronsPerPixel(1)*5;
        middleXTickValue = lineSize/2;
        
        leftSideTicks = sort(middleXTickValue:-increment:-20); % makes minus tick locations
        leftSideTicks = leftSideTicks(leftSideTicks>0); % gets rid of negative values
        leftSideTicks(leftSideTicks<0.5) = 0.5; % fixes display error on small tick value
        ticksPlot = [leftSideTicks(1:end-1)  middleXTickValue:increment:lineSize];
        xticks(ticksPlot);
        
        xtickNums = (1:length(ticksPlot))*5;
        xtickNums = xtickNums - xtickNums(ceil(length(xtickNums)/2));
        
        xticklabels(xtickNums);
        xlabel('Distance from center (um)');
        
        %% save data
        if ~exist([experimentStructure.savePath  'RawLinePic\native\'],'dir')
            mkdir([experimentStructure.savePath  'RawLinePic\native']);
        end
        
        imwrite(imageCndMeanRGB, [experimentStructure.savePath  'RawLinePic\native\' identText num2str(p) '_condNo_' num2str(cndNo) '.tif']);
        
    end
    
    tightfig;
    
    saveas(figHandle, [experimentStructure.savePath 'RawLinePic\' identText  '_Plot_' num2str(p)  '.tif']);
    close;
end

end