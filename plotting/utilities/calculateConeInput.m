function [ratioLM, ratioLMS] = calculateConeInput(cndAverages, orientationNo, colorNo)

[value, preferredStimulus] = max(cndAverages);

[prefOrientation, prefColor] = ind2sub([orientationNo colorNo],preferredStimulus);

indxM = sub2ind([orientationNo colorNo],prefOrientation,2);
indxLM = sub2ind([orientationNo colorNo],prefOrientation,3);
indxS = sub2ind([orientationNo colorNo],prefOrientation,4);

ratioLM = cndAverages(prefOrientation)/(cndAverages(prefOrientation)+cndAverages(indxM));
ratioLMS = cndAverages(indxS)/(cndAverages(indxS)+cndAverages(indxLM));

end