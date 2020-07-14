function experimentStructure = prepTrialData(experimentStructure)
% Reads in trial data into experimentStructure and aligns events to frames
% This function has a lot of event error checking and compensation
%
% Inputs- experimentStructure: structure containing experiment data
%
% Output- experimentStructure: updated experimentStructure
%

%% initalise stuff

codes = prairieCodes();
sizeIndMax =0;
rawTrials = [];

essentialEvents ={'TRIAL_START', 'PARAM_START', 'PARAM_END', 'TRIAL_END'}; %list of essential events for valid trial
essentialEventsNum = stringEvent2Num(essentialEvents, codes);


eventArray = readEventFilePrairie(experimentStructure.prairiePathVoltage, []); % read in events file

%% if path to PTB file is set check consistency between set and recorded events
PTBPath = dir([experimentStructure.prairiePath '*.mat']);

% find index of stimParams mat
indexCell = strfind({PTBPath.name}, 'stimParams');
indexOfStimParams = find(~cellfun(@isempty,indexCell));

% copy stimParams to experimentStructure
if ~isempty(indexOfStimParams)
    load(fullfile(PTBPath(indexOfStimParams).folder, PTBPath(indexOfStimParams).name));
    experimentStructure.stimParams = stimParams;
end
% clear entry
PTBPath(indexOfStimParams) = [];

if ~isempty(PTBPath)
    experimentStructure.PTB_TimingFilePath = [PTBPath.folder '\' PTBPath.name ];
    [eventArray, PTBeventArray ]= checkConsistencyPrairie2PTB(eventArray, experimentStructure.PTB_TimingFilePath);
end

%% Proceed with trial event segementation
eventStream = eventArray;

% use trial end events to chunk up into individual trials
endIndx = findEvents('TRIAL_END', eventStream, codes); % get trial end event times
rawTrials  = cell([length(endIndx),1]);

%% splits up raw trial events
for i =1:length(endIndx)
    if i==1
        rawTrials{i,1} = eventStream(1:endIndx(i),:);
    else
        rawTrials{i,1} = eventStream(endIndx(i-1)+1:endIndx(i),:);
    end
end

%% check trial has all the codes for a valid trial
for k = 1:numel(rawTrials)
    numOfEssentialEvents(k) = recursiveSum((rawTrials{k}(:,2) == essentialEventsNum));
end

validTrial = numOfEssentialEvents==length(essentialEventsNum); % indx of valid trial by event inclusion

disp([num2str(sum(validTrial)) ' / '  num2str(length(validTrial)) ' trials have valid condition codes!!!']);

%% extract stimulus conditions for each valid trial

block = zeros(length(validTrial),2);
cnd = block;

nonEssentialCodes = zeros(max(cellfun('size', rawTrials, 1)),2,length(validTrial));

paramStartPosition = find(PTBeventArray ==stringEvent2Num('PARAM_START', codes));
for i =1:length(validTrial)
    
    % grab cnd/ event identity from PTB codes
    paramStartIndx = find(rawTrials{i}(:,2) == stringEvent2Num('PARAM_START', codes)); % get the indx for param start in eventArray
    rawTrials{i}(paramStartIndx+1,2) = PTBeventArray(paramStartPosition(i)+1); % set the block (param start +1) to PTB block code
    rawTrials{i}(paramStartIndx+2,2) = PTBeventArray(paramStartPosition(i)+2); % set the condition (param start +2) to PTB condition code
    
    block(i,:) = rawTrials{i}(findEvents('PARAM_START',rawTrials{i,1},codes)+1,:); % finds block num and timestamp for all valid trials
    cnd(i,:) = rawTrials{i}(findEvents('PARAM_START',rawTrials{i,1},codes)+2,:); % finds condition num and timestamp for all valid trials
    
    % if there are more than 2 events between param start and end then get
    % rid of the duplicate
    paramStartEndDiff = findEvents('PARAM_END',rawTrials{i},codes)-paramStartIndx;
    
    if paramStartEndDiff > 3
        rawTrials{i}(findEvents('PARAM_END',rawTrials{i},codes)-1,:) = [];
    end
    
    nonEssentialIndStart = findEvents('PARAM_END',rawTrials{i},codes)+1; % gets the index for the event just after PARAM_END
    
    % if can not find param end postion in raw trials uses the PTB event
    % array
    if isempty(nonEssentialIndStart)
        nonEssentialIndStart = paramStartPosition(i)+4 - (paramStartPosition(i)-2); % set relative event index number after param end for this trial...
    end
    
    nonEssentialIndEnd = findEvents('TRIAL_END',rawTrials{i},codes); % gets the index for TRIAL_END
    
    sizeInd = nonEssentialIndEnd-nonEssentialIndStart+1; % gets length of vector to come
    
    if sizeInd>sizeIndMax % max vector length across trials
        sizeIndMax = sizeInd;
    end
    nonEssentialCodes(1:sizeInd,:,i) = rawTrials{i}(nonEssentialIndStart:nonEssentialIndEnd,:); % gets all the non essential trial events into an array
end

% get total number of each condition presented
cndTotal = zeros(max(cnd(:,2)),1);
for i=1:max(cnd(:,2))
    cndTotal(i) = length(cnd(cnd(:,2)==i,2));
end

%% move onto non essential events
% get timestamps and lists for all during trial events (ie after
% PARAM_END
nonEssentialEventNumbers = unique(nonEssentialCodes(:,2,:));

% remove zeros and any not used events.... this may cause errors if you
% do not keep prairieCodes.m updated  with any changes in event usage
nonEssentialEventNumbers(nonEssentialEventNumbers ==0) = [];

% check if events are used in experiment at all
checkEventUsage = false(length(nonEssentialEventNumbers),1);
for x = 1:length(nonEssentialEventNumbers)
    if ~isempty(codes{nonEssentialEventNumbers(x)})
        checkEventUsage(x) = true;
    end
end
nonEssentialEventNumbers = nonEssentialEventNumbers(checkEventUsage);

% for each non essential event
for i =1:length(nonEssentialEventNumbers)
    nonEssentialEvent{1,i}= codes{nonEssentialEventNumbers(i)};
    
    indexOfCodes = nonEssentialCodes == (nonEssentialEventNumbers(i));
    indexOfTimes = circshift(indexOfCodes,-1,2);
    indexOfBoth= logical(indexOfCodes+indexOfTimes);
    
    
    try
        nonEssentialEvent{2,i}= reshape(nonEssentialCodes(indexOfBoth),[],2,size(nonEssentialCodes,3)); % if all goes well reshapes array
    catch
        %% If there are mismatched number of events across trials try to fix
        
        disp('Trying to fix irrational event timing issues');
        
        % finds the trials that have non matching number of events
        for q = 1:size(indexOfBoth,3) % for each trial
            trialSumEvents(q) = sum(indexOfBoth(:,1,q));
        end
        
        %         trialEventAverage = floor(mean(trialSumEvents)); % finds the correct number of a particular event in each trial
        trialEventAverage = round(sum(PTBeventArray == nonEssentialEventNumbers(i))/sum(cndTotal(:))); % finds the correct number of a particular event in each trial
        
        if trialEventAverage==0 % if calculates zero, corrects to one
            trialEventAverage = ceil(mean(trialSumEvents));
        end
        
        indexOfMismatchedTrials = find(trialSumEvents~=trialEventAverage);
        
        % for each mismatched trial tries to find the out of place
        % event by running through the timings
        for z = 1:length(indexOfMismatchedTrials)
            % gets mismatched trial
            currentTrial= nonEssentialCodes(:,:,indexOfMismatchedTrials(z));
            
            % gets index of events of interest and  corresponding
            % timestamps
            currentIndexOfCodes = currentTrial == (nonEssentialEventNumbers(i));
            currentIndexOfTimes = circshift(currentIndexOfCodes,-1,2);
            
            % gets the timestamps and works out if any are duplicated
            % and irrational timescale
            currentTrialEventTimes = currentTrial(currentIndexOfTimes);
            timeBetweenEvents = currentTrialEventTimes(2:end) - currentTrialEventTimes(1:end-1);
            meanTimeBetweenEvents = mean(timeBetweenEvents);
            stdTimeBetweenEvents = std2(timeBetweenEvents);
            indexOfOddTimesOut = find(timeBetweenEvents < (meanTimeBetweenEvents - 10*stdTimeBetweenEvents));
            indexOfOddTimesOut = indexOfOddTimesOut+1;
            
            % deletes these irrational events from the array
            for b =1:length(indexOfOddTimesOut)
                indexOfBoth(indexOfOddTimesOut(b),:,indexOfMismatchedTrials(z)) = [0 0];
            end
            
            % check number of events has been fixed AND if the event is
            % miscoded, ie 139 instead of 140 etc
            counter = 0;
            while sum(indexOfBoth(:,2,indexOfMismatchedTrials(z))) ~= trialEventAverage
                % this loop tryones to find events +/- counter of intented
                % event
                disp('Trying to fix miscoded event entries');
                
                if counter == 5 % if we get too far from intended signal leave loop
                    break
                end
                
                % assume event number got detected as one less that
                % used, ie 140 sent, 139 detected
                counter = counter +1;
                currentEventTry = nonEssentialEventNumbers(i)-counter;
                
                % get index of miscoded values
                currentIndexOfCodesFIX = currentTrial == currentEventTry;
                currentIndexOfTimesFIX = circshift(currentIndexOfCodesFIX,-1,2);
                indexOfBothFIX= logical(currentIndexOfCodesFIX+currentIndexOfTimesFIX);
                
                % change miscoded values
                index2Use = find(currentIndexOfCodesFIX);
                [rows2Fix, cols2Fix] = ind2sub(size(currentIndexOfCodesFIX), index2Use);
                nonEssentialCodes(rows2Fix,cols2Fix,indexOfMismatchedTrials(z))= nonEssentialEventNumbers(i);
                indexOfBoth(rows2Fix,:,indexOfMismatchedTrials(z)) = 1;
                
                
                
                % if we still are not finding the correct number of
                % events FIX v2
                if sum(indexOfBoth(:,2,indexOfMismatchedTrials(z))) ~= trialEventAverage
                    % assume event number got detected as one less that
                    % used, ie 140 sent, 141 detected
                    currentEventTry = nonEssentialEventNumbers(i)+counter;
                    
                    % get index of miscoded values
                    currentIndexOfCodesFIX = currentTrial == currentEventTry;
                    currentIndexOfTimesFIX = circshift(currentIndexOfCodesFIX,-1,2);
                    indexOfBothFIX= logical(currentIndexOfCodesFIX+currentIndexOfTimesFIX);
                    
                    % change miscoded values
                    index2Use = find(currentIndexOfCodesFIX);
                    [rows2Fix, cols2Fix] = ind2sub(size(currentIndexOfCodesFIX), index2Use);
                    nonEssentialCodes(rows2Fix,cols2Fix,indexOfMismatchedTrials(z))= nonEssentialEventNumbers(i);
                    indexOfBoth(rows2Fix,:,indexOfMismatchedTrials(z)) = 1;
                    
                end
            end
        end
        nonEssentialEvent{2,i}= reshape(nonEssentialCodes(indexOfBoth),[],2,size(nonEssentialCodes,3)); % if all goes well reshapes array
    end
end

%% build trial condition structure
experimentStructure.rawTrials = rawTrials;
experimentStructure.validTrial = validTrial;
experimentStructure.cndTotal = cndTotal;

if any(cnd)
    experimentStructure.block = block;
    experimentStructure.cnd = cnd;
    
    cnd = cnd(:,2);
    for i=1:length(cndTotal)
        cndTrials{i} = find(cnd == i)';
    end
    experimentStructure.cndTrials = cndTrials;
end

experimentStructure.nonEssentialEvent= nonEssentialEvent;

%% align events to frame times and numbers

for i =1:length(experimentStructure.nonEssentialEvent)
    experimentStructure = alignEvents2Frames(experimentStructure, experimentStructure.nonEssentialEvent{1,i});
end

end