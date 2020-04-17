function experimentStructure = prepImagingMetaData(experimentStructure)
% Loads in imaging meta data from the prairie xml file
%
% Input- experimentStructure: structure containing experiment data
%
% Output- experimentStructure: updated structure containing experiment data
%
%% get the correct folder/files
filepath = experimentStructure.prairiePath; %imaging folder

% get xml files in folder, should be two there
fileList = dir([filepath '*.xml']);

if isempty(fileList)
    filepath = [filepath '\'];
    fileList = dir([filepath '*.xml']); % trys to add last backslash if can not find files
    
    if isempty(fileList)
        error(['Please check filepath:' ...
            '\n%s'], filepath);
    end
end

%% get the xml which contains imaging meta data
voltageFileIndex = contains({fileList.name}, 'Voltage'); % finds inde of file containing 'Voltage

% just in case there is no voltage file
if any(voltageFileIndex)
metaDataFileIndex = find(~voltageFileIndex); % finds index of meta data file
else
    metaDataFileIndex = 1;
end

prairieXMLPath = [fileList(metaDataFileIndex).folder '\' fileList(metaDataFileIndex).name]; % sets metaData filepath
%% Read in meta data from xml file
imagingStructRAW = xml2struct(prairieXMLPath);

experimentStructure.date = extractFromStruct(imagingStructRAW, 0, [], 'PVScan', 'Attributes', 'date');
experimentStructure.scanType = extractFromStruct(imagingStructRAW, 0, [], 'PVScan', 'Sequence', 'Attributes', 'type');

%get all the settings from the structure
experimentStructure =  readScanXMLSettings(experimentStructure, imagingStructRAW);


% get frame times etc
experimentStructure.absoluteFrameTimes = extractFromStruct(imagingStructRAW, 1, 3, 'PVScan', 'Sequence', 'Frame', 'Attributes', 'absoluteTime');
experimentStructure.absoluteFrameTimes = experimentStructure.absoluteFrameTimes * 1000; % converts the relative times to ms
experimentStructure.relativeFrameTimes = extractFromStruct(imagingStructRAW, 1, 3, 'PVScan', 'Sequence', 'Frame', 'Attributes', 'relativeTime');
experimentStructure.relativeFrameTimes = experimentStructure.relativeFrameTimes * 1000; % converts the relative times to ms

% get filenames
try
    experimentStructure.filenamesFrame = extractFromStruct(imagingStructRAW, 0, 3, 'PVScan', 'Sequence', 'Frame', 'File', 'Attributes', 'filename');
catch ME
    experimentStructure.filenamesFrame = extractFromStruct(imagingStructRAW, 0, [3 4] , 'PVScan', 'Sequence', 'Frame', 'File', 'Attributes', 'filename');
end

%% get the file path for the voltage recording csv
CSVList = dir([filepath '*VoltageRecording*.csv']);
if ~isempty(CSVList)
    prairiePathCSV = [filepath CSVList(1).name];
else
    prairiePathCSV = [];
end

%% wrap up
experimentStructure.prairiePathVoltage = prairiePathCSV;
experimentStructure.prairiePathXML = prairieXMLPath;

end
