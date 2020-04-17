function [eventLocation, eventIndx]= findEvents(event, eventArray, codes)
% find event indices within eventArray
%
% Inputs- event: can be numeric or string
%
%         eventArray: array of timestamps and decoded events from prairie
%                     file
%
%         codes: the cell array which is produced from running
%               prairieCodes()
%
% Outputs- eventIndx: logical vector size of eventArray for found instances
%                     of event
%          eventLocation: index locations of found events

if isnumeric(event)
    level = event;
else
    % find voltage level equal to string event
    level = find(strcmp(event, codes), 1);
end

eventIndx = eventArray(:,2) == level;
eventLocation = find(eventIndx);
end