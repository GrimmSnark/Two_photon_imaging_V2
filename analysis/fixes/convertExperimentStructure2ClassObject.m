function failedFiles = convertExperimentStructure2ClassObject(directory)


%% Start processing

% get the folders to process
folders2Process = dir([directory '\**\experimentStructure.mat']);

% tries to fix if we happened to use the raw data path
if isempty(folders2Process)
    filePath = createSavePath(directory,1,1);
    folders2Process = dir([filePath '\**\experimentStructure.mat']);
end

counter = 1;
% for each processing folder
for i = 1:length(folders2Process)
    tempObject = experimentStructureClass;
    
    % try to load experimentStructure
    try
    load([folders2Process(i).folder '\experimentStructure.mat']);
    
    % if is not object then convert
    if ~isobject(experimentStructure)
        
        % get fieldnames
        exStructFieldNames = fieldnames(experimentStructure);

        % for each fieldname in the structure
        for x = 1:length(exStructFieldNames)
            
            if isprop(tempObject,exStructFieldNames{x}) % if already a property in class, copies across
                
                tempObject.(exStructFieldNames{x}) = experimentStructure.(exStructFieldNames{x});
                
            else % if not, adds the property field then copies
                
                
                if strcmp(exStructFieldNames{x}, 'PVCellIndent')
                    tempObject.ChannelOverlap = experimentStructure.(exStructFieldNames{x});
                else
                    tempObject.addprop(exStructFieldNames{x});
                    tempObject.(exStructFieldNames{x}) = experimentStructure.(exStructFieldNames{x});
                end
            end
        end
        
        % save object as experimentStructure
        experimentStructure = tempObject;
        save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');
    end
    
    catch
        % if can not, may be corrupt, takes a note ofthe filepath
        failedFiles{counter,1} = [folders2Process(i).folder '\experimentStructure.mat'];
        counter = counter+1;
    end
end
end