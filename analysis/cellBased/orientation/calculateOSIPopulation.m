function experimentStructure = calculateOSIPopulation(experimentStructure, noOrientations, angleMax, secondCndDimension, dataType)
% Calculates OSI metrics for each cell in an experiment
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
%          data2Use - specify the type of data to use
%                     FBS- first before stimulus subtraction (For LCS)
%                     Neuro_corr- Neuropil corrected based subtraction
%
% % Output: experimentStructure - structure containng all the data for that
%                                 run


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

if nargin <5
    dataType = 'FBS';
end

if isfield(experimentStructure, 'OSIStruct')
    experimentStructure = rmfield(experimentStructure, 'OSIStruct');
end

%% Get the appropriate data and make sure it is in correct format

switch dataType
    case 'FBS'
        data = experimentStructure.dFstimWindowAverageFBS;
        preStim = experimentStructure.dFpreStimWindowAverageFBS;
    case 'Neuro_corr'
        data = experimentStructure.dFstimWindowAverage;
        preStim = experimentStructure.dFpreStimWindowAverage;
end

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


%% Do Z Score of cell responsivity

% maxStimData = cellfun(@max,cellfun(@mean,cellfun(@cell2mat,data, 'Un', 0), 'Un', 0));
% prestimMean = cellfun(@mean,cellfun(@mean,cellfun(@cell2mat,preStim, 'Un', 0), 'Un', 0));
% prestimSD =cellfun(@std,cellfun(@mean,cellfun(@cell2mat,preStim, 'Un', 0), 'Un', 0));
% 
% experimentStructure.ZScore = (maxStimData' - prestimMean') ./prestimSD';

maxStimData = cellfun(@max,cellfun(@mean,cellfun(@cell2mat,data, 'Un', 0), 'Un', 0));
samplelength = experimentStructure.stimOnFrames(2)- experimentStructure.stimOnFrames(1);

cndTrials=[];
% unpack cndTrials
for vv = 1: length(experimentStructure.cndTrials)
   cndTrials = [cndTrials  experimentStructure.cndTrials{vv}];
end

maxTrialNo2Use = max(cndTrials);

% new prestim
for cellNo = 1:experimentStructure.cellCount
for qq = 2:maxTrialNo2Use
    % find appropriate cnd for previous trial
    out = cellfun(@(x)find(x(1,:) == qq-1),experimentStructure.cndTrials,'un',0);
    cnd2UsePrev = find(~cellfun(@isempty,out'));
    % find rep number of that condition prevous trial
    repNumberPrev = find(experimentStructure.cndTrials{cnd2UsePrev} == qq-1);
    trial2UsePrev = experimentStructure.dFperCndFBS{cellNo}{cnd2UsePrev}(:,repNumberPrev);
    indx2SamplePrev = samplelength- (experimentStructure.stimOnFrames(1)-2);
    
    % find appropriate cnd for current trial
    out = cellfun(@(x)find(x(1,:) == qq),experimentStructure.cndTrials,'un',0);
    cnd2Use = find(~cellfun(@isempty,out'));
    % find rep number of that condition prevous trial
    repNumber = find(experimentStructure.cndTrials{cnd2Use} == qq);
    trial2Use = experimentStructure.dFperCndFBS{cellNo}{cnd2Use}(:,repNumber);
    indx2Sample = experimentStructure.stimOnFrames(1)-3;
    
    preStimWrap(cellNo,qq-1,:) = [trial2UsePrev(end-indx2SamplePrev:end); trial2Use(1:indx2Sample)];
    
end
end

preStimMean = mean(preStimWrap,3);
preStimSD = std(preStimMean,[],2);
preStimMean2 = mean(preStimMean,2);

zscores = (maxStimData' - preStimMean2) ./preStimSD;

experimentStructure.ZScore = zscores;


%% start OSI calculations
% runs through each cell
for i = 1:experimentStructure.cellCount
        % gets mean data per condition
        
        % if any inf values changes to 0
        currentData = cell2mat(data{i});
        currentData(isnan(currentData)) = 0;
        currentData(isinf(currentData)) = 0;
        
        dataMean= mean(currentData); 
        dataSD = std(currentData);
        dataSEM = dataSD/sqrt(size(data{i},1));
        
        disp(['Calculating OSI for Cell No. ' num2str(i) ' of ' num2str(experimentStructure.cellCount)]);
        
        % for each of the second dimension conditions (eg color/SF levels etc)
        for x = 1: secondCndDimension
             currentMeans = dataMean(condtionsBy2ndDim(x,:));
             currentDataSD = dataSD(condtionsBy2ndDim(x,:));
             currentDataSEM = dataSEM(condtionsBy2ndDim(x,:));
            
             % LS and Priebe fit
             experimentStructure.OSIStruct{i,x} = calculateOSI(angles, currentMeans, currentDataSD, currentDataSEM);
        end
        
end

% save structure
save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure', '-v7.3');
end