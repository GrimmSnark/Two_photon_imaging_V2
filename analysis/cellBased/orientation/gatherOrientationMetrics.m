function [OSIMetrics_animal, metricIdentifiers, XYZ_recordingLocs] = gatherOrientationMetrics(filepaths, metrics2Extract, zScoreLimit, anatomicalMarker2Extract)
% Gathers already calculated orientation selectivity info from the
% subfolders derived from filpaths
%
% Inputs: filepaths- filepath string of folder for the function to search
%                    through for experimentStructure.mats OR cell string
%                    array of multiple folders to run through, ie.
%                    [{'D:\Data\M1'}, {'D:\Data\M2'}]
%
%         zScoreThrehold- used if you want to limit population to a certain
%                         z score visual responsiveness
%
%         metrics2Extract - number vector to indicate which orientation
%                           metrics you want to extract, see code for
%                           details
%
%         anatomicalMarker2Extract - string to indicate what anatomical
%                                    marker to extract for cell
%                                    classification, ie
%
%                                    'ChannelOverlap' - color channel
%                                    overlap used in PV/non PV cell
%                                    anaylsis (DEFAULT)
%                                    'COIdent' - cytchrome oxidase patch
%                                    vs interpatch identity
%
%
% Outputs: OSIMetrics_animal - structure containing all the metrics
%                              extracted (cell x second Dimension cnd x
%                              metric)
%
%          metricIdentifiers - cell string detailing which orientation
%                              metrics you extracted
%
%          XYZ_recordingLocs - XYZ locations of all recordings, used for
%                              plotting across depths
%% set defaults
if nargin <3 || isempty(zScoreLimit)
    zScoreLimit = [];
end

if nargin < 4 || isempty(anatomicalMarker2Extract)
   anatomicalMarker2Extract = 'ChannelOverlap';
end

%% Get metrics to extract
metricIdentifiers = [];

for q = 1: length(metrics2Extract)
    
    switch metrics2Extract(q)
        case 1
            metricIdentifiers{q} = 'OSI_CV';
        case 2
            metricIdentifiers{q} = 'LSStruct.OSI';
        case 3
            metricIdentifiers{q} = 'VHStruct.OSI_PR';
        case 4
            metricIdentifiers{q} = 'VHStruct.ot_index_rectified';
    end
end

%% load data and get metrics

if ~iscell(filepaths)
    filepaths = cellstr(filepaths);
end

OSIMetrics_animal =[];
counter = 1;
% for each directory in filepaths
for x = 1:length(filepaths)
    
    filepathList = dir([filepaths{x} '\**\*experimentStructure.mat']);
    
    % remove zstack folders
    index2Remove = find(contains({filepathList(:).folder}, 'ZSeries'));
    filepathList(index2Remove) = [];
    
    OSIMetrics_recordings =[];
    % for each recording in that list
    for i = 1:length(filepathList)
        OSIMetrics =[];
        load([filepathList(i).folder '\experimentStructure.mat']);
        
        
        % get recording locations for reasons
        XYZ_recordingLocs(counter,:) = experimentStructure.currentPostion;
        counter = counter + 1;
        
        disp(['Sucessfully loaded ' filepathList(i).folder ' on ' num2str(i) '/' num2str(length(filepathList))]);
        
        % for each metric
        for z = 1:length(metricIdentifiers)
            %for each cell
            for c = 1:experimentStructure.cellCount
                % for the number of second dimension conditions, ie contrast,
                % color etc
                for b = 1:size(experimentStructure.OSIStruct,2)
                    OSIMetrics(c,b,z) = eval(['experimentStructure.OSIStruct{' num2str(c) ',' num2str(b) '}.' metricIdentifiers{z}]);
                end
            end
        end
        
        
        
        % if the OSIs have been calculated
        if ~isempty(OSIMetrics)
            % add in cell channel dual expression if available
            if isprop(experimentStructure, anatomicalMarker2Extract)
                OSIMetrics(:,1,length(metricIdentifiers)+1) = eval(['experimentStructure.' anatomicalMarker2Extract]);
            end
            
            
            % limits cells included to responsive basedon z score, if specified
            if ~isempty(zScoreLimit)
                OSIMetrics(experimentStructure.ZScore<zScoreLimit,:,:) = [];
            end
            
            % add metrics to recording grand structure
            OSIMetrics_recordings = cat(1, OSIMetrics_recordings, OSIMetrics);
            
        else % if OSIs have not been calculated print that they are missing
            disp([filepathList(i).folder  ' does NOT contain OSI metrics, please check!!!!']);
        end
        
    end
    
    % add metrics to recording grand structure
    OSIMetrics_animal = cat(1, OSIMetrics_animal, OSIMetrics_recordings);
end

% add in cell channel dual expression label into metricIdentifiers
if isprop(experimentStructure, anatomicalMarker2Extract)
    metricIdentifiers{end+1} = anatomicalMarker2Extract;
end

end