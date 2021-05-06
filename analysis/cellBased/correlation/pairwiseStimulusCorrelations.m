function pairwiseStimulusCorrelations(experimentStructure, cnd2Use)




% extract the data from expeimentStructure
for i = 1:experimentStructure.cellCount
responseMat(i,:,:) = cell2mat(experimentStructure.dFstimWindowAverageFBS{1,i});
end

responseMat = squeeze(mean(responseMat,2));

% limit to useful conditions, ie full contrast
responseMat = responseMat(:,cnd2Use);

% check cells are valid, ie have responses in the chosen conditions
invalidCells = logical(sum(isnan(responseMat),2));

% get XY locations
cellXY = [experimentStructure.xPos experimentStructure.yPos];

% get cell overlap
cellIdentity = experimentStructure.ChannelOverlap;

% remove invalid cells
responseMat(invalidCells,:) = [];
cellXY(invalidCells,:) = [];
cellIdentity(invalidCells,:) = [];

%% run through all possible pairs

allPairs = nchoosek(1:length(responseMat),2);
for x = 1:length(allPairs)
    
    A = allPairs(x,1);
    B = allPairs(x,2);
    
    responseA = responseMat(A,:);
    responseB = responseMat(B,:);
    
    corrC = corrcoef(responseA,responseB);
    corrMatrix(x) = corrC(1,2);
    
    pairDistance(x) = pdist([cellXY(A,:); cellXY(B,:)],'euclidean');
    
    pairwiseCellId(x) = cellIdentity(A) + cellIdentity(B);
    
end

if ~isprop(experimentStructure,'correlations')
    experimentStructure.addprop('correlations');
end

experimentStructure.correlations.allPairs = allPairs;
experimentStructure.correlations.corrMatrix = corrMatrix;
experimentStructure.correlations.pairDistance = pairDistance;
experimentStructure.correlations.pairwiseCellId = pairwiseCellId;

%% band the correlation coeffs by distance, cell type etc

distanceBands = [0:50:450];

for q = 1:length(distanceBands)-1
    
    pairs2Include = pairDistance > distanceBands(q) & pairDistance <= distanceBands(q+1);
    coeffALLMean(q) = nanmean(corrMatrix(pairs2Include));
    coeffAllSEM(q) =  std(corrMatrix(pairs2Include),'omitnan')/sqrt(length(corrMatrix(pairs2Include)));
    
end


pairDistanceNonPV = pairDistance(pairwiseCellId == 0);
corrMatrixNonPV = corrMatrix(pairwiseCellId == 0);
for q = 1:length(distanceBands)-1
    
    pairs2Include = pairDistanceNonPV > distanceBands(q) & pairDistanceNonPV <= distanceBands(q+1);
    coeffNonPVMean(q) = nanmean(corrMatrixNonPV(pairs2Include));
    coeffNonPVSEM(q) =  std(corrMatrixNonPV(pairs2Include),'omitnan')/sqrt(length(corrMatrixNonPV(pairs2Include)));
    
end

pairDistanceNonPV_PV = pairDistance(pairwiseCellId == 1);
corrMatrixNonPV_PV = corrMatrix(pairwiseCellId == 1);
for q = 1:length(distanceBands)-1
    
    pairs2Include = pairDistanceNonPV_PV > distanceBands(q) & pairDistanceNonPV_PV <= distanceBands(q+1);
    coeffNonPV_PVMean(q) = nanmean(corrMatrixNonPV_PV(pairs2Include));
    coeffNonPV_PVSEM(q) =  std(corrMatrixNonPV_PV(pairs2Include),'omitnan')/sqrt(length(corrMatrixNonPV_PV(pairs2Include)));
    
end

pairDistancePV = pairDistance(pairwiseCellId == 2);
corrMatrixPV = corrMatrix(pairwiseCellId == 2);
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


%% save stuff

saveas(figHandle, [experimentStructure.savePath 'Pairwise Correlations.tif']);
close;

save([experimentStructure.savePath '\experimentStructure.mat'], 'experimentStructure', '-v7.3');

end
