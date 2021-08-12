function [outputFolders, outputFolderFullfile] = returnSubFolderList(directory)
% Returns folder list within the specified directory
% Inputs-   directory: filepath for the directory to search for folders
%
% Outputs-  outputFolders: structure of all subfolders within directory

outputFolders = dir(directory);
dirFlags = [outputFolders.isdir]; % Gets flags for directories
outputFolders = outputFolders(dirFlags); % Extract only those that are directories
outputFolders(ismember( {outputFolders.name}, {'.', '..'})) = [];  % remove . and ..

outputFolderFullfile = strcat( {outputFolders.folder}, {'\'}, {outputFolders.name}, {'\'});

end