function [fitGrandStruct] = testOrientationFitsPerBlock(experimentStructure, cellNos, noOrientations, angleMax, secondCndDimension)

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
            
            x=interp1(data2Use,linspace(1,length(angles),18));
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