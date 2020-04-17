function colorOrientationPCAAgainstCells(experimentStructure, cellNo, colorCnds, data2Use)


if nargin < 3 || isempty(colorCnds)
    colorCnds = [1 2 4];
end

if nargin < 4 || isempty(data2Use)
    data2Use = 'FBS';
end


%% real data
data = eval(['experimentStructure.cndSumMean' data2Use]);

% % unroll data into 2D array
dataMat = cat(3,data{:});
dataMat = dataMat(colorCnds,:,:);
dataUnrolled = reshape(dataMat,[],size(dataMat,3))';


[eigenvectors,score,latent, tsquared, explained, mu] = pca(dataUnrolled);

figH = figure('units','normalized','outerposition',[0 0 1 1]);
figAx = gca;

for i =cellNo
    data2Plot = dataMat(:,:,i);
    
    colors = ggb1;
    
    colorAssigments = round(linspace(1,length(colors),length(data2Plot)+1));
    scatter3(figAx,data2Plot(1,:),data2Plot(2,:), data2Plot(3,:),1000 , colors(colorAssigments(1:end-1),:), 'Marker', '.');
    hold on
    
    plot_dir3(data2Plot(1,:)',data2Plot(2,:)', data2Plot(3,:)');
    hold on
end

shiftedEigens = eigenvectors + mu;
%  shiftedEigens = (shiftedEigens * repmat(explained', 18,1))/100;
eigenVectors3D = reshape(shiftedEigens, 3,6, []);

cols = distinguishable_colors(3);
% plot eigenvectors
for q = 1:3
    lineH(q) = plot3(eigenVectors3D(1,:,q), eigenVectors3D(2,:,q), eigenVectors3D(3,:,q), 'LineWidth',2, 'Color', cols(q,:), 'DisplayName', ['PCA ' num2str(q)] );
end

title(['Cell No: ' num2str(cellNo)]);

legend(lineH)
colormap(colors);
colBar = colorbar;
colBar.Ticks = colorAssigments/256;
colBar.TickLabels = linspace(0, 180, 7);

xlabel('L Cone');
ylabel('M Cone');
zlabel('S Cone');

axesLim = axis(gca);
maxAx = max(axesLim);
minAx = min(axesLim);

minLim = min([0 minAx]);
axis([minLim maxAx minLim  maxAx minLim maxAx]);

saveas(figH, [experimentStructure.savePath 'PCA_Cells ' num2str(cellNo) '.tif']);

end
