function pairwiseNoiseCorrelations(experimentStructure, cnd2Use, plotFlag)

if nargin <3 || isempty(plotFlag)
   plotFlag = 0; 
end

if isprop(experimentStructure,'correlations')
    experimentStructure.correlations = rmfield(experimentStructure.correlations,'corrNoiseMatrix' );
end

numReps = median(experimentStructure.cndTotal);

% extract the data from expeimentStructure
for i = 1:experimentStructure.cellCount
    responseMat(i,:,:,:) = reshape(cell2mat(experimentStructure.dFperCndFBS{1,i}),1,experimentStructure.meanFrameLength,numReps,[]);
end

% limit to useful conditions, ie full contrast
responseMat = responseMat(:,:,:,cnd2Use);

% check cells are valid, ie have responses in the chosen conditions
nanValuesPerCnd = squeeze(sum(isnan(squeeze(mean(responseMat,3))),2)); % gets the number of NaN values totaled across every condition for each cell
invalidCells = logical(sum(nanValuesPerCnd,2)); % creates a logical array of invalid NaN cells


% get XY locations
cellXY = [experimentStructure.xPos experimentStructure.yPos];

% get cell overlap
cellIdentity = experimentStructure.ChannelOverlap;


% remove invalid cells
responseMat(invalidCells,:,:,:) = [];
cellXY(invalidCells,:) = [];
cellIdentity(invalidCells,:) = [];


% remove zero frame to spot spurious correlations
responseMat(:,experimentStructure.stimOnFrames(1)-2,:,:) = [];
%% run through all possible pairs

allPairs = nchoosek(1:length(responseMat),2);
for x = 1:length(allPairs)
    
    A = allPairs(x,1);
    B = allPairs(x,2);
    
    responseA = responseMat(A,:);
    responseB = responseMat(B,:);
    
    % for each condition
    for b = 1:size(responseMat,4)
        corrC = corrcoef(responseA,responseB);
        corrPerCnd(b) = corrC(1,2);
    end
    
    corrNoiseMatrix(x) = mean(corrPerCnd);
    
    pairDistance(x) = pdist([cellXY(A,:); cellXY(B,:)],'euclidean');
    
    pairwiseCellId(x) = cellIdentity(A) + cellIdentity(B);
    
end

if ~isprop(experimentStructure,'correlations')
    experimentStructure.addprop('correlations');
end

experimentStructure.correlations.noise.allPairs = allPairs;
experimentStructure.correlations.noise.pairDistance = pairDistance;
experimentStructure.correlations.noise.pairwiseCellId = pairwiseCellId;
experimentStructure.correlations.noise.corrNoiseMatrix = corrNoiseMatrix;

%% band the correlation coeffs by distance, cell type etc

if plotFlag == 1
    distanceBands = [0:50:450];
    
    for q = 1:length(distanceBands)-1
        
        pairs2Include = pairDistance > distanceBands(q) & pairDistance <= distanceBands(q+1);
        coeffALLMean(q) = nanmean(corrNoiseMatrix(pairs2Include));
        coeffAllSEM(q) =  std(corrNoiseMatrix(pairs2Include),'omitnan')/sqrt(length(corrNoiseMatrix(pairs2Include)));
        
    end
    
    
    pairDistanceNonPV = pairDistance(pairwiseCellId == 0);
    corrMatrixNonPV = corrNoiseMatrix(pairwiseCellId == 0);
    for q = 1:length(distanceBands)-1
        
        pairs2Include = pairDistanceNonPV > distanceBands(q) & pairDistanceNonPV <= distanceBands(q+1);
        coeffNonPVMean(q) = nanmean(corrMatrixNonPV(pairs2Include));
        coeffNonPVSEM(q) =  std(corrMatrixNonPV(pairs2Include),'omitnan')/sqrt(length(corrMatrixNonPV(pairs2Include)));
        
    end
    
    pairDistanceNonPV_PV = pairDistance(pairwiseCellId == 1);
    corrMatrixNonPV_PV = corrNoiseMatrix(pairwiseCellId == 1);
    for q = 1:length(distanceBands)-1
        
        pairs2Include = pairDistanceNonPV_PV > distanceBands(q) & pairDistanceNonPV_PV <= distanceBands(q+1);
        coeffNonPV_PVMean(q) = nanmean(corrMatrixNonPV_PV(pairs2Include));
        coeffNonPV_PVSEM(q) =  std(corrMatrixNonPV_PV(pairs2Include),'omitnan')/sqrt(length(corrMatrixNonPV_PV(pairs2Include)));
        
    end
    
    pairDistancePV = pairDistance(pairwiseCellId == 2);
    corrMatrixPV = corrNoiseMatrix(pairwiseCellId == 2);
    for q = 1:length(distanceBands)-1
        
        pairs2Include = pairDistancePV > distanceBands(q) & pairDistancePV <= distanceBands(q+1);
        coeffPVMean(q) = nanmean(corrMatrixPV(pairs2Include));
        coeffPVSEM(q) =  std(corrMatrixPV(pairs2Include),'omitnan')/sqrt(length(corrMatrixPV(pairs2Include)));
        
    end
    
    
    
    %% plot
    
    figHandle= figure('units','normalized','outerposition',[0 0 1 1]);
    title('Pairwise Neuron Correlations');
    shadedErrorBarV2(50:50:450,coeffALLMean,coeffAllSEM, 'lineProps',  'k', 'DisplayName', 'All Pairs');
    hold on
    
    shadedErrorBarV2(50:50:450,coeffNonPVMean,coeffNonPVSEM, 'lineProps',  'b',  'DisplayName', 'NonPV--NonPV');
    
    shadedErrorBarV2(50:50:450,coeffNonPV_PVMean,coeffNonPV_PVSEM, 'lineProps',  'g' , 'DisplayName', 'NonPV--PV');
    
    shadedErrorBarV2(50:50:450,coeffPVMean,coeffPVSEM, 'lineProps',  'r',  'DisplayName', 'PV--PV');
    legend;
    
    xlim([0 450]);
    xlabel('Pairwise Distance (um)');
    ylabel('Pearson Correlation Coeff');
    
    tightfig;
    
    
    saveas(figHandle, [experimentStructure.savePath 'Pairwise Noise Correlations.tif']);
    close;
    
end

%% save stuff

save([experimentStructure.savePath '\experimentStructure.mat'], 'experimentStructure', '-v7.3');

end
