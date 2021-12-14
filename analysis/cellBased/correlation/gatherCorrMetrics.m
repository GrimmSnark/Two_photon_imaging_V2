function [CorrMetrics_animal] = gatherCorrMetrics(filepaths)
% gathers correlation metrics from all subfolders in filepath, intended for
% each animal or subject
%
% Inputs: filepaths - string or cell string of mutiple folders to search
%                     through for experimentStructures
%
% Outputs: CorrMetrics_animal- structure containing all correlation metrics
%                              for the animal or subject
%
% USAGE : PV_Cre_tDtomato_young_M2.Filepath = [{'D:\Data\2P_Data\Processed\Mouse\gCamp6s\PV_Cre_tDtomato_young_M2\'} {'G:\dataTemp\2P_Data\Processed\Mouse\gCamp6s\PV_Cre_tDtomato_young_M2\'}];
%         [PV_Cre_tDtomato_young_M2.corr] = gatherCorrMetrics(PV_Cre_tDtomato_young_M2.Filepath);

%% load data and get metrics

if ~iscell(filepaths)
    filepaths = cellstr(filepaths);
end

CorrMetrics_recordings =[];
counter = 1;
% for each directory in filepaths
for x = 1:length(filepaths)
    
    filepathList = dir([filepaths{x} '\**\*experimentStructure.mat']);

     % remove zstack folders
    index2Remove = find(contains({filepathList(:).folder}, 'ZSeries'));
    filepathList(index2Remove) = [];
    
    % for each recording in that list
    for i = 1:length(filepathList)
        CorrMetrics =[];
        load([filepathList(i).folder '\experimentStructure.mat']);
        counter = counter + 1;
        
        disp(['Sucessfully loaded ' filepathList(i).folder ' on ' num2str(i) '/' num2str(length(filepathList))]);
        
        % if correlations field exists in the experimentStructure
        if isprop(experimentStructure, 'correlations')
            CorrMetrics = experimentStructure.correlations;
            CorrMetrics.allPairs =  CorrMetrics.allPairs';
            
            if isfield(experimentStructure.correlations, 'noise')
                
                fields = fieldnames(experimentStructure.correlations.noise);
                
                for qq=1:length(fields)
                    CorrMetrics.([fields{qq} '_Noise']) = CorrMetrics.noise.(fields{qq});   % read/concatenate
                end
                
                CorrMetrics = rmfield(CorrMetrics, 'noise');
                CorrMetrics.allPairs_Noise =  CorrMetrics.allPairs_Noise';
            end 
        end
        
        
        % merge structures
        CorrMetrics_recordings = cat(2, CorrMetrics_recordings, CorrMetrics);
    end
end
    
%% merge structure

fields = fieldnames(CorrMetrics_recordings);

CorrMetrics_animal = createEmptyStruct(fields);
for i=1:length(fields)
    CorrMetrics_animal.(fields{i}) = horzcat(CorrMetrics_recordings.(fields{i}));   % read/concatenate
end
    
end