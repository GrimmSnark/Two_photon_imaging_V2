function [indxOfSquares] = randDistributeSquares(gridSize, minAllowableDistance,maxNumPoints, indxOfSquaresPrev)
% created for making sparse noise stimulus....

% gridSize = [15 28];
% minAllowableDistance = 5;
% maxNumPoints = 12;

x = randi([1 gridSize(2)], [1 1000]);
y = randi([1 gridSize(1)], [1 1000]);
topIdxs =1;
maxIteration = 10000;
breaks = 0;

if ~isempty(indxOfSquaresPrev)
    indexOfStim = unique(indxOfSquaresPrev);
    totalStims = [indexOfStim,histc(indxOfSquaresPrev(:),indexOfStim)];
    currentMaxTotal = max(max(totalStims(:,2), [], 2));
    indexToFind = find(totalStims==currentMaxTotal)- length(totalStims);
    indexToFind = indexToFind(indexToFind>=0);
    topIdxs = totalStims(indexToFind);
end


% Initialize first point.
plottedX = x(1);
plottedY = y(1);
% Try dropping down more points.
counter = 1;
numberPoints =1;

while numberPoints ~=maxNumPoints +1
    counter = counter+1;
    currentX = randi([1 gridSize(2)], [1 1]);
    currentY = randi([1 gridSize(1)], [1 1]);
    
    if sub2ind(gridSize, currentY, currentX) ~= topIdxs
        distances = sqrt((currentX-plottedX).^2 + (currentY - plottedY).^2);
        
        minDistance = min(distances);
        if minDistance >= minAllowableDistance
            plottedX(numberPoints) = currentX;
            plottedY(numberPoints) = currentY;
            numberPoints  = numberPoints +1;
        end
    else
        disp('Kicked');
        
        if counter >= maxIteration
            breaks = breaks +1;
            currentX = randi([1 gridSize(2)], [1 1]);
            currentY = randi([1 gridSize(1)], [1 1]);
            distances = sqrt((currentX-plottedX).^2 + (currentY - plottedY).^2);
            
            minDistance = min(distances);
            if minDistance >= minAllowableDistance
                plottedX(numberPoints) = currentX;
                plottedY(numberPoints) = currentY;
                numberPoints  = numberPoints +1;
            end
            
        end
    end
end

indxOfSquares = sub2ind(gridSize, plottedY, plottedX);
[posY, posX] = ind2sub(gridSize, indxOfSquares);

plot(plottedX, plottedY, 'b*');
grid on;

end
