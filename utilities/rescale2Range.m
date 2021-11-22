function dataRescaled = rescale2Range(data, limits)
% rescaled data in range specified so that they do not cut off data points
% limits are DEFAULT [0 1]
% outputs rescaled data between 0 1

if nargin < 2 || isempty(limits)
   limits = [0 1]; 
end

% get size and number of dimensions
dataSz = size(data);
dataNdim = ndims(data);

% add dimensions with have the limit numbers in to maintain the rescale
% properly

% create lower and upper limit mats
lowerLimMat = zeros(dataSz)+limits(1);
upperLimMat = zeros(dataSz)+limits(2);

% add them to data matrix
dataMod = cat(dataNdim+1, data, lowerLimMat);
dataMod = cat(dataNdim+1, dataMod, upperLimMat);

% rescale
dataModRescale = rescale(dataMod);

% get indexs of orginal data to extract
C = repmat({':'},1,dataNdim);

% extract original data
dataRescaled = dataModRescale(C{:},1);

end