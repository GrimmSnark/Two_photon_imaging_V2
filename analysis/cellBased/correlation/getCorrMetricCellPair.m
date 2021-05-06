function corrMetrics = getCorrMetricCellPair(experimentStructure, cellPairs)
% Function grabs the correlation netrics for a list of cell pairs
%
% Inputs: experimentStructure- structure containing all experimental data
%         cellPairs - array m X 2 of cell pairs
%
% Outputs: corrMetrics - structure containig fields
%                                  cellPairs - array m X 2 of cell pairs
%                                  corr - signal/noise correlation
%                                  distance - euclidian distance between
%                                             cell pair


corrMetrics.cellPairs = cellPairs;

for i = 1:size(cellPairs,1)
    % find correlation pair indices
    
    % signal
    indxSignalA = findfirst(experimentStructure.correlations.allPairs(:,1) == cellPairs(i,1), 1,100000);
    indxSignalB = findfirst(experimentStructure.correlations.allPairs(:,2) == cellPairs(i,2), 1,100000);
    
    indexSignal = intersect(indxSignalA,indxSignalB);  
    indexSignal = indexSignal(2);
    
    % get distance between pairs
    corrMetrics.distance(i) = experimentStructure.correlations.pairDistance(indexSignal);
    
%     experimentStructure.correlations.allPairs(indexSignal,:)
    
    % noise
    indxNoiseA  =  findfirst(experimentStructure.correlations.noise.allPairs == cellPairs(i,1), 1, 100000);
    indxNoiseB  =  findfirst(experimentStructure.correlations.noise.allPairs == cellPairs(i,2), 1, 100000);
    
    indexNoise = intersect(indxNoiseA,indxNoiseB);  
    indexNoise = indexNoise(2);
    
   corrMetrics.corr(i,1) = experimentStructure.correlations.corrMatrix(indexSignal);
   corrMetrics.corr(i,2) = experimentStructure.correlations.noise.corrNoiseMatrix(indexNoise);
end