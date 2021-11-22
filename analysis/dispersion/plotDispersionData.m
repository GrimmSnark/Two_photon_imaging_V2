function plotDispersionData(data)

colorTraces = distinguishable_colors(size(data.zPostions,2));

figHandle = figure('units','normalized','outerposition',[0 0 1 1]);
hold on
for i = 1:size(data.zPostions,2)
   plot(data.zPostions(:,i), data.averageIntesityPer_mW(:,i), 'Color', colorTraces(i,:), 'lineWidth',3,  'DisplayName', ['Dispersion Value = ' num2str(data.dispersionVal(i))]);
    
end

hold off

ylabel('Intensity/mW');
xlabel('Depth in um');
title('Effect of dispersion at different depths');

tightfig;

legend();

saveas(figHandle, [data.saveLoc 'Dispersion_depth.tif']);
saveas(figHandle, [data.saveLoc 'Dispersion_depth.svg']);

close();
end
