function plotCorrCoeffDistanceHist(figHandle,corrStruct) 

%% filter the distances by pair type

distanceBands = [0:25:450];

% all cells
distancesAllCells = corrStruct.pairDistance;


% NonPV--NonPV pairs
distancesNonPVCells = distancesAllCells(corrStruct.pairwiseCellId == 0);

% NonPV--PV pairs
distancesNonPV_PVCells = distancesAllCells(corrStruct.pairwiseCellId == 1);

% PV--PV pairs
distancesPVCells = distancesAllCells(corrStruct.pairwiseCellId == 2);


%% plot

histogram(distancesAllCells,'BinWidth',10, 'BinLimits',[0,450], 'FaceColor', 'k', 'DisplayName', ['All Pairs (n=' num2str(length(distancesAllCells)) ')']);
hold on

histogram(distancesNonPVCells,'BinWidth',10, 'BinLimits',[0,450], 'FaceColor', 'cy', 'DisplayName', ['NonPV--NonPV  (n=' num2str(length(distancesNonPVCells)) ')'] );

histogram(distancesNonPV_PVCells,'BinWidth',10, 'BinLimits',[0,450], 'FaceColor', 'g', 'DisplayName',['NonPV--PV  (n=' num2str(length(distancesNonPV_PVCells)) ')']);

histogram(distancesPVCells,'BinWidth',10, 'BinLimits',[0,450], 'FaceColor', 'r', 'DisplayName', ['PV--PV  (n=' num2str(length(distancesPVCells)) ')']);

legend;

xlim([0 450]);
xlabel('Pairwise Distance (um)');
ylabel('Bin Count');

end

