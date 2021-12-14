function plotCorrelationPairResponses(experimentStructure, cellPairs)
% Plots average condition responses, stimulus and noise correlations for
% specficed pairs of cells ( used for mouse data)
%
% Inputs: experimentStructure - experimentStructure containing all the
%                               information for the run
%
%         cellPairs - m x 2 number cell pair list to compare

%% choose the right data for mouse
if length(experimentStructure.cndTotal) > 8
    data2Use =cellfun(@(a) a(:, 33:40), experimentStructure.dFperCndMeanFBS, 'un', 0);
    errorBarData = cellfun(@(a) a(:,33:40), experimentStructure.dFperCndSTDFBS, 'un', 0);
else
    data2Use = experimentStructure.dFperCndMean;
    errorBarData = experimentStructure.dFperCndSTDFBS;
end

% get angles for labels
angles     = linspace(0,360,8+1);
angles     = angles(1:end-1);

%% Create plots
for i =1:size(cellPairs,1)
    % create figure
    figHandle = figure('units','normalized','outerposition',[0 0 1 1]);
    hold on
    axisLims = [] ;

    for q = 1: size(cellPairs, 2)
        subFighandle(q) = subplot(2,1,q);
        
        data = data2Use{cellPairs(i,q)};
        errorBarDataCell = errorBarData{cellPairs(i,q)};
        
        for x =1:size(data,2)
            
            % get length of traces
            lengthOfData = experimentStructure.meanFrameLength;
            
            spacing = 5;
            xlocations(x,:) = ((lengthOfData +lengthOfData* (x-1))- (lengthOfData-1) :lengthOfData + lengthOfData* (x-1)) + spacing*(x-1);
            xlocationMid(x) = xlocations(x,round(lengthOfData/2));
            
            
            errorBarsPlot = errorBarDataCell (:,x);
            
            
            % get max and min data for limiting axes
            if isempty(axisLims)
                maxData = data + errorBarDataCell;
                maxData = max(maxData(:));
                minData = data - errorBarDataCell;
                minData = min(minData(:));
            else
                minData = axisLims(1);
                maxData = axisLims(2);
            end
            
            ylabel('\DeltaF/F')
            xlabel(sprintf('Stimulus direction (%s)', char(176)));
            ylim([minData maxData]);
            title(['Cell No: ' num2str(cellPairs(i,q)) '      OSI (1-CV): ' num2str(experimentStructure.OSIStruct{cellPairs(i,q),end}.OSI_CV)]);
            
            
            
            % plot trace
            shadedErrorBarV2(xlocations(x,:), data(:,x)', errorBarsPlot, 'lineprops' , {'color',[0 0 1]});
            
            % set labels
            xticks(xlocationMid);
            xticklabels([angles]);
        end
        
        hline(0,'k--','');
        
        % add tuning curve
        try
            respacedCurve = interp1(1: length(experimentStructure.OSIStruct{cellPairs(i,q), end}.LSStruct.modelTrace), experimentStructure.OSIStruct{cellPairs(i,q), end}.LSStruct.modelTrace, linspace(1,length(experimentStructure.OSIStruct{cellPairs(i,q), end}.LSStruct.modelTrace),subFighandle(q).XLim(2)), 'spline');
            plot(0:subFighandle(q).XLim(2)-1,respacedCurve, 'Color',[0 0 1],'LineStyle', '--');
        catch
            
        end
    end
    subplotEvenAxes(gcf);
    
    for x =1:size(data,2)
        % plot stim on/off lines
        vline2(subFighandle,[xlocations(x,1)+experimentStructure.stimOnFrames(1)-2  xlocations(x,1)+experimentStructure.stimOnFrames(2)-2 ], {'k--', 'k--' },{'', ''} );
    end
    
    tightfig;
    corrMetrics = getCorrMetricCellPair(experimentStructure, cellPairs(i,:));
    
    suptitle(['Signal Correlation : ' num2str(corrMetrics.corr(1)) '   Noise Correlation : ' num2str(corrMetrics.corr(2))  '   Soma distance : ' num2str(corrMetrics.distance) 'um']);
    
     if ~exist([experimentStructure.savePath 'pairCorrPlots\'], 'dir')
                mkdir([experimentStructure.savePath 'pairCorrPlots\']);
     end
            
    saveas(figHandle, [experimentStructure.savePath 'pairCorrPlots\Cells ' num2str(cellPairs(i,:)) '.png']);
    close;

end


end