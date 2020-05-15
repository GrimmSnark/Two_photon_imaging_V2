function recordingLocations = grabRecordingLocationsXYZ(experimentDayFilepath)


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