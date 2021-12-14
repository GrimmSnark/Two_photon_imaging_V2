function [fitGrandStruct] = testOrientationFitsPerBlock(experimentStructure, cellNos, noOrientations, angleMax, secondCndDimension)
% Fits orientation tuning curves on each block of the orientation sets for
% each cell specified for each cone coniditon (cone condition number hard
% set for 4 colors
%
% Inputs:   experimentStructure - structure containng all the data for that
%                                 run
%
%          cellNos- number or vector of numbers for cells to test
%
%          noOrientations - number of orientations tested in the experiment
%                          ie 4/8 etc, default = 6
%
%          angleMax - 360 or 180 for the Max angle tested, default = 180
%
%          secondCndDimension - number of conditions in the second
%                               dimension, e.g. colors tested, ie 1 for
%                               black/white, 4 monkey color paradigm, or
%                               number of spatial frequencies etc
%                               default = 1
%
% Output: fitGrandStruct - Contains all the fits and metrics for all cells
%                          for each block of orientation
%                               cell no X color condition x block number
%
%           Fields - fitStruct - fit structure for each fit
%                    peaks - peak angle location
%                    width - tuning curve width

%% set defaults
if nargin < 3 || isempty(noOrientations)
    noOrientations = 6;
end

if nargin < 4 || isempty(angleMax)
    angleMax = 180;
end

if nargin < 5 || isempty(secondCndDimension)
    secondCndDimension = 4;
end

%%  get data

data = experimentStructure.dFstimWindowAverageFBS;

% checks if your inputs for condition numbers are correct
cndNo = noOrientations * secondCndDimension;
if cndNo~= length(experimentStructure.cndTotal)
    disp('Input wrong number of conditions, please fix!!');
    return
end

% split coditions into matrix by second dimension
condtionsBy2ndDim = reshape(1:cndNo,noOrientations, [])';

% get angle identities
angles = linspace(0, angleMax, noOrientations+1);
angles = angles(1:end-1);


%% start OSI calculations
% runs through each cell
    count = 1;
for i = cellNos
    count2 = 1;
    % for each color
    for c = [1 2 4]
        % for each block/orientation set
        for q = 1: size(experimentStructure.dFstimWindowAverageFBS{i},1)
            data2Use = cell2mat(data{i}(q,condtionsBy2ndDim(c,:)));
            
            
            x = interp1([ data2Use data2Use(1)],linspace(1,length(data2Use)+1,19)); % wrap around first condition and interp to number required + 1
            x = x(1:18); % limit to 18 numbers, ie input for single guassian fit
            fitStruct = singleGaussianFit(x);
            
            fitGrandStruct.fitStruct(count,count2,q) =fitStruct;
            fitGrandStruct.peaks(count,count2,q) =fitStruct.Peak1Loc;
            fitGrandStruct.width(count,count2,q) =fitStruct.Peak1Width;
        end
        count2 = count2 +1;
    end
    count = count + 1;
end

end