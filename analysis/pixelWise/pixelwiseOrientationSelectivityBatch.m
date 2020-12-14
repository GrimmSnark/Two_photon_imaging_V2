function pixelwiseOrientationSelectivityBatch(directory, startDirNo, noOrientations, angleMax, secondCndDimension, useSTDorMean, channel2Use)
% Function which plots orientation selectivty maps from STD or mean stim
% images
%
% Inputs: directory - processed experiment day folder containing the
%                     experimentStructure.mats
%
%          startDirNo: specify the number folder to start on (OPTIONAL)
%
%
%         noOrientations - number of orientations tested in the experiment
%                          ie 4/8 etc, default = 8
%
%         angleMax - 360 or 180 for the Max angle tested, default = 360
%
%         secondCndDimension - number of conditions in the second 
%                              dimension, e.g. colors tested, ie 1 for 
%                              black/white, 4 monkey color paradigm, or
%                              number of spatial frequencies etc
%                              default = 1
%
%         useSTDorMean - 0/1 flag for using STD (1) or mean (2) per
%                        condition array for calculations
%                        (OPTIONAL) default = 1 (STD image)
%
%         channel2Use: can specify channel to analyse if there are more 
%                      than one recorded channel
%                      (OPTIONAL) default = 2 (green channel)


%% set defaults


if nargin <2 || isempty(noOrientations)
    noOrientations = 8;
end

if nargin < 3 || isempty(startDirNo)
   startDirNo = 1; 
end

if nargin <4 || isempty(angleMax)
    angleMax = 360;
end

if nargin <5 || isempty(secondCndDimension)
    secondCndDimension = 1;
end

if nargin <6 || isempty(useSTDorMean)
    useSTDorMean = 1;
end

if nargin < 7 || isempty(channel2Use)
    channel2Use = 2;
end

%% run pixel orientation processing

% get the folders to process
folders2Process = dir([directory '\**\experimentStructure.mat']);

% tries to fix if we happened to use the raw data path
if isempty(folders2Process)
    filePath = createSavePath(directory,1,1);
    folders2Process = dir([filePath '\**\experimentStructure.mat']);
end

for i = startDirNo:length(folders2Process)
    pixelwiseOrientationSelectivity([folders2Process(i).folder '\'], noOrientations,angleMax, secondCndDimension,useSTDorMean, channel2Use)
end
