function prepDataBatch(directory, experimentType, startDirNo,saveRegMovie, loadMetadata, motionCorrectionType, channel2register, frameAlignmentTemplate)
% Wrapper to run through a folder containing multiple single files for
% preparing Data 
% Inputs-   directory: filepath for the raw data experiment day file.
%                     This should contain all the runXX recording folders, 
%                     i.e.
%                     'D:\Data\2P_Data\Raw\Mouse\GCamp7s\WT_M1\20200123\'
%
%          experimentType: string of experiment type, if empty will not run
%                          experiment event extraction, default =
%                          'orientation'
%
%          startDirNo: specify the number folder to start on (OPTIONAL)
%
%          saveRegMovie: 0/1 flag for save registered movie file, 
%                        (OPTIONAL) default is 0 = not save
%
%          loadMetadata: 1/0 flag for loading experiment metadata from xml 
%                        file (OPTIONAL) default is 1 = load metadata
%
%          motionCorrectionType: string input for motion correction type,
%                                if empty will not run motion correction
%                                (OPTIONAL) default = 'subMicronMethod'
%                                Correction Types:
%
%                            'subMicronMethod' = DFT-based subpixel method 
%                            'nonRigid' = non-rigid DFT subpixel 
%                             registration
%
%          saveRegMovie: 0/1 flag for save registered movie file, not 
%                        necessary and takes up time/space (OPTIONAL) 
%                        default is 0 = does not save file
%
%          channel2register: can specify channel to register the stack with
%                            if there are more than one recorded channel
%                           (OPTIONAL) default = 2 (green channel)
%
%          frameAlignmentTemplate: 1/0 flag to use either:
%
%                                1 = 100 brightest frames 
%                                0 = first 100 frames to create motion 
%                                correction template
%
%                                (OPTIONAL) default = 1 (brightest frames)

%% set defaults
if nargin < 2 || isempty(experimentType)
    experimentType = 'orientation';
end
if nargin < 3 || isempty(startDirNo)
   startDirNo = 1; 
end

if nargin < 4 || isempty(saveRegMovie)
    saveRegMovie =0;
end

if nargin < 5 || isempty(loadMetadata)
    loadMetadata =1;
end

if nargin < 6 || isempty(motionCorrectionType)
    motionCorrectionType = 'subMicronMethod';
end

if nargin < 7 || isempty(channel2register)
    channel2register = 2;
end

if nargin < 8 || isempty(frameAlignmentTemplate)
    frameAlignmentTemplate = 1;
end


%% run wrapper
subFolders = returnSubFolderList(directory);

for i = startDirNo:length(subFolders)
   
    subSubFolders = dir([directory subFolders(i).name '\TSeries*']); % Retrieve TSeries folder, ie the one containing image files
    for x = 1:length(subSubFolders)
        prepData([directory subFolders(i).name '\' subSubFolders(x).name],loadMetadata,motionCorrectionType,saveRegMovie,experimentType,channel2register,[],frameAlignmentTemplate);
    end
    
end

end