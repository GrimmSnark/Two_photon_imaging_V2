function colMap = makeHues(startColor, noColors)

[val, maxInd] = max(startColor);
primaryCol = [0 0 0];
primaryCol(maxInd) =1;


colMap = [linspace(primaryCol(1),startColor(1),noColors)', linspace(primaryCol(2),startColor(2),noColors)', linspace(primaryCol(3),startColor(3),noColors)'];

end

