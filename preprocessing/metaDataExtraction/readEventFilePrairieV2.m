function eventArray = readEventFilePrairieV2(dataFilepath, keyFilepath)
% reads prairie event file and decodes analogue signal into discrete levels
% of stimcode.
% NB THIS VERSION IS NON FUNCTIONAL!!!!!!!
%
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
    keyFilepath='C:\PostDoc Docs\code\matlab\Two_photon_imaging_V2\preprocessing\metaDataExtraction\PrairieVoltageInfo.mat';
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
%get the rising edge peaks for square wave signals
eventDataDirvative = gradient(rawEventData(:,2));
[~, eventDataLocRising]= findpeaks(eventDataDirvative, 'MinPeakHeight', 0.006 , 'MinPeakDistance', 10);

eventDataDirvative = gradient(rawEventData(:,2)) * -1;
[~, eventDataLocFalling]= findpeaks(eventDataDirvative, 'MinPeakHeight', 0.006 , 'MinPeakDistance', 10);


% remove rising and falling edges are very close, ie within 3 samples

count = 1;
events2RemoveRising =[];
events2RemoveFalling = [];
for i = 1:length(eventDataLocRising)
    
     diffValues = eventDataLocFalling-eventDataLocRising(i);
    diffValues = diffValues(diffValues> 0);
    
    if any(diffValues <4)
        events2RemoveFalling(count) = find(diffValues <4);
        events2RemoveRising(count) = i;
        count = count +1;
    end
end

eventDataLocRising(events2RemoveRising) = [];
eventDataLocFalling(events2RemoveFalling) = [];


%% check to see whether the there is a mismatch of rising and falling edge numbers

% If there is only a single difference, finds and removes
if abs(length(eventDataLocFalling)-length(eventDataLocRising)) ==1
    if length(eventDataLocFalling)> length(eventDataLocRising)
        testDiff = eventDataLocFalling(1:end-1)- eventDataLocRising;
        l = find(testDiff < 0, 1);
        eventDataLocFalling(l) =[];
    else
        testDiff = eventDataLocRising(1:end-1)- eventDataLocFalling;
        l = find(testDiff < 0, 1);
        eventDataLocRising(l) =[];
    end
    
    eventDataLocRisingFilt = eventDataLocRising;
    eventDataLocFallingFilt = eventDataLocFalling;
else
    
    % check rising and falling edges are within sensible bound, ie at the edges
    % of the square wave
    
    shortLimit = 10;
    longLimit = 55;
    
    % for every rising edge
    count = 1;
    for i = 1:length(eventDataLocRising)
        
        diffValues = eventDataLocFalling-eventDataLocRising(i);
        diffValues = diffValues(diffValues> 0);
        
        if ~isempty(find(diffValues >= shortLimit & diffValues <= longLimit,1))
            eventDataLocRisingFilt(count) = eventDataLocRising(i);
            count = count +1;
        else
            spaceFill = 1;
        end
    end
    
    % for every falling edge
    count = 1;
    for i = 1:length(eventDataLocFalling)
        
        diffValues = eventDataLocRisingFilt-eventDataLocFalling(i);
        diffValues = diffValues(diffValues< 0);
        
        if ~isempty(find(diffValues < -shortLimit & diffValues > -longLimit,1))
            eventDataLocFallingFilt(count) = eventDataLocFalling(i);
            count = count +1;
        end
    end
    
    % if the number of rising edges is more than falling edges
    while length(eventDataLocRisingFilt) > length(eventDataLocFallingFilt)
        
        for q = 2:length(eventDataLocRisingFilt)
            % checks whether the rising edge event is detected before or after the
            % previous falling edge event
            if eventDataLocRisingFilt(q) < eventDataLocFallingFilt(q-1)
                eventDataLocRisingFilt(q) = [];
                break
            else
            end
        end
    end
end


% plot(rawEventData(:,2));
% hold on
% scatter(eventDataLocRisingFilt +1, rawEventData(eventDataLocRisingFilt +1, 2),'g');
% scatter(eventDataLocFallingFilt -1, rawEventData(eventDataLocFallingFilt -1, 2),'r');
% 
% scatter(eventDataLocRising +1, rawEventData(eventDataLocRising +1, 2),'g');
% scatter(eventDataLocFalling -1, rawEventData(eventDataLocFalling -1, 2),'r');

% 
% adds 1 to make sure we are on the square wave plateau and means the
% plateau
for x = 1:length(eventDataLocRisingFilt)
    
    eventArrayVoltage(x,1)   = rawEventData(eventDataLocRisingFilt(x)+1,1);
    eventArrayVoltage(x,2) = median(rawEventData(eventDataLocRisingFilt(x)+1:eventDataLocFallingFilt(x)-2,2));
    
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