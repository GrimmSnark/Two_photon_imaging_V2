function dispersionAnalysis(wavelengthFolder, channel2Use, laserPower, runThresholdFlag)

intializeMIJ;

%% get data
% get folders
[dispersionFolders, dispersionFoldersFullfile] = returnSubFolderList(wavelengthFolder);

if runThresholdFlag == 1
% run through folders
for i = 1:length(dispersionFoldersFullfile)
    % get the intensity values
    [averageIntesity(:,i), zPostions(:,i)] = getDispersionIntensity(dispersionFoldersFullfile{i}, channel2Use);
    
    % get dispersion values
    dispersionVal(i) = str2double(dispersionFolders(i).name);
end

%% collect and save data

data.saveLoc = wavelengthFolder;
data.zPostions = zPostions;
data.averageIntesity = averageIntesity;
data.laserPower = laserPower;
data.averageIntesityPer_mW = averageIntesity./laserPower;
data.dispersionVal = dispersionVal;

save([wavelengthFolder 'dispersionData.mat'], 'data');

else
    
    load([wavelengthFolder 'dispersionData.mat']);
end

%% plot dispersion data

plotDispersionData(data);
end