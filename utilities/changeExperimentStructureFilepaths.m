function changeExperimentStructureFilepaths(filepath)

%% defaults
folder2Use =[];

%% gets the experimentStructure filepaths
try
    load(filepath, '-mat');
    filePath2Use = dir(filepath);
    experimentStructure.savePath = [filePath2Use.folder '\'] ;
catch
    if exist([filepath '\experimentStructure.mat'], 'file' )
        load([filepath '\experimentStructure.mat']);
        experimentStructure.savePath = [filepath '\'];
    else
        folder2Use = dir([filepath '\**\experimentStructure.mat']);
    end
end


%% runs through filepath list to change filepaths

if ~isempty(folder2Use)
    for i = 1:length(folder2Use)
        
        % load in experimentStructure
        load([folder2Use(i).folder '\experimentStructure.mat']);
        experimentStructure.savePath = [folder2Use(i).folder '\'];
        
        % create new raw path from the new save path
        rawPath = createRawFromSavePath(experimentStructure.savePath);
        
        % modify filepaths in experimentStructure
        experimentStructure.prairiePath = rawPath;
        
        voltageFile = dir([rawPath '\**\*Voltage*.csv']);
        experimentStructure.prairiePathVoltage = [voltageFile.folder '\' voltageFile.name];
        
        prairieXML = dir([rawPath '\**\*TSeries*.xml']);
        experimentStructure.prairiePathXML = [prairieXML(1).folder '\' prairieXML(1).name];
        
        fullfilePath = dir([experimentStructure.prairiePath '*.tif']);
        experimentStructure.fullfile = [fullfilePath(1).folder '\' fullfilePath(1).name];
        
        PTBPath = dir([experimentStructure.prairiePath '*.mat']);
        indexCell = strfind({PTBPath.name}, 'stimParams');
        strfind({PTBPath.name},'stimParams');
        index2use = find(cellfun(@isempty,indexCell));
        
        experimentStructure.PTB_TimingFilePath = [PTBPath(index2use).folder '\' PTBPath(index2use).name]; 
        
        
        %% save experimentStructure
        save([experimentStructure.savePath '\experimentStructure.mat'], 'experimentStructure', '-v7.3');
    end
else
    
end
end