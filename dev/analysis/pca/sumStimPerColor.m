function experimentStructure = sumStimPerColor(filepath, data2Use, secondCndDimension)
% Creates condition sum averages across the entire trial to be used with
% PCA analysis
%
% Inputs:  filepath - processed data folder containing the
%                     experimentStructure.mat, or the fullfile to the
%                     experimentStructure.mat
%
%          data2Use - specify the type of data to use
%                     FBS- first before stimulus subtraction (For LCS)
%                     Neuro_corr- Neuropil corrected based subtraction
%
%          secondCndDimension - number of conditions in the second
%                               dimension, e.g. colors tested, ie 1 for
%                               black/white, 4 monkey color paradigm, or
%                               number of spatial frequencies etc
%                               default = 1


%% Defaults

% gets the experimentStructure
if ~isobject(filepath)
    try
        load(filepath, '-mat');
        filePath2Use = dir(filepath);
        experimentStructure.savePath = [filePath2Use.folder '\'] ;
    catch
        load([filepath '\experimentStructure.mat']);
        experimentStructure.savePath = [filepath '\'];
    end
else % if variable is the experimentStructure
    experimentStructure = filepath;
    clearvars filepath
end

if nargin < 2 || isempty(data2Use)
    data2Use = 'FBS';
end

if nargin < 3 || isempty(secondCndDimension)
    secondCndDimension = 4;
end

%% Start calculations

% Get data

% get Data
switch data2Use
    
    case 'FBS'
        data = experimentStructure.dFperCndFBS;
        dataTag = 'FBS';
        
    case 'Neuro_corr'
        data = experimentStructure.dFperCnd;
        dataTag = '';
end
    

% get the sum per cnd
for p = 1:experimentStructure.cellCount % for each cell
    for  x =1:length(experimentStructure.cndTotal) % for each condition
        
        %full trial prestimON-trialEND cell cnd trial
        trialSum = sum(data{p}{x}(experimentStructure.stimOnFrames(1):experimentStructure.stimOnFrames(2),:),1); %chunks data and sorts into structure
        cndSumStd{p}(x) = std(trialSum);
        cndSumMean{p}(x) = mean(trialSum);
        cndSumSum{p}(x) = sum(trialSum);
    end
    
    %reshape into 2nd Dim x Orientations
    cndSumStd{p} = reshape(cndSumStd{p},[], secondCndDimension)';
    cndSumMean{p} = reshape(cndSumMean{p},[], secondCndDimension)';
    cndSumSum{p} = reshape(cndSumSum{p},[], secondCndDimension)';
end


eval(['experimentStructure.cndSumStd' dataTag ' = cndSumStd;']);
eval(['experimentStructure.cndSumMean' dataTag ' = cndSumMean;']);
eval(['experimentStructure.cndSumSum' dataTag ' = cndSumSum;']);


%% Save the updated experimentStructure
save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');

end