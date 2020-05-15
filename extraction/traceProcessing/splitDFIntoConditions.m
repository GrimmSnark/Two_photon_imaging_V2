function experimentStructure = splitDFIntoConditions(experimentStructure)
% Splits up the calcium imaging traces into conditions and makes prestim
% and stim window averages so that analysis is easier in future scripts
%
% Input- experimentStructure: structure containing all experiment info
%
% Output- experimentStructure: updated structure containing all experiment
%                              info


%% get trial length and stim on frame lengths
analysisFrameLength = round(mean(experimentStructure.EventFrameIndx.TRIAL_END - experimentStructure.EventFrameIndx.PRESTIM_ON));
stimOnFrames = [ceil(mean(experimentStructure.EventFrameIndx.STIM_ON - experimentStructure.EventFrameIndx.PRESTIM_ON))+1 ...
    ceil(mean(experimentStructure.EventFrameIndx.STIM_OFF - experimentStructure.EventFrameIndx.PRESTIM_ON))-1];

experimentStructure.meanFrameLength = analysisFrameLength; % saves the analysis frame length into structure, just FYI
experimentStructure.stimOnFrames = stimOnFrames; % saves the frame index for the trial at which stim on and off occured, ie [7 14] from prestim on

% clear any previous
experimentStructure.dFperCnd = [];
experimentStructure.dFperCndFBS = [];
experimentStructure.rawFperCnd = [];

%% chunks up dF into cell x cnd x trial
for p = 1:experimentStructure.cellCount % for each cell
    for  x =1:length(experimentStructure.cndTotal) % for each condition
        if any(experimentStructure.cndTotal(x)) % checks if there are any trials of that type
            for y =1:length(experimentStructure.cndTrials{x}) % for each trial of that type
                
                currentTrial = experimentStructure.cndTrials{x}(y); % gets current trial number for that cnd
                currentTrialFrameStart = experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial);
                
                %% DF/F Splits
                %full trial prestimON-trialEND cell cnd trial
                experimentStructure.dFperCnd{p}{x}(:,y) = experimentStructure.dF(p,currentTrialFrameStart:currentTrialFrameStart+ (analysisFrameLength-1)); %chunks data and sorts into structure
                
                % prestim response and average response per cell x cnd x trial
                experimentStructure.dFpreStimWindow{p}{y,x} = experimentStructure.dF(p,currentTrialFrameStart:experimentStructure.EventFrameIndx.PRESTIM_OFF(currentTrial)-1);
                
                % makes average of prestim window
                experimentStructure.dFpreStimWindowAverage{p}{y,x} = mean(experimentStructure.dFpreStimWindow{p}{y,x});
                
                % stim response and average response per cell x cnd x trial
                experimentStructure.dFstimWindow{p}{y,x} = experimentStructure.dF(p,experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_OFF(currentTrial));
                experimentStructure.dFstimWindowAverage{p}{y,x} = mean(experimentStructure.dFstimWindow{p}{y,x});
                
                %% First frame before stimulus subtraction (FBS) splits, does not require neuropil subraction etc
                % splits rawF into conditions/trials
                experimentStructure.rawFperCnd{p}{x}(:,y) = experimentStructure.rawF(p,currentTrialFrameStart:currentTrialFrameStart+ (analysisFrameLength-1)); %chunks data and sorts into structure
                
                % calulates per trial DF/F FBS
                rawFCurrentTrial = experimentStructure.rawF(p,currentTrialFrameStart:currentTrialFrameStart+ (analysisFrameLength-1)); % gets the raw trial
                rawFCurrentFrameBeforeStim = experimentStructure.rawF(p,currentTrialFrameStart+experimentStructure.stimOnFrames(1)-2); % get the FBS values
                experimentStructure.dFperCndFBS{p}{x}(:,y) = (rawFCurrentTrial - rawFCurrentFrameBeforeStim)/rawFCurrentFrameBeforeStim; %creates the trial dF/F for FBS
                
                % makes average of prestim window
                experimentStructure.dFpreStimWindowFBS{p}{y,x} =  experimentStructure.dFperCndFBS{p}{x}(1:experimentStructure.stimOnFrames(1)-1,y);
                experimentStructure.dFpreStimWindowAverageFBS{p}{y,x} = mean(experimentStructure.dFpreStimWindowFBS{p}{y,x});
                
                % stim response and average response per cell x cnd x trial
                experimentStructure.dFstimWindowFBS{p}{y,x} =  experimentStructure.dFperCndFBS{p}{x}(experimentStructure.stimOnFrames(1):experimentStructure.stimOnFrames(2),y);
                experimentStructure.dFstimWindowAverageFBS{p}{y,x} = mean(experimentStructure.dFstimWindowFBS{p}{y,x});
                
            end
        end
    end
end

%% sets up average traces per cnd and STDs
for i = 1:length(experimentStructure.dFperCnd) % for each cell
    for x = 1:length(experimentStructure.dFperCnd{i}) % for each condition
        %% dF/F
        experimentStructure.dFperCndMean{i}(:,x) = mean(experimentStructure.dFperCnd{i}{x}, 2); % means for each cell frame value x cnd
        experimentStructure.dFperCndSTD{i}(:,x) = std(experimentStructure.dFperCnd{i}{x}, [], 2); % std for each cell frame value x cnd
        
        %% First before Stimulus
        experimentStructure.dFperCndMeanFBS{i}(:,x) = mean(experimentStructure.dFperCndFBS{i}{x}, 2); % means for each cell frame value x cnd
        experimentStructure.dFperCndSTDFBS{i}(:,x) = std(experimentStructure.dFperCndFBS{i}{x}, [], 2); % std for each cell frame value x cnd
    end
end

%% Save the updated experimentStructure
save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');
end
