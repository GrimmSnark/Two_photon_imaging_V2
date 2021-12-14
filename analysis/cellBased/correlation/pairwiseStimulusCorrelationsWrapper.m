function  pairwiseStimulusCorrelationsWrapper(filepaths, plotFlag)
% runs stimuuls response correlation calulations on all recrodings within
% the specified folder and its subfolders
%
% Input: filepaths - cell string of filepaths to search through
%        plotFlag - flag to actually create plot instead of just
%                   calculating values
%
% USAGE : PV_Cre_tDtomato_young_M1.Filepath = [{'D:\Data\2P_Data\Processed\Mouse\GCamp7s\PV_Cre_tDtomtato_young_M1\'}];
%          pairwiseStimulusCorrelationsWrapper(PV_Cre_tDtomato_young_M1.Filepath);

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
                pairwiseStimulusCorrelations(experimentStructure, 33:40, plotFlag);
            else
                pairwiseStimulusCorrelations(experimentStructure, 1:8, plotFlag);
            end
        catch
        end
    end
end



end
