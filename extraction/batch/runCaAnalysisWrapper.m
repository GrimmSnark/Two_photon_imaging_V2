function runCaAnalysisWrapper(experimentDayFilepath, chooseROIsFlag, startDirNo, channel2Use, checkChannelOverlap, useNeuralNet4ROIs)
% wrapper to batch choose ROIs and run calcium trace extraction from chosen
% cells for an experiment day folder
%
% Inputs- experimentDayFilepath: filepath for the folder to run batch
%                                analysis
%         chooseROIs: 1/0 flag to choose cell ROIs, if set to 0 will try
%                     and load already chosen ROIs (OPTIONAL) 
%                     default is 1 = choose ROIs
%
%         startDirNo: specify the number folder to start on (OPTIONAL)
%
%         channel2Use: can specify channel to analyse if there are more 
%                      than one recorded channel
%                      (OPTIONAL) default = 2 (green channel)
%         checkChannelOverlap: Indicates whether you want to
%                              categorize cell ROIs into color channel
%                              overlapping or not, ie whether it show
%                              co-expression. Only affects recordings with
%                              two color channels
%                               0 == do not categorize (DEFAULT)
%                               1 == categorize 
%         useNeuralNet4ROIs: Inidicates whether you want to use the neural
%                            net to prime ROIs for cells
%                               0 == do not use net
%                               1 == use net (DEFAULT)



%% set defaults

if nargin <2 || isempty(chooseROIsFlag)
    chooseROIsFlag = 1;
end

if nargin <3 || isempty(startDirNo)
    startDirNo = 1;
end

if nargin <4 || isempty(channel2Use)
    channel2Use = 2; % sets default channel to use if in multi channel recording
end

if nargin <5 || isempty(checkChannelOverlap)
    checkChannelOverlap = 0;
end

if nargin <6 || isempty(useNeuralNet4ROIs)
    useNeuralNet4ROIs = 1;
end

%% start analysis

% close all FIJI windows
try
   MIJ.closeAllWindows; 
catch

end

% get the folders to process
folders2Process = dir([experimentDayFilepath '\**\experimentStructure.mat']);

% tries to fix if we happened to use the raw data path
if isempty(folders2Process)
    filePath = createSavePath(experimentDayFilepath,1,1);
    folders2Process = dir([filePath '\**\experimentStructure.mat']);
end

% remove zstack folders
index2Remove = find(contains({folders2Process(:).folder}, 'ZSeries'));
folders2Process(index2Remove) = [];

%choose all ROIs if flag set
if chooseROIsFlag == 1
    for i = startDirNo:length(folders2Process)
       killFlag = chooseROIs([folders2Process(i).folder '\'], useNeuralNet4ROIs, [], checkChannelOverlap);
    
    if killFlag ==1 % if you choose to end script
       return 
    end
    
    end
else % start FIJI if not already started
    intializeMIJ;
end

% Do actual analysis
for x =  startDirNo:length(folders2Process)
     CaAnalysis([folders2Process(x).folder '\'], channel2Use);
end

end