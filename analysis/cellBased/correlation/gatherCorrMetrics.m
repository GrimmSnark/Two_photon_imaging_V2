function [CorrMetrics_animal] = gatherCorrMetrics(filepaths)

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