function PTB_Melanopsin_Mnky_Plexon(preStimTime, stimTime, postStimTime, numReps, useBackgroundScreen, doNotSendEvents)
% Visual stimulus script with uses Paul's sheeple arduino LED stimulator to
% flash blue and red light stimulus. Sends events out to the PLexon system
% with indivdual bit events (stim ON, stim OFF) via  Measurement
% Computing USB-1208FS
%
% Inputs: preStimTime - prestimulus time in seconds
%         stimTime - stimulus on time in seconds
%         postStimTime - inter trial interval in seconds
%         numReps - number of repeats of each stimulus
%         doNotSendEvents - Flag to no send events out through USB-1208FS,
%                           used for testing purposes

%% set up parameters of stimuli
clc
sca;

% digital On/Off numbers
onNum = 1;
offNum = 8;

backgroundColor = [0.5 0.5 0.5]; % gray

if nargin < 5 || isempty(useBackgroundScreen)
    useBackgroundScreen = 0;
end

if nargin < 6 || isempty(doNotSendEvents)
    doNotSendEvents = 0;
end

% set up USB-1208FS
if doNotSendEvents ==0
    daq =[];
    % set up DAQ
    if isempty(daq)
        clear PsychHID;
        daq = DaqDeviceIndex([],0);
    end
end

% open arduino
ardBoard = serial('COM5', 'BaudRate', 9600,'Terminator','CR/LF');
fopen(ardBoard);


dataDir = 'C:\Users\pgamlin\Desktop\PTB_Files\'; % save dir for timing files
timeSave = datestr(now,'yyyymmddHHMMSS');
indentString = 'MelanopsinMnky_';

stimCmpEvents = [1 1] ;

% levels = linspace(65535,0,numCnd+1);
% levelStim = levels(2:end);

% log stim level         blue   red
levelStim = ...
    [-0.5               65460  65466;
    0.5                 65272  65331;
    1.5                 64235  64150;
    2.5                 52895  51800];



% Add stim parameters to structure for saving
stimParams.preStimTime = preStimTime;
stimParams.stimTime = stimTime;
stimParams.postStimTime = postStimTime;
stimParams.numReps = numReps;
stimParams.numCnd = size(levelStim, 1) * 2;
stimParams.levelStim = levelStim;


if doNotSendEvents ==0
    save([dataDir 'stimParams_' timeSave '.mat'], 'stimParams');
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display total experiment predicted time and query continue.....

lengthofTrial = preStimTime + stimTime + postStimTime + 1;
totalTrialNo = (size(levelStim, 1) * 2) * numReps;
totalTime = lengthofTrial * totalTrialNo;

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('');
disp(['This experiment will take approx. ' num2str(totalTime) 's (' num2str(totalTime/60) ' minutes)']);
disp('If you want to procceed press SPACEBAR, if you want to CANCEL, pres ESC');
disp('');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

[secs, keyCode, deltaSecs] = KbWait([],2, inf);

keypressNo = find(keyCode);

if keypressNo == 27 % ESC code = 27
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% start experiment

% set up screen
if useBackgroundScreen == 1
    
    Screen('Preference', 'VisualDebugLevel', 0); % removes welcome screen
    Screen('Preference','SkipSyncTests', 0);
    PsychDefaultSetup(2); % PTB defaults for setup
    
    screenNumber = max(Screen('Screens')); % makes display screen the secondary one
    PsychImaging('PrepareConfiguration');
    
    % try to open screen, can have issues on windows, so retry till it works
    count = 0;
    errorCount = 0;
    while count == errorCount
        try
            [windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, backgroundColor); %opens screen and sets background color
        catch
            disp(['Screen opening error detected......retrying']);
            errorCount = errorCount+1;
        end
        count = count+1;
    end
    
    % load gamma table
    try
        load 'C:\All Docs\calibrations\gammaTableGamma.mat'
    catch
        load 'C:\PostDoc Docs\Two Photon Rig\calibrations\LCD monitor\gammaTableGamma.mat'
    end
    
    oldTable = Screen('LoadNormalizedGammaTable', windowPtr, gammaTable1*[1 1 1]);
    
end


if doNotSendEvents ==0
    DaqDConfigPort(daq,0,0); % configure port A for output
    %     DaqDConfigPort(daq,1,1) % configure port B for input
end


experimentStartTime = tic;
for currentBlkNum = 1:numReps
    counter = 0;
    for trialCnd = 1:size(levelStim,1)
        for channel = 9:10
            counter = counter +1;
            % get current time till estimated finish
            currentTimeUsed = toc(experimentStartTime);
            timeLeft = (totalTime - currentTimeUsed)/60;
            
            if channel == 9
                channelText = 'Blue';
            elseif channel == 10
                channelText = 'Red';
            end
            
            if doNotSendEvents ==0
                %                 AnalogueOutEvent(daq, 'TRIAL_START');
                stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_START');
            end
            
            
            %display trial conditions
            
            fprintf(['Block No: %i of %i \n'...
                'Condition No: %i of %i \n' ...
                'LED Color: %s \n' ...
                'Intensity: %.1f log \n'...
                'Estimated Time to Finish = %.1f minutes \n' ...
                '############################################## \n'] ...
                ,currentBlkNum, numReps, counter, size(levelStim,1)*2, channelText, levelStim(trialCnd,1),  timeLeft);
            
            
            
            if doNotSendEvents ==0
                % send out cnds to imaging comp
                %                 AnalogueOutEvent(daq, 'PARAM_START');
                stimCmpEvents(end+1,:)= addCmpEvents('PARAM_START');
                %                 AnalogueOutCode(daq, currentBlkNum); % block num
                stimCmpEvents(end+1,:)= addCmpEvents(currentBlkNum);
                WaitSecs(0.001);
                %                 AnalogueOutCode(daq, trialCnd); % condition num
                stimCmpEvents(end+1,:)= addCmpEvents(trialCnd);
                WaitSecs(0.001);
                %                 AnalogueOutEvent(daq, 'PARAM_END');
                stimCmpEvents(end+1,:)= addCmpEvents('PARAM_END');
            end
            
            if doNotSendEvents ==0
                %                 AnalogueOutEvent(daq, 'PRESTIM_ON');
                stimCmpEvents(end+1,:)= addCmpEvents('PRESTIM_ON');
            end
            
            WaitSecs(preStimTime);
            
            if doNotSendEvents ==0
                %                 AnalogueOutEvent(daq, 'PRESTIM_OFF');
                stimCmpEvents(end+1,:)= addCmpEvents('PRESTIM_OFF');
            end
            
            melanopsinStimON(ardBoard, channel ,levelStim(trialCnd, channel-7),stimTime*1000);
            
            if doNotSendEvents ==0
                %                 AnalogueOutEvent(daq, 'STIM_ON');
                WaitSecs(1);
                err = DigiOut(daq, 0, onNum, 0.1);
                stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
            end
            
            WaitSecs(stimTime-0.1);
            
            if doNotSendEvents ==0
                %                 AnalogueOutEvent(daq, 'STIM_OFF');
                err = DigiOut(daq, 0, offNum, 0.1);
                stimCmpEvents(end+1,:)= addCmpEvents('STIM_OFF');
            end
            
            WaitSecs(postStimTime);
            
            if doNotSendEvents ==0
                %                 AnalogueOutEvent(daq, 'TRIAL_END');
                stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_END');
            end
            
            % Abort requested? Test for keypress:
            if KbCheck
                break;
            end
        end
        % Abort requested? Test for keypress:
        if KbCheck
            break;
        end
    end
    % Abort requested? Test for keypress:
    if KbCheck
        break;
    end
end

toc(experimentStartTime);

fclose(ardBoard);
clear ardBoard

%% save things before close
if doNotSendEvents ==0
    saveCmpEventFile(stimCmpEvents, dataDir, indentString, timeSave);
end

if useBackgroundScreen == 1
    Screen('LoadNormalizedGammaTable', windowPtr, oldTable);
    % Clear screen
    sca;
end
end