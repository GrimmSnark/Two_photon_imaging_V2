function readEventFileSetupV2(filepathData)
% This function analyses the output from testDAQOutSignal.m and produces a
% look up table file (PrairieVoltageInfo.mat) for actual voltage levels to
% correspond to event numbers used in experiments. This should only need to
% be run at the installation of the toolbox.
% filepathData is the fullfile string of the voltage recording .csv OR cell
% string s x 1 for multiple .csv  voltage files from multiple runs of
% testDAQOutSignal.m
% This function should output to the save location for the look up table
% (should be saved in the basicfunctions folder as PrairieVoltageInfo.mat)

%% hard codes from inital writing
% filepathData = 'C:\PostDoc Docs\Ca Imaging Project\Voltage Recording Test 3\Voltage Test 2ms-001\Voltage Test 2ms-001_Cycle00001_VoltageRecording_001.csv';
%  
% filepathData{1,1}= 'C:\PostDoc Docs\Ca Imaging Project\Voltage Recording Test 3\Voltage Test 2ms-001\Voltage Test 2ms-001_Cycle00001_VoltageRecording_001.csv';
% filepathData{2,1}= 'C:\PostDoc Docs\Ca Imaging Project\Voltage Recording Test 3\Voltage Test 2ms-002\Voltage Test 2ms-002_Cycle00001_VoltageRecording_001.csv';
% % 
 %filepathData = 'C:\PostDoc Docs\Ca Imaging Project\Voltage Recording Test 4\TSeries-09262018-1149-015\TSeries-09262018-1149-015_Cycle00001_VoltageRecording_001.csv';
 
 % 20200130
%  filepathData = 'D:\Data\2P_Data\Raw\Calibration\TTL_test\20200130\TSeries-01302020-0806-000\TSeries-01302020-0806-000_Cycle00001_VoltageRecording_001.csv';
 
 % 20210709
 filepathData = 'D:\Data\2P_Data\Raw\Mouse\gCamp6s\AAVretro_LS_M4\sigTest\TSeries-07092021-0848-003\TSeries-07092021-0848-003_Cycle00001_VoltageRecording_001.csv';


%% basic setup info

% work out savefile location
functionPath = mfilename('fullpath');
out=regexp(functionPath,'\','split');

filepathSave =[];
for i =1:length(out)-1
   filepathSave =  [filepathSave '\' out{1,i}];
end
filepathSave = [filepathSave(2:end) '\PrairieVoltageInfo.mat'];

minimumPeakNum =255; % number of voltage levels to find (255 + 0V level =256, ie 8 bit)

if ischar(filepathData) % if there is a single file
    data = readVoltageFile(filepathData);
elseif iscell(filepathData) % if there are multiple files, concatenate voltages
   data.Voltage  =[];
    for i = 1:length(filepathData)
        tempData = readVoltageFile(filepathData{i,1});
        data.Voltage = vertcat(data.Voltage, tempData.Voltage); 
    end
    data.headers = tempData.headers;
end

 rawEventData = data.Voltage;
 
 rawEventData = rawEventData(1:length(rawEventData)/2,:);
 %% do the peak detection
% find first and last peak of every burst...

% all peaks

gradData = gradient(rawEventData(:,2));
[peaks, peakGradValues]= findpeaks(gradData, 'MinPeakHeight', 0.006 );
% 
% plot(1:length(rawEventData(:,2)), rawEventData(:,2))
% hold on
% scatter(peakGradValues+1, rawEventData(peakGradValues+1,2), 'v');
% 
% peakValues =  rawEventData(peakGradValues+1,2)

incrementAll = peaks(2:end)-peaks(1:end-1);
incrementAll(incrementAll < 0.001) = NaN;
incrementAll(incrementAll == 0) = NaN;
increment = mean(incrementAll, 'omitnan');

% last peaks of bursts
removeMaximums = rawEventData(:,2) > 4.110001;
rawEventDataLasts = rawEventData;
rawEventDataLasts(removeMaximums,2) = 0;
[lastPeaks, lastLocs]= findpeaks(rawEventData(:,2), 'MinPeakHeight', max(rawEventDataLasts(:,2))-increment, 'MinPeakDistance', 1000 );


% use last peaks to find the first peaks of the following burst
for x = 1:length(lastPeaks)-1
    
   tempPeaks =  peakGradValues(peakGradValues > lastLocs(x));
   firstLocs(x) =  tempPeaks(1);
end

% plot(1:length(rawEventData(:,2)), rawEventData(:,2))
% hold on
% scatter(firstLocs+1, rawEventData(firstLocs+1,2), 'v');



% %first peaks of bursts
% removeMaximums = rawEventData(:,2) >= round(increment,2)-0.00015;
% rawEventDataFirsts = rawEventData;
% rawEventDataFirsts(removeMaximums,2) = 0;
% [firstPeaks, firstLocs]= findpeaks(rawEventDataFirsts(:,2), 'MinPeakHeight', 0.0001, 'MinPeakDistance', 25000);


% uncomment below if you want to plot the raw data together

plot(1:length(rawEventData(:,2)), rawEventData(:,2))
hold on
scatter(firstLocs, rawEventData(firstLocs,2), 'v');
scatter(lastLocs, lastPeaks, 'v', 'r');
% plot(1:length(rawEventData(:,2)), rawEventDataFirsts(:,2));



% segement out peak bursts between first and last
for i =1:length(lastLocs)-1
    
    chunkedData(1:length(rawEventData(firstLocs(i)-100: lastLocs(i+1)+50 ,2)),i) = rawEventData(firstLocs(i)-100: lastLocs(i+1)+50 ,2);
    
end

%% use derivative of peaks to find the on slope of bursts for each chunk of data
for i = 1: length(nonzeros(chunkedData(1,:))) % for each burst
    
    % calculate peaks derivative 
    chunkDirvative = gradient(chunkedData(:,i));
    
    [~, tempLocsDir]= findpeaks(chunkDirvative, 'MinPeakHeight', 0.006 ); % find peaks based on the derivative
    
    chunkPeaksDir(1:length(chunkedData(tempLocsDir+1,i)),i) = chunkedData(tempLocsDir+1,i); % find the value of on of square wave +1 sample to accound for off by one error
    chunkLocsDir(1:length(tempLocsDir),i) = tempLocsDir; % colllate the index value of the peaks
    
end

% if any burst does not have all of the voltage levels, this section omits
% them
count =1;
for i=1:size(chunkPeaksDir,2)
    if length(nonzeros(chunkPeaksDir(:,i)))==minimumPeakNum
        
        peakDir(:,count)=chunkPeaksDir(:,i);
        LocsDir(:,count)= chunkLocsDir(:,i);
        count =count+1;
    end
end


% uncomment to examine individual burst val = x

% x = 94;
% plot(1:length(chunkedData(:,x)),chunkedData(:,x));
% hold on
% scatter(chunkLocsDir(:,x), chunkedData(chunkLocsDir(:,x)+1,x), 'v', 'r');

%means and std of the voltage levels
meanPeaks = mean(peakDir,2);
stdPeaks = std(peakDir');

% plots the means and stds
errorbar(meanPeaks, stdPeaks, 'o');

%% wrap up
% preps structure for saving
Prairie.VoltageLevels = horzcat((1:1:255)' , meanPeaks);
Prairie.std = mean(stdPeaks);

% save structure
save(filepathSave, 'Prairie');

end


