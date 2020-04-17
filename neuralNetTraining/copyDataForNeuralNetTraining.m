function copyDataForNeuralNetTraining(folderPaths, saveDir, removeRecordingFlag)
% Copies the data needed for training the Cell ROI neural net
% Inputs:   folderPaths- string of folder to search or cell array of
%                        strings to search for images and ROI files
%
%           saveDir- string of folder path to save the training data to
%
%           removeRecordingFlag - 0/1 flag to remove smore bad recordings
%                                 0 = do not remove, 1 = remove folders
%                                 (default = 1)


%% set defaults

if nargin < 2 || isempty(saveDir)
    saveDir = 'D:\Data\2P_Data\Processed\Mouse\neuralNetData\neuralNetCovid19\';
end

if nargin < 3 || isempty(removeRecordingFlag)
    removeRecordingFlag = 1;
end

%% Get the folders with ROI already chosen

% Get all folders with cell ROIs
allFolders = [];
for q = 1:length(folderPaths)
    allFolders = [allFolders ; dir([folderPaths{q} '/**/ROIcells.zip'])];
end

%% Check for duplicates of the same recording and choose the 
% check for duplicates of the same recording
for w = 1:length(allFolders)
    temp = strsplit(allFolders(w).folder, filesep);
    Index(w) = find(contains(temp,'TSeries'));
    filePartsAll(w,1:length(temp)) =  temp;
end

indexVect = sub2ind(size(filePartsAll),1:length(filePartsAll), Index);
duplicateTester = filePartsAll(indexVect);
[~, duplicateIndexs] = unique(duplicateTester); % gets the unique TSeries folders

duplicateIndexs = sort(duplicateIndexs); % sorts the indices ( gives the first unique folder)

% gets the last unique folder, ie the one created last
diffBetween = [duplicateIndexs(2:end) - duplicateIndexs(1:end-1) ; 1] - 1;
index2use = duplicateIndexs +  diffBetween;

allFolders = allFolders(index2use);

% remove shitty recordings
if removeRecordingFlag == 1
    counter = 1;
    for x = 1:length(allFolders)
        if isempty([strfind(allFolders(x).folder, '\M1\')  strfind(allFolders(x).folder, '\M3\')])
            folders(counter) =  allFolders(x);
            counter = counter +1;
        end
    end
end

%% copy files across
copyfiles{1} = 'ROIcells.zip';
copyfiles{2} = 'STD_Average.tif';

if ~exist(saveDir,7)
   mkdir(saveDir); 
end

if ~exist([saveDir '\original'],7)
   mkdir([saveDir '\original']); 
end

original

count = 1;
for i = 1:length(folders)
    for x = 1:length(copyfiles)
            if x == 1 %if the ROI file
                copyfile([folders(i).folder '\' copyfiles{x}], [saveDir '\original' copyfiles{x}(1:end-4) '_' sprintf('%02d',i) copyfiles{x}(end-3:end) ])
            else % if the image file
                try
                    image2Process = read_Tiffs([folders(i).folder '\Max_Project.tif']); % This is the image we want if it a two channel recording
                catch
                    image2Process = read_Tiffs([folders(i).folder '\' copyfiles{x}]); % If a single channel recoring
                end
                
                saveastiff(image2Process, [saveDir '\original\' copyfiles{x}(1:end-4) '_' sprintf('%02d',i) copyfiles{x}(end-3:end) ])
            end
            count = count +1; 
    end 
end
end