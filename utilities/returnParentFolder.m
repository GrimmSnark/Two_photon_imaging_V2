function [parentDirectory, currentLevel] = returnParentFolder(fullfile)
% Returns parent folder of fullfile sting
% Inputs-   fullfile: filepath for the file you want to get the parent of
%
% Outputs-  parentDirectory: string of parent folder
%           currentLevel: filename or folder of current level

parts = strsplit(fullfile, '\');
currentLevel = parts(end);
parentDirectory = strjoin(parts(1:end-1), '\');
parentDirectory= strcat(parentDirectory, '\');


end