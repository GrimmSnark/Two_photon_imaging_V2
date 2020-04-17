function [oriStruct] = gatherPopulationOSI(filepaths, zScoreThrehold)
% Gathers already calculated orientation selectivity info from the
% subfolders derived from filpaths
% Inputs: filepaths- filepath string of folder for the function to search
%                    through for experimentStructure.mats OR cell string
%                    array of multiple folders to run through, ie.
%                    [{D:\Data\M1}, {D:\Data\M2}]
%
%         zScoreThrehold- used if you want to limit population to a certain
%                         z score visual responsiveness
%
% Output: oriStruct - structure containing the selectivtiy metrics,
%                     currently contains OSI, DSI, OSI_CV and dual channel
%                     overlap flag

%% Defaults

if nargin <2 || isempty(zScoreThrehold)
    zScoreThrehold = [];
end

% set up blank lists
oriStruct.OSI_list =[];
oriStruct.DSI_list =[];
oriStruct.ChannelOverlap =[];
oriStruct.OSI_CV_list =[];

%% start grabbing data

if ~iscell(filepaths)
    filepaths = cellstr(filepaths);
end

% for each directory in filepaths
for x = 1:length(filepaths)
    
    filepathList = dir([filepaths{x} '\**\*experimentStructure.mat']);
    
    % for each of the subfolders in the filepath entry
    for i = 1:length(filepathList)
        
        % try to load experimentStructure.mat
        try
            load([filepathList(i).folder '\experimentStructure.mat']);            
        catch
            disp(['Unable to load "' filepathList(i).folder '\experimentStructure.mat" PLease check folder and structure']);
        end
        
        % try to get the OSI info
        try
            % new version
            oriStruct = gatherOSI(experimentStructure, oriStruct, zScoreThrehold);
        catch
            % old version
            oriStruct = gatherOSILegacy(experimentStructure, oriStruct, zScoreThrehold);
        end
    end   
end
end