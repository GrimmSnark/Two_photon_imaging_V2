function eventArray = readEventFilePrairie(dataFilepath, keyFilepath)
% reads prairie event file and decodes analogue signal into discrete levels
% of stimcode.
% Inputs-  dataFilepath: fullfile of voltage csv file
%
%          keyFilePath: voltage level key calculated in previous from
%          readEventFileSetup.mat
%
% Output- eventArray: 2D array of timestamps and decoded event numbers from
%         the experiment (timestamp x event)
%
% NB: If getting decoding errors continuously examine analogue cables from
% USB Daq and maybe rerun readEventFileSetup and change keyFile.

%% set up
if nargin <2 || isempty(keyFilepath)
    keyFilepath='C:\PostDoc Docs\code\matlab\Two_photon_imaging_clean\preprocessing\metaDataExtraction\PrairieVoltageInfo.mat';
end

plotRawPeaks = 0; % set to 1 to view raw peak detection
plotDecodedValues = 0; % set to 1 to viewevent decoded from raw voltages (very slow)

%% load in data
%load keyfile
load(keyFilepath);

%read out voltage data
data = readVoltageFile(dataFilepath);
rawEventData = data.Voltage;

%% get peaks
%get the peaks for square wave signals
eventDataDirvative = gradient(rawEventData(:,2));
[~, eventDataLoc]= findpeaks(eventDataDirvative, 'MinPeakHeight', 0.005 , 'MinPeakDistance', 10);

% adds 1 to make sure we are on the square wave plateau and means the
% plateau
for x = 1:length(eventDataLoc)
    
    eventArrayVoltage(x,1)   = rawEventData(eventDataLoc(x)+1,1);
    eventArrayVoltage(x,2) = median(rawEventData(eventDataLoc(x)+1:eventDataLoc(x)+20,2));
    
end

% plot raw peak detection if wanted
if plotRawPeaks == 1
    plotHandle =  handle(plot(rawEventData(:,1),rawEventData(:,2)));
    plotAxis = gca;
    hold on
    scatter( plotAxis, eventArrayVoltage(:,1), eventArrayVoltage(:,2), 'r');
    scrollplot(plotHandle);
    pause;
end

%% decode events
% prep Event array with the timepoints
eventArray(:,1) = eventArrayVoltage(:,1);

% set signal error factor
errorLimit = Prairie.std;

%remove baseline offset
minValue = mean(rawEventData(500:1000,2))/2;
eventArrayVoltage(:,2) = eventArrayVoltage(:,2)-minValue;


%convert voltages to event numbers
for i=1:length(eventArrayVoltage)
    
    %tries to find event peak voltage level in look up table
    tempLevel=Prairie.VoltageLevels((eventArrayVoltage(i,2)>= Prairie.VoltageLevels(:,2)-errorLimit &  eventArrayVoltage(i,2) <=Prairie.VoltageLevels(:,2)+errorLimit),1);
    
    counter = 1;
    % if it can't find it widens search parameters by number of standard
    % deviations
    while isempty(tempLevel)
        
        tempLevel=Prairie.VoltageLevels((eventArrayVoltage(i,2)>= Prairie.VoltageLevels(:,2)-(errorLimit+ counter*Prairie.std) &  eventArrayVoltage(i,2) <=Prairie.VoltageLevels(:,2)+(errorLimit+counter*Prairie.std)),1);
        
        counter = counter+1;
    end
    
    % once found, if more than one match takes the lowest number
    if length(tempLevel)>1
        
        eventArray(i,2) = tempLevel(1);
    else % if tempLevel is single number..
        eventArray(i,2)= tempLevel;
        
    end
end


% Plot voltage trace and decoded event number ident (is very slow)
if plotDecodedValues ==1
    plotHandleEnd = plot(rawEventData(:,1),rawEventData(:,2));
    % plot(1:length(rawEventData),rawEventData(:,2));
    hold on
    plotHandleAx = gca;
    text(plotHandleAx, eventArray(:,1), eventArrayVoltage(:,2), num2str(eventArray(:,2)));
    scrollplot(plotHandleEnd);
    pause;
end
end