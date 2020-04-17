function calculateOSIPopulation_wrapper(directory, noOrientations, angleMax, secondCndDimension, dataType, startDirNo)
% Wrapper function to run OSI calculation on a batch of experiments
%
% Inputs:  directory: filepath for the processed data folder, will search
%                     all subfolders for experimentStructure.mat and run 
%                     OSI calculation on them 
%                    
%          noOrientations - number of orientations tested in the experiment
%                          ie 4/8 etc, default = 8
%
%          angleMax - 360 or 180 for the Max angle tested, default = 360
%
%          secondCndDimension - number of conditions in the second
%                               dimension, e.g. colors tested, ie 1 for
%                               black/white, 4 monkey color paradigm, or
%                               number of spatial frequencies etc
%                               default = 1
%
%          dataType - specify the type of data to use
%                     FBS- first before stimulus subtraction (For LCS)
%                     Neuro_corr- Neuropil corrected based subtraction
%
%          startDirNo: specify the number folder to start on (OPTIONAL)


%% set defaults
if nargin < 2 || isempty(noOrientations)
    noOrientations = 8;
end

if nargin < 3 || isempty(angleMax)
    angleMax = 360;
end

if nargin < 4 || isempty(secondCndDimension)
    secondCndDimension = 1;
end

if nargin <5 || isempty(dataType)
    dataType = 'FBS';
end

if nargin <6 || isempty(startDirNo)
    startDirNo = 1;
end

%% Start processing

% get the folders to process
folders2Process = dir([directory '\**\experimentStructure.mat']);

% tries to fix if we happened to use the raw data path
if isempty(folders2Process)
    filePath = createSavePath(directory,1,1);
    folders2Process = dir([filePath '\**\experimentStructure.mat']);
end

for i = startDirNo:length(folders2Process)
    load([folders2Process(i).folder '\experimentStructure.mat']);
    experimentStructure =calculateOSIPopulation(experimentStructure, noOrientations, angleMax, secondCndDimension, dataType);
    
%     compareOrientationTuningFits(experimentStructure, [], noOrientations, angleMax);
end

end