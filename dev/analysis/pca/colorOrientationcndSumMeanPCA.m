function colorOrientationcndSumMeanPCA(experimentStructure, colorCnds, data2Use)


if nargin < 3 || isempty(colorCnds)
    colorCnds = [1 2 4];
end

if nargin < 4 || isempty(data2Use)
    data2Use = 'FBS';
end


%% fake data

% make data
numCells = 50;

% %orientation
% for i = 1:numCells
%     %     dataFake(:,:,i) = makeOrientationTunedData([0.1 0.3], [3.5 4.5],4);
% %    dataFake(:,:,i) = makeOrientationTunedData([0.1 0.6], [5 10],4);
%  dataFake(:,:,i) = makeOrientationColorModulatedData([0.1 0.3], [3.5 4.5], [1 3 6]);
% end
% 
% for q = 1:numCells
%     dataFake(:,:,i+q) = makeOrientationTunedData([0.1 0.3], [3.5 4.5],1);
% end
% 
% % color
% for w = 1:numCells
%     dataFake(:,:,i+q+w)= makeColorTunedData([0.1 0.3], [3.5 4.5],1);
% end
% 
% for t = 1:numCells
%     dataFake(:,:,i+q+w+t)= makeColorTunedData([0.1 0.3], [3.5 4.5],3);
% end

%orientation
for i = 1:numCells
 dataFake(:,:,i) = makeOrientationColorModulatedData([0.1 0.3], [3.5 4.5], [1 3 6]);
end

for q = 1:numCells
    dataFake(:,:,i+q) = makeOrientationColorModulatedData([0.1 0.3], [3.5 4.5],[1 0 0]);
end

% color
for w = 1:numCells
    dataFake(:,:,i+q+w)= makeOrientationColorModulatedData([0.1 0.3], [3.5 4.5],[0 3 0]);
end

for t = 1:numCells
    dataFake(:,:,i+q+w+t)= makeOrientationColorModulatedData([0.1 0.3], [3.5 4.5],[0 0 6]);
end



% % unroll data into 2D array
dataUnrolledFake = reshape(dataFake,[],size(dataFake,3))';

colorGroups = [1 0 0; 0 1 0; 0 0 1; 0 0 0];
repColors = repmat(colorGroups,1,1,numCells);
repColorsArr = reshape(permute(repColors, [3 1 2]),[],3);

[eigenvectorsF,scoreF,latentF, tsquaredF, explainedF, muF] = pca(dataUnrolledFake);
% [eigenvectorsF,scoreF,latentF, tsquaredF, explainedF, muF] = pca(dataUnrolledFake, 'Centered', false);


fakeFig = figure('units','normalized','outerposition',[0 0 1 1]);
% suptitle('Red = Color__Orientation   Green = Ori   Blue = Color 1   Black = Color 2');
suptitle('Red = Color__Orientation   Green = Ori 1 Col 1  Blue = Ori 3 Col 2   Black = Ori 6 Col 3');
subplot(3,2,1:2:6)

scatHandle =  scatter3(scoreF(:,1)', scoreF(:,2)',scoreF(:,3)', [], repColorsArr);
xlabel('PCA 1');
ylabel('PCA 2');
zlabel('PCA 3');

ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
axis equal
axesLim = axis(gca);
hold on

% x plane
vX = [0 axesLim(3) axesLim(5);  0 axesLim(4) axesLim(5); 0 axesLim(4) axesLim(6) ; 0 axesLim(3) axesLim(6) ];
fX = [1 2 3 4];
patch('Faces',fX,'Vertices',vX,'FaceColor','k', 'FaceAlpha', 0.1)

% y plane
vY = [axesLim(1) 0 axesLim(5); axesLim(2)  0 axesLim(5); axesLim(2) 0 axesLim(6) ; axesLim(1) 0 axesLim(6) ];
fY = [1 2 3 4];
patch('Faces',fY,'Vertices',vY,'FaceColor','k', 'FaceAlpha', 0.1)

% z plane
vZ = [axesLim(1) axesLim(3) 0 ; axesLim(2)  axesLim(3) 0 ; axesLim(2)  axesLim(4) 0  ; axesLim(1)  axesLim(4) 0  ];
fZ = [1 2 3 4];
patch('Faces',fZ,'Vertices',vZ,'FaceColor','k', 'FaceAlpha', 0.1)

% x y
subplot(3,2,2);
hXY = scatter(scoreF(:,1)', scoreF(:,2)', [], repColorsArr);
xlabel('PCA 1');
ylabel('PCA 2');
axis equal

vline(0)
hline(0)

% x z
subplot(3,2,4);
hXZ = scatter(scoreF(:,1)', scoreF(:,3)', [], repColorsArr);
xlabel('PCA 1');
ylabel('PCA 3');
axis equal

vline(0)
hline(0)


% y z
subplot(3,2,6);
hYZ = scatter(scoreF(:,2)', scoreF(:,3)', [], repColorsArr);
xlabel('PCA 2');
ylabel('PCA 3');
axis equal

vline(0)
hline(0)

figure
plot(1:length(latentF), latentF, '-o');
ylabel('Eignenvalues');
xlabel('PCA Component No');


eigenvectorsShiftedF = eigenvectorsF + muF;
% eigenvectorsShiftedScaledF = eigenvectorsShiftedF .* repmat(latentF', 18,1);
% eigenVectors3DF = reshape(eigenvectorsShiftedScaledF, 3,6, []);

 eigenVectors3DF = reshape(eigenvectorsShiftedF, 3,6, []);
%  eigenVectors3DF = reshape(eigenvectorsF, 3,6, []);

% eigenvectorsFOrtoNorm = inv(diag(std(dataUnrolledFake)))*eigenvectorsF;
% eigenVectors3DF = reshape(eigenvectorsFOrtoNorm, 3,6, []);


figH = figure('units','normalized','outerposition',[0 0 1 1]);

noEigns2Plot = 3;
cols = distinguishable_colors(noEigns2Plot);
% plot eigenvectors
for q = 1:noEigns2Plot
    lineH(q) = plot3(gca, eigenVectors3DF(1,:,q), eigenVectors3DF(2,:,q), eigenVectors3DF(3,:,q), 'Color', cols(q,:), 'DisplayName', ['PCA ' num2str(q)]);
    %     plot3(eigenVectors3D(:,1,q), eigenVectors3D(:,2,q), eigenVectors3D(:,3,q), 'Color', cols(q,:));
    hold on
end
legend

grid on
axesLim = axis(gca);
maxAx = max(axesLim);
minAx = min(axesLim);

minLim = min([0 minAx]);
axis([minLim maxAx minLim  maxAx minLim maxAx]);



%% real data


data = eval(['experimentStructure.cndSumMean' data2Use]);

% % unroll data into 2D array
dataMat = cat(3,data{:});
dataMat = dataMat(colorCnds,:,:);
dataUnrolled = reshape(dataMat,[],size(dataMat,3))';

% [eigenvectors,score,latent, tsquared, explained, mu] = pca(dataUnrolled);
[eigenvectors,score,latent, tsquared, explained, mu] = pca(dataUnrolled, 'Centered', false);

realFig = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(3,2,1:2:6)
scatHandle =  scatter3(score(:,1)', score(:,2)',score(:,3)');
xlabel('PCA 1');
ylabel('PCA 2');
zlabel('PCA 3');

ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
axis equal
axesLim = axis(gca);
hold on

% x plane
vX = [0 axesLim(3) axesLim(5);  0 axesLim(4) axesLim(5); 0 axesLim(4) axesLim(6) ; 0 axesLim(3) axesLim(6) ];
fX = [1 2 3 4];
patch('Faces',fX,'Vertices',vX,'FaceColor','k', 'FaceAlpha', 0.1)

% y plane
vY = [axesLim(1) 0 axesLim(5); axesLim(2)  0 axesLim(5); axesLim(2) 0 axesLim(6) ; axesLim(1) 0 axesLim(6) ];
fY = [1 2 3 4];
patch('Faces',fY,'Vertices',vY,'FaceColor','k', 'FaceAlpha', 0.1)

% z plane
vZ = [axesLim(1) axesLim(3) 0 ; axesLim(2)  axesLim(3) 0 ; axesLim(2)  axesLim(4) 0  ; axesLim(1)  axesLim(4) 0  ];
fZ = [1 2 3 4];
patch('Faces',fZ,'Vertices',vZ,'FaceColor','k', 'FaceAlpha', 0.1)


% legend([1, 51, 101, 151],{'Orientation 1','Orientation 2', 'Color 1', 'Color 2'})

row = dataTipTextRow('Cell No', 1:experimentStructure.cellCount);
scatHandle.DataTipTemplate.DataTipRows(end+1) = row;

% x y
subplot(3,2,2);
hXY = scatter(score(:,1)', score(:,2)');
xlabel('PCA 1');
ylabel('PCA 2');
axis equal

vline(0)
hline(0)

row = dataTipTextRow('Cell No', 1:experimentStructure.cellCount);
hXY.DataTipTemplate.DataTipRows(end+1) = row;

% x z
subplot(3,2,4);
hXZ = scatter(score(:,1)', score(:,3)');
xlabel('PCA 1');
ylabel('PCA 3');
axis equal

vline(0)
hline(0)

row = dataTipTextRow('Cell No', 1:experimentStructure.cellCount);
hXZ.DataTipTemplate.DataTipRows(end+1) = row;


% y z
subplot(3,2,6);
hYZ = scatter(score(:,2)', score(:,3)');
xlabel('PCA 2');
ylabel('PCA 3');
axis equal

vline(0)
hline(0)

row = dataTipTextRow('Cell No', 1:experimentStructure.cellCount);
hYZ.DataTipTemplate.DataTipRows(end+1) = row;




saveas(fakeFig, [experimentStructure.savePath 'PCA_fake.tif']);

saveas(realFig, [experimentStructure.savePath 'PCA_real.tif']);


figure;

plot(1:length(latent),latent, '-o');
ylabel('Eigenvalue' );
xlabel('PCA Component No');

% eigenvectorsShifted = eigenvectors + mu';
% eigenVectors3D = reshape(eigenvectorsShifted, 3,6, []);
eigenVectors3D = reshape(eigenvectors, 3,6, []);
figure
cols = distinguishable_colors(3);
% plot eigenvectors
for q = 1:3
    plot3(eigenVectors3D(1,:,q), eigenVectors3D(2,:,q), eigenVectors3D(3,:,q), 'Color', cols(q,:), 'DisplayName', ['PCA ' num2str(q)]);
    %     plot3(eigenVectors3D(:,1,q), eigenVectors3D(:,2,q), eigenVectors3D(:,3,q), 'Color', cols(q,:));
    hold on
end
grid on
legend


end