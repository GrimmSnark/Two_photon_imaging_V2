function timestampEvent = addCmpEvents(evnt)
%creates timestamped event for syncing with imaging computer posthoc. evnt
%is either a condition level or an event string

timestampEvent(1,1) = GetSecs;

if isnumeric(evnt)
    timestampEvent(1,2) = evnt;
else
    codes = prairieCodes();
    % find voltage level equal to string event
    timestampEvent(1,2) = find(strcmp(evnt, codes), 1);
    
end
end