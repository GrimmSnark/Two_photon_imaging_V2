function [experimentStructure, imagingVol]= prepImagingData(experimentStructure, loadMetaData)
% Reads in metadata into experimentStructure and read in imaging files
%
% Inputs- experimentStructure: structure containing experiment data
%
%         loadMetadata: flag 1/0 for loading experiment metadata from xml 
%                       file
%
% Output- experimentStructure: updated experimentStructure
%
%         imagingVol: array of imaging data pixel x pixel x frames

% loads in meta data if it you want
if loadMetaData ==1 
    experimentStructure = prepImagingMetaData(experimentStructure); % gets metadata from the xml files
    frameFilepath = [experimentStructure.prairiePath experimentStructure.filenamesFrame{1,1}]; %builds fullfile location for images
else
    file = dir([experimentStructure.prairiePath '*.tif']);
    frameFilepath = [experimentStructure.prairiePath file(1).name ];
end

% sets fullfile for first image
experimentStructure.fullfile = frameFilepath;

% reads in imaging data
imagingVol = read_Tiffs(frameFilepath,1); % if one large 3d file

% if it is a t series
if ndims(imagingVol) ~=3
    imagingVol = readMultipageTifFiles(experimentStructure.prairiePath);
end

end