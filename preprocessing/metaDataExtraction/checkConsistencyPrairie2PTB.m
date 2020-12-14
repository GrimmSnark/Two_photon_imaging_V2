function [eventArray, PTBevents ]= checkConsistencyPrairie2PTB(dataPrairie, dataPTB)
% checks the consistency between recorded prairie events and the events
% set in the PTB experimental file
%  
% Inputs- dataPrairie: can be a filepath for .csv file OR 
%                      preloaded eventArray
%
%         dataPTB: is a filepath for .mat PTB file
%
% Outputs- eventArray: updated event array
%          PTBeventArray: event array from pyschtoolbox event file 
      
%% get PTB file
if ischar(dataPrairie)
    eventArray = readEventFilePrairie(dataPrairie, []);
else
    eventArray = dataPrairie;
end

load(dataPTB);

% load in events from PTB
PTBevents = cellfun(@str2double,stimCmpEvents(2:end,:));

% start compare event arrays
eventCodes = eventArray(:,2);
PTBeventArray = PTBevents(:,2);

if length(eventCodes) == length(PTBeventArray)
    disp('Success, events arrays are the same size!!!')
    
    if isequal(eventCodes, PTBeventArray)
        
        disp('Awesome, the event array codes are exactly the same!!!')
    else
        indx = eventCodes ~= PTBeventArray;
        
        disp(['Oh no, there are ' num2str(sum(indx)) 'disputed codes, fixing from PTB timing file...'])
        eventArray(indx,2) = PTBeventArray(indx);
    end
    
else
    disp('Failure, events array are NOT the same size!!!')
    
end

end