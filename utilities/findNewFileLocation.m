function newString = findNewFileLocation(oldStringLoc, newStringLoc)
% Function changes filepath roots based on old string and new string
% locations. Finds the matching portions and splices in the new string
% location in front.
%
% Inputs - oldStringLoc: old filepath to change, ie
% C:\PostDoc Docs\dataTemp\2P_Data\Raw\Mouse\M1\TSeries-08312020-0707-000\
%
%          newStringLoc: new filepath location to prepend to, ie
% G:\dataTemp\2P_Data\Raw\Mouse\M1\TSeries-08312020-0707-000\
%
% Outputs - newString: new filepath location

%% defaults
maxSearchIndex = max([length(oldStringLoc) length(newStringLoc)]);
count = 0;
stringSameFlag = 1;
% see where end old string starts matching end of new string
while stringSameFlag == 1
    count = count + 1;
    stringSameFlag = strncmp(reverse(oldStringLoc), reverse(newStringLoc),count);
end

count = count -2;
newString = [newStringLoc(1:end-count-1) oldStringLoc(end-count:end)];
end