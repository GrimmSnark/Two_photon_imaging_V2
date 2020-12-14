function [fullDestinationFolder] = copyCreateFolder(sourceDir, destinationDir)
% Copies source folder into destination folder while creating the last
% subfolder

%% get folder string to create
try
    stringSplit = strsplit(sourceDir,'\');
    delim = '\';
catch
    stringSplit = strsplit(sourceDir,'/');
     delim = '/';
end

folder2create = stringSplit{end};
fullDestinationFolder = [destinationDir delim folder2create delim];

if ~exist(fullDestinationFolder, 'dir')
   mkdir(fullDestinationFolder);
end

%% copy folder
copyfile(sourceDir, fullDestinationFolder)


end