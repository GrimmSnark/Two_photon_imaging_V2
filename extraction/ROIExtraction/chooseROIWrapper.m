function chooseROIWrapper(experimentDayFilepath,startDirNo, checkChannelOverlap, saveFlag)
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
%         checkChannelOverlap: Indicates whether you want to
%                              categorize cell ROIs into color channel
%                              overlapping or not, ie whether it show
%                              co-expression. Only affects recordings with
%                              two color channels
%                               0 == do not categorize
%                               1 == categorize (DEFAULT)
%
%         saveFlag: Indicated whether you want to save the
%                   checkChannelOverlap output within this function. If you
%                   are running this function as part of the
%                   runCaAnalysisWrapper it will save the results in
%                   CaAnalysis
%                   0 == do not save 
%                   1 == save here (DEFAULT)
%% set defaults

if nargin <2 || isempty(startDirNo)
    startDirNo = 1;
end

if nargin <3 || isempty(checkChannelOverlap)
    checkChannelOverlap = 1;
end

if nargin <4 || isempty(saveFlag)
    saveFlag = 1;
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


for i = startDirNo:length(folders2Process)
    killFlag = chooseROIs([folders2Process(i).folder '\'], 0, [], checkChannelOverlap, saveFlag);
    
    if killFlag ==1 % if you choose to end script
        return
    end
    
end

end
