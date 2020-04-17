function saveCmpEventFile(stimCmpEvents, dataDir, indentString, timeSave)
%function saves PTB event file to a .mat for later syncing with stim
%computer files. stimCmpEvents is a 2 colomn array with times and codes,
%dataDir is the save file directory, identString is the prefix for the
%experiment type

stimCmpEvents = [cellstr(num2str(stimCmpEvents(:,1))) , cellstr(num2str(stimCmpEvents(:,2)))];
stimCmpEvents{1,1}= 'Time(ms)';
stimCmpEvents{1,2}= 'Events';
save([dataDir indentString timeSave], 'stimCmpEvents');

disp(['Success, saved ' dataDir indentString timeSave]);
end