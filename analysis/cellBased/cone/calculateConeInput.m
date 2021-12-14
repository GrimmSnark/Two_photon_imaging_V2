function [ratioLM, ratioLMS, ModInd_LM, ModInd_S_LM, coneWeights] = calculateConeInput(experimentStructure, noOrientations, secondCndDimension, zScoreThreshold)
% calculates a variety of cone response ratios and weights for existing
% monkey orientation/cone isolating stimuli with have L M L+M S conditions
%
% Inputs:   experimentStructure - structure containng all the data for that
%                                 run
%
%          noOrientations - number of orientations tested in the experiment
%                           default = 6
%
%          secondCndDimension - number of conditions in the second
%                               dimension, e.g. colors tested, ie 1 for
%                               black/white, 4 monkey color paradigm, or
%                               number of spatial frequencies etc
%                               default = 1
%
%          zScoreThreshold - zscore response threshold for inclusion in
%                            analysis DEFAULT = no threshold
%
% Outputs:  ratioLM - ratio of L vs M input (max orientation responses)
%
%           ratioLMS - ratio of LM vs S input (max orientation responses)
%
%           ModInd_LM - modualtion index of L vs M (max orientation responses)
%
%           ModInd_LMS - modualtion index of LM vs S (max orientation responses)
%
%           coneWeights - structure containing normalized cone weights for
%                         L, M, S from Johnson et al 2004 "Cone Inputs in
%                         Macaque Primary Visual Cortex."
%                   
%                weight = LCD screen cone contrast corrected
%                weightRel = LCD screen cone contrast corrected relative
%                            weight
%
% USAGE:  [ratioLM, ratioLMS, ModInd_LM, ModInd_S_LM, coneWeights] = calculateConeInput(experimentStructure, 6, 4, []);
%% defaults

if nargin < 2 || isempty(noOrientations)
    noOrientations = 6;
end

if nargin < 3 || isempty(secondCndDimension)
    secondCndDimension = 4;
end

if nargin < 4 || isempty(zScoreThreshold)
    zScoreThreshold = [];
end

% cone contrasts for LCD screen
LConeCon = 28;
MConeCon = 28;
SConeCon = 80;


%% get data
data = cellfun(@mean,cellfun(@cell2mat,experimentStructure.dFstimWindowAverageFBS, 'Un', 0), 'Un', 0);

% checks if your inputs for condition numbers are correct
cndNo = noOrientations * secondCndDimension;
if cndNo~= length(experimentStructure.cndTotal)
    disp('Input wrong number of conditions, please fix!!');
    return
end

% limit to zscore theshold
if ~isempty(zScoreThreshold)
    data = data(experimentStructure.ZScore >= zScoreThreshold);
end

% split coditions into matrix by second dimension
condtionsBy2ndDim = reshape(1:cndNo,noOrientations, [])';

for cellNo = 1:length(data)
    count = 1;
    for colorCnd = [1 2 4]
        cndPrefPerColor(cellNo,count) =  max(data{cellNo}(condtionsBy2ndDim(colorCnd,:)));
        count = count+1;
    end
end

% calculate ratios and modulation indexes  for L vs M, LM vs S
ratioLM = cndPrefPerColor(:,1) ./cndPrefPerColor(:,2);
ratioLMS = cndPrefPerColor(:,3) ./ mean(cndPrefPerColor(:,1:2),2);

ModInd_LM = (cndPrefPerColor(:,1) - cndPrefPerColor(:,2))./ (cndPrefPerColor(:,1) +cndPrefPerColor(:,2));
ModInd_S_LM = (cndPrefPerColor(:,3) - mean(cndPrefPerColor(:,1:2),2))./ (cndPrefPerColor(:,3) + mean(cndPrefPerColor(:,1:2),2));

%% calculate cone weights see Johnson et al 2004

% absolute weights
weightL = cndPrefPerColor(:,1) / LConeCon;
weightM = cndPrefPerColor(:,2) / MConeCon;
weightS = cndPrefPerColor(:,2) / SConeCon;

% relative weights
sumWeights = weightL + weightM + weightS;

weightRel_L = weightL ./ sumWeights;
weightRel_M = weightM ./ sumWeights;
weightRel_S = weightS ./ sumWeights;


coneWeights.weightL = weightL;
coneWeights.weightM = weightM;
coneWeights.weightS = weightS;
coneWeights.weightRel_L = weightRel_L;
coneWeights.weightRel_M = weightRel_M;
coneWeights.weightRel_S = weightRel_S;

end