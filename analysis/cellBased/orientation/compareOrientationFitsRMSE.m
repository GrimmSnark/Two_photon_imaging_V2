function [pDM,usefulCmbs] = compareOrientationFitsRMSE(experimentStructure, noOrientations, angleMax, secondCndDimension)
% Compares orientation tuning fits for different cone color conditons to
% see if they can fit across cone conditions
%
% Inputs:   experimentStructure - structure containng all the data for that
%                                 run
%
%          noOrientations - number of orientations tested in the experiment
%                          ie 4/8 etc, default = 8
%
%          angleMax - 360 or 180 for the Max angle tested, default = 360
%
%          secondCndDimension - number of conditions in the second
%                               dimension, e.g. colors tested, ie 1 for
%                               black/white, 4 monkey color paradigm, or
%                               number of spatial frequencies etc
%                               default = 1
% 
% Outputs: pDM - Diebold-Mariano test significance value for all
%                comparisons (cell No x comparison No)
%                   x < 0.05 = different fit efficiency for the tuning
%                   curve
%                   
%                   x > 0.05 = similar fit properties for the comparisons
%
%          usefulCmbs - combination no X test pair for the fit 
%% set defaults
if nargin < 2 || isempty(noOrientations)
    noOrientations = 8;
end

if nargin < 3 || isempty(angleMax)
    angleMax = 360;
end

if nargin < 4 || isempty(secondCndDimension)
    secondCndDimension = 1;
end

%% get data
data = cellfun(@mean,cellfun(@cell2mat,experimentStructure.dFstimWindowAverageFBS, 'Un', 0), 'Un', 0);

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

for i = 1:experimentStructure.cellCount
    
    % gets mean data per condition
    currentData = data{i};
    try
        
        for scndDim = 1: secondCndDimension
            % get the fits per color cnd
            fits2Use(scndDim,:) = experimentStructure.OSIStruct{i, scndDim}.LSStruct.modelTrace;
            
            % get the mean data per color cnd, interpolated to the same size
            % as fit
            if  max(angles) > 180
                data2Compare(scndDim,:) = interp1(currentData(condtionsBy2ndDim(scndDim,:)),linspace(1,length(angles),360));
            else
                data2Compare(scndDim,:) = interp1(currentData(condtionsBy2ndDim(scndDim,:)),linspace(1,length(angles),180));
            end
        end
        
        % get all possible combinations
        selfCmbs = [1:secondCndDimension ;1:secondCndDimension]';
        possibleCombs = [selfCmbs; nchoosek(1: secondCndDimension, 2)];
        usefulCmbs = nchoosek(1: secondCndDimension, 2);
        
        % get the root mean square error for all fits against all color cnd
        % data
        for x = 1: length(possibleCombs)
            rmse(x) = sqrt(immse(data2Compare(possibleCombs(x,1),:), fits2Use(possibleCombs(x,2),:)));
            
            
%             errs(x,:) =  data2Compare(possibleCombs(x,1),:)- fits2Use(possibleCombs(x,2),:);
                        normValue = max(fits2Use(possibleCombs(x,2),:));
                        errs(x,:) =  (data2Compare(possibleCombs(x,1),:)/ normValue) - (fits2Use(possibleCombs(x,2),:)/normValue);
%             errs(x,:) =  (data2Compare(possibleCombs(x,1),:)/ max(data2Compare(possibleCombs(x,1),:))) - (fits2Use(possibleCombs(x,2),:)/max(fits2Use(possibleCombs(x,2),:)));
        end
        
        for cc = 1:length(possibleCombs)-secondCndDimension
            [DM(i,cc),pDM(i,cc)] = dmtest_modified(errs(cc,:)', errs(cc+secondCndDimension,:)');
        end
    catch
        
    end
end


end