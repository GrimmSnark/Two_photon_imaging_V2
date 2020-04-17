function experimentStructure = alignEvents2Frames(experimentStructure, event)
% extracts image frame numbers/indexs for the chosen event 
%
% Inputs- experimentStructure: structure containing experiment info
%
%         event: the chosen event to align, either the string or event 
%                number
%
% Output- experimentStructure: updated structure

%% handles event input if char or number
codes = prairieCodes();

if ischar(event)
    event = event;
elseif isnumeric(event)
    event = codes{event};
else
    disp('Incorrect format of input, please review code');
    return
end
%% finds imaging frame closest to each event instanence

% finds event location in structure
indexOfEvents = find(strcmp(event, experimentStructure.nonEssentialEvent));
[subLocationI , subLocatationJ] = ind2sub(size(experimentStructure.nonEssentialEvent),indexOfEvents);
subLocationI = subLocationI+1;
events2Match = experimentStructure.nonEssentialEvent{subLocationI, subLocatationJ};

% runs through each occurance of the event and finds closest frame
for i =1:size(events2Match,1) % for each occurance per trial
    for x = 1:size(events2Match,3) % for each trial
        [~,closetIndx] = min(abs(experimentStructure.relativeFrameTimes - events2Match(i,1,x))); % finds closest match (may be negative)
        
        if experimentStructure.relativeFrameTimes(closetIndx)< events2Match(i,1,x) % makes adjustment if the closest frame is before event onset
            frameIndex(i,x) = closetIndx+1;
        else
            frameIndex(i,x) = closetIndx;
        end
    end
end

% outputs to the experiment structure for each event (number per trial,
% trial)
eval( [ 'experimentStructure.EventFrameIndx.' event '= frameIndex;']);

end