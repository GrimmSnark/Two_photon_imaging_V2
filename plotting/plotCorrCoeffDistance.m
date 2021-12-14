function plotCorrCoeffDistance(figHandle,corrStruct, data2Use) 
% Plots correlation coeffs across distance for populations of data for both
% non PV and PV cell types in mouse for stimulus or noise data types
%
% Inputs: figHandle - figure/axis handle to place plot into
%
%         corrStruct- structure containing all correlation metrics
%                     for the popultion to plot
%
%         data2Use- 1/2 flag to choose whether to plot stimulus (1)
%                   or noise (2) correlations
%                   DEFAULT = 1 (stimulus correlations)
%%
if nargin < 3 || isempty(data2Use)
    data2Use = 1;
end

%% choose data
switch data2Use 
    case 1  % stimulus correlations
        pairDistance = corrStruct.pairDistance;
        corrMatrix = corrStruct.corrMatrix;
        pairwiseCellId = corrStruct.pairwiseCellId;
    case 2 % noise correlations
        pairDistance = corrStruct.pairDistance_Noise;
        corrMatrix = corrStruct.corrNoiseMatrix_Noise;
        pairwiseCellId = corrStruct.pairwiseCellId_Noise;
end


%% band the correlation coeffs by distance, cell type etc

distanceBands = [0:25:450];

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
shadedErrorBarV2(25:25:450,coeffALLMean,coeffAllSEM, 'lineProps',  'k', 'Axis', figHandle , 'DisplayName', 'All Pairs');
hold on

shadedErrorBarV2(25:25:450,coeffNonPVMean,coeffNonPVSEM, 'lineProps',  'cy',  'Axis', figHandle , 'DisplayName', 'NonPV--NonPV');

shadedErrorBarV2(25:25:450,coeffNonPV_PVMean,coeffNonPV_PVSEM, 'lineProps',  'g' , 'Axis', figHandle , 'DisplayName', 'NonPV--PV');

shadedErrorBarV2(25:25:451,coeffPVMean,coeffPVSEM, 'lineProps',  'r',  'Axis', figHandle , 'DisplayName', 'PV--PV');
legend;

xlim([0 450]);
xlabel('Pairwise Distance (um)');
ylabel('Pearson Correlation Coeff');

end

