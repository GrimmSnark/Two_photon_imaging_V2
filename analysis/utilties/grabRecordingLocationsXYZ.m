function recordingLocations = grabRecordingLocationsXYZ(experimentDayFilepath)
% Grabs X y Z positions for all experiment runs in a day file
%
% Input: experimentDayFilepath - recording directory file
%
% Output: recordingLocations - recording number x   X Y Z locations
%
% USAGE:  locs = grabRecordingLocationsXYZ('G:\dataTemp\2P_Data\Processed\Mouse\gCamp6s\AAVretro_LS_M1\20200318\');

% get the folders to process
folders2Process = dir([experimentDayFilepath '\**\experimentStructure.mat']);

for x =  1:length(folders2Process)
    try
        load([folders2Process(x).folder '\experimentStructure.mat']);
        recordingLocations(x,:) = experimentStructure.currentPostion;
    catch
        recordingLocations(x,:) = [NaN NaN NaN];
    end
end

end