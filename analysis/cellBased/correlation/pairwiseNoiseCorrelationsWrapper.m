function  pairwiseNoiseCorrelationsWrapper(filepaths)


%% Start processing

for x = 1:length(filepaths)
    
    filepathList = dir([filepaths{x} '\**\*experimentStructure.mat']);
    
    % remove zstack folders
    index2Remove = find(contains({filepathList(:).folder}, 'ZSeries'));
    filepathList(index2Remove) = [];
    
    OSIMetrics_recordings =[];
    % for each recording in that list
    for i = 1:length(filepathList)
        load([filepathList(i).folder '\experimentStructure.mat']);
        
        disp(['Sucessfully loaded ' filepathList(i).folder ' on ' num2str(i) '/' num2str(length(filepathList))]);
        
        try
            if length(experimentStructure.cndTotal) > 8
                pairwiseNoiseCorrelations(experimentStructure, 33:40);
            else
                pairwiseNoiseCorrelations(experimentStructure, 1:8);
            end
        catch
        end
    end
end



end
