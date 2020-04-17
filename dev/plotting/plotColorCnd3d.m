function plotColorCnd3d(experimentStructure, cellNo, colorCnds, data2Use)


if nargin < 3 || isempty(colorCnds)
    colorCnds = [1 2 4];
end

if nargin < 4 || isempty(data2Use)
    data2Use = 'FBS';
end


data = eval(['experimentStructure.cndSumMean' data2Use]);
dataStd = eval(['experimentStructure.cndSumStd' data2Use]);


for i =cellNo %[2 38 69 86] %1:cellNumber
   
      figure('units','normalized','outerposition',[0 0 1 1]);
      subplot(121);
        data2Plot = data{i}(colorCnds,:);
%     data2Plot = [0.1 0.1 0.2; 0.9 0.4 0.7; 3.5 4.2 2.8; 0.4 0.3 0.1; 0.5 0.6 0.2; 0.1 0.3 0.2]'; % simple orientation selective
%         data2Plot = [0.1 0.1 0.2; 0.9 0.4 0.7; 3.5 4.2 2.8; 2.4 1.3 3.4; 0.5 0.6 0.2; 0.1 0.3 0.2]';

    [eigenvectors,score,latent, tsquared, explained, mu] = pca(data2Plot');
    
    
    scaledEigens = (eigenvectors .* [explained explained explained]')/50;
    shiftedEigens = mu' + scaledEigens;
    
    
%     dataStd2Plot = dataStd{i}(colorCnds,:);
    colors = ggb1;
    
    colorAssigments = round(linspace(1,length(colors),length(data2Plot)+1));
    scatter3(data2Plot(1,:),data2Plot(2,:), data2Plot(3,:),1000 , colors(colorAssigments(1:end-1),:), 'Marker', '.');
    hold on
%     
%        Q=Bezier(data2Plot,1:1000);
%     
%     plot3(Q(1,:)',Q(2,:)', Q(3,:)');
%     
    plot_dir3(data2Plot(1,:)',data2Plot(2,:)', data2Plot(3,:)');
    hold on
    cols = distinguishable_colors(3);
    % plot eigenvectors
    for q = 1:size(shiftedEigens,2)
     lineH(q) = line([mu(1) shiftedEigens(1,q)], [mu(2) shiftedEigens(2,q)], [mu(3) shiftedEigens(3,q)], 'LineWidth',2, 'Color', cols(q,:), 'DisplayName', ['PCA ' num2str(q)] );
    end
    
    legend(lineH);
%     ax = gca;
%     hold on
%     for x = 1:length(data2Plot)
%         [xEp, yEp, zEp] = ellipsoid(data2Plot(1,x),data2Plot(2,x), data2Plot(3,x), dataStd2Plot(1,x)/sqrt(experimentStructure.cndTotal(1)), dataStd2Plot(2,x)/sqrt(experimentStructure.cndTotal(1)), dataStd2Plot(3,x)/sqrt(experimentStructure.cndTotal(1)));
%         fill3(ax,xEp, yEp, zEp,colors(colorAssigments(x),:), 'FaceAlpha', 0.1);
%     end
    
    colormap(colors);
    colBar = colorbar;
    colBar.Ticks = colorAssigments/256;
    colBar.TickLabels = linspace(0, 180, 7);
    
    xlabel('L Cone');
    ylabel('M Cone');
    zlabel('S Cone');
    title(['Cell No: ' num2str(i)]);
    
    axesLim = axis(gca);
    maxAx = max(axesLim);
    minAx = min(axesLim);
    
    minLim = min([0 minAx]);
    axis([minLim maxAx minLim  maxAx minLim maxAx]);
    
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    set(gca,'Ydir','reverse')
    hold on
    
    rotate3d('on')
    
    hold all
    subplot(122);
    
    scatter3(score(:,1),score(:,2), score(:,3))
    xlabel('PCA 1');
    ylabel('PCA 2');
    zlabel('PCA 3');
    
end
end