function dispersionAnalysis(wavelengthFolder, channel2Use, laserPower, runThresholdFlag)
% runs dispersion analysis on full run of dispersion values for a single
% wavelength and plots intensity/mW ovre depth of recording
%
% Inputs: wavelengthFolder- recording day folder with all the dispersion
%                           subfolders
%
%         channel2Use - 1/2 channel number to use for dispersion
%                       calculation
%
%         laserPower- vector of laser power per dispersion value
%
%         runThresholdFlag - 0/1 flag to actually run anaylsis
%                            0 = try and load previously calculated values
%                            1 = run analysis and create plot
%
% USAGE: dispersionAnalysis('D:\Data\2P_Data\Processed\Calibration\x12 Dispersion\1250um\v2\',1,[0.8 1.0 1.2 1.4 1.5 1.7], 0);
%%
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
%     data.laserPower = laserPower;
%     data.averageIntesityPer_mW = data.averageIntesity./laserPower;
%     
    load([wavelengthFolder 'dispersionData.mat']);
end

%% plot dispersion data

plotDispersionData(data);
end