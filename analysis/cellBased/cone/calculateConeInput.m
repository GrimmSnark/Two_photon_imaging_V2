function [ratioLM, ratioLMS, ModInd_LM, ModInd_S_LM, coneWeights] = calculateConeInput(experimentStructure, noOrientations, secondCndDimension, zScoreThreshold)


%% defaults
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