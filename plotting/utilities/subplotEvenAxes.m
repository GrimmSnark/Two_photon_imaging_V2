function subplotEvenAxes(axH)
% Sets both X andf Y axes to be the same across an entire subplot image

%% check if the handle is a figure
if ishandle(axH) && findobj(axH,'type','figure')==axH
    axH = findall(axH,'type','axes');
end

%% Y axis
axYLim =  get(axH,'YLim');
maxY = max([axYLim{:}]);
minY = min([axYLim{:}]);
set(axH,'YLim',[minY maxY]);

%% X axis
axXLim =  get(axH,'XLim');
maxX = max([axXLim{:}]);
minX = min([axXLim{:}]);
set(axH,'XLim',[minX maxX]);

end