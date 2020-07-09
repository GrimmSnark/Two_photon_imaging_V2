function PTBContrastVSOri(width, stimCenter,  preStimTime, stimTime, rampTime,  numReps, dropRed, doNotSendEvents)
% Visual stimulus script which presents moving sinsuiodal gratings of
% different orientations and contrasts
%
% Inputs: width - size of stimulus in degrees, leave blank for full screen
%                 stim
%         stimCenter - degrees visual angle from screen center[x,y]
%         preStimTime - prestimulus time in seconds
%         stimTime - stimulus on time in seconds
%         rampTime - stimulus ramp on/off time in seconds, increases in
%                    constrast over this time to the max contrast
%         numReps - number of repeats of each stimulus
%         dropRed - 1/0 flag to drop the red channel from the stimulus and
%                   background as mice do not see red (1 = drop,
%                   0 = include red)
%         doNotSendEvents - Flag to no send events out through USB-1208FS,
%                           used for testing purposes


%% set up parameters of stimuli
clc
sca;


fullfieldStim = 0;

if nargin < 8 || isempty(doNotSendEvents)
    doNotSendEvents = 0;
end

if isempty(numReps)
    numReps = Inf;
end

if isempty(width)
    fullfieldStim =1;
    width = 0;
end

if isempty(rampTime)
    rampTime = 0;
end

% Should not change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataDir = 'C:\PostDoc Docs\Ca Imaging Project\PTB_Timing_Files\'; % save dir for timing files
timeSave = datestr(now,'yyyymmddHHMMSS');
indentString = 'ContrstOrient_';

ITItime = 2;
firstTime =1;
blockNum = 0;
stimCmpEvents = [1 1] ;

phase = 0;
if dropRed ==1
    backgroundColorOffset = [0 0.5 0.5 0]; %RGBA offset color
    modulateCol = [0 1  1];
else
    backgroundColorOffset = [0.5 0.5 0.5 0]; %RGBA offset color
    modulateCol = [1 1 1];
end

%Stimulus
%width = 10; % in degrees visual angle
widthInPix = degreeVisualAngle2Pixels(3,width);
heightInPix =widthInPix;
radius=widthInPix/2; % circlar apature in pixels

freq = 0.05 ; % in cycles per degree
freq = 1/freq; % hack hack hack
freqPix = degreeVisualAngle2Pixels(3,freq);
freqPix =1/freqPix; % use the inverse as the function below takes bloody cycles/pixel...

cyclespersecond =1; % temporal frequency to stimulate all cells
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

contrast = [0.2 0.4 0.6 0.8 1] ; % should already be set by the sine grating creation??
orientations =[0    45    90   135   180   225   270   315]; % angle in degrees


Angle =repmat(orientations,[1 length(contrast)]); % angle in degrees x number of constrasts
numCnd = length(Angle); % conditions = angle x constrasts


% Add stim parameters to structure for saving
stimParams.width = width;
stimParams.stimCenter = stimCenter;
stimParams.preStimTime = preStimTime;
stimParams.stimTime = stimTime;
stimParams.rampTime = rampTime;
stimParams.numReps = numReps;
stimParams.dropRed = dropRed;
stimParams.freq = freq;
stimParams.ITItime = ITItime;
stimParams.cyclespersecond = cyclespersecond;
stimParams.contrast = contrast;
stimParams.Angle = Angle;

save([dataDir 'stimParams_' timeSave '.mat'], 'stimParams');
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display total experiment predicted time and query continue.....

lengthofTrial = preStimTime + stimTime + rampTime*2 + ITItime;
totalTrialNo = numCnd * numReps;
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



%% intial set up of experiment
Screen('Preference', 'VisualDebugLevel', 0); % removes welcome screen
PsychDefaultSetup(2); % PTB defaults for setup

if doNotSendEvents ==0
    daq =[];
    
    % set up DAQ
    if isempty(daq)
        clear PsychHID;
        daq = DaqDeviceIndex([],0);
    end
end

screenNumber = max(Screen('Screens')); % makes display screen the secondary one
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', screenNumber); % uncomment for your setup
screenCentre = [0.5 * screenXpixels , 0.5 * screenYpixels]; % screen centre

% Set up relative stim centre based on degree visual angle

screenStimCentreOffset(1) = degreeVisualAngle2Pixels(3,stimCenter(1));
screenStimCentreOffset(2) = degreeVisualAngle2Pixels(3,stimCenter(2));

screenStimCentre = screenCentre + screenStimCentreOffset;

% Define black, white and grey
white = WhiteIndex(screenNumber);

if dropRed == 1
    grey = [0 0.5 0.5];
else
    grey = white / 2;
end

PsychImaging('PrepareConfiguration');

% try to open screen, can have issues on windows, so retry till it works
count = 0;
errorCount = 0;
while count == errorCount
    try
        [windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, [ grey ] ); %opens screen and sets background to grey
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


%create all gratings on GPU.....should be very fast
if fullfieldStim ==0
    [gratingid, gratingrect] = CreateProceduralSineGrating(windowPtr, widthInPix, heightInPix, backgroundColorOffset, radius, 0.5);
else
    [gratingid, gratingrect] = CreateProceduralSineGrating(windowPtr, screenXpixels*1.5, screenXpixels*1.5, backgroundColorOffset, [], 0.5);
end

% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', windowPtr);
frameWaitTime = ifi - 0.5;

% Get frame rate fro moving patch
frameRate=Screen('FrameRate',screenNumber);

% Get the number of frames stim needs to be on for
totalNumFrames = frameRate * stimTime;

% Get number of frames for prestimulus time
preStimFrames = frameRate * preStimTime;

% Get frame number to interate over contrast ramp
contrast_rampFrames = round(frameRate *  rampTime);

% Compute increment of phase shift per redraw:
phaseincrement = (cyclespersecond * 360) * ifi;


%% Set up stimulus params per trial
counter =0;

if doNotSendEvents ==0
    % trigger image scan start
    DaqDConfigPort(daq,0,0);
    err = DigiOut(daq, 0, 255, 0.1);
    DaqDConfigPort(daq,1,1) % configure port B for input
end

vbl = Screen('Flip', windowPtr);
for currentBlkNum = 1:numReps
    
    % randomizes the order of the conditions for this block
    cndOrder = datasample(1:numCnd,numCnd,'Replace', false);
    blockNum = blockNum+1;
    
    for trialCnd = 1:length(cndOrder)
        
        % Get trial cnds
        trialParams = Angle(cndOrder(trialCnd)); % get angle identity
        indexForOrientation = find(Angle==trialParams, 1); % get index for that angle
        
        % get color condition
        currentContrastLevel = ceil(cndOrder(trialCnd)/length(orientations));
        
        % set current contast ramp increments
        contrastLevels = linspace(0, currentContrastLevel, contrast_rampFrames);
        
        
        if doNotSendEvents ==0
            AnalogueOutEvent(daq, 'TRIAL_START');
            stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_START');
        end
        
        if fullfieldStim ==0
            dstRect = OffsetRect(gratingrect, screenStimCentre(1)-radius, screenStimCentre(2)-radius);
        else
            dstRect = [];
        end
        
        % get current time till estimated finish
        currentTimeUsed = toc(experimentStartTime);
        timeLeft = (totalTime - currentTimeUsed)/60;
        
        
        %display trial conditions
        fprintf(['Block No: %i of %i \n'...
            'Condition No: %i \n'...
            'Trial No: %i of %i \n' ...
            'Orientation: %i degrees \n'...
            'Contrast: %.2f \n' ...
            'Estimated Time to Finish = %.1f minutes \n' ...
            '############################################## \n'] ...
            ,blockNum, numReps,cndOrder(trialCnd), trialCnd, length(cndOrder), trialParams(1), currentContrastLevel, timeLeft);
        
        
        if doNotSendEvents ==0
            % send out cnds to imaging comp
            AnalogueOutEvent(daq, 'PARAM_START');
            stimCmpEvents(end+1,:)= addCmpEvents('PARAM_START');
            AnalogueOutCode(daq, blockNum); % block num
            stimCmpEvents(end+1,:)= addCmpEvents(blockNum);
            WaitSecs(0.001);
            AnalogueOutCode(daq, cndOrder(trialCnd)); % condition num
            stimCmpEvents(end+1,:)= addCmpEvents(cndOrder(trialCnd));
            WaitSecs(0.001);
            AnalogueOutEvent(daq, 'PARAM_END');
            stimCmpEvents(end+1,:)= addCmpEvents('PARAM_END');
        end
        %% Prestim
        
        % blank screen flips for prestimulus time period
        if doNotSendEvents ==0
            
            AnalogueOutEvent(daq, 'PRESTIM_ON');
            stimCmpEvents(end+1,:)= addCmpEvents('PRESTIM_ON');
        end
        
        for prestimFrameNp = 1:preStimFrames
            vbl = Screen('Flip', windowPtr, vbl + frameWaitTime);
        end
        
        if doNotSendEvents ==0
            AnalogueOutEvent(daq, 'PRESTIM_OFF');
            stimCmpEvents(end+1,:)= addCmpEvents('PRESTIM_OFF');
        end
        
        %% Stim on
        % start constrast ramp on
        if rampTime > 0
            for frameNo =1:contrast_rampFrames
                % Increment phase by cycles/s:
                phase = phase + phaseincrement;
                %create auxParameters matrix
                propertiesMat = [phase, freqPix, contrastLevels(frameNo), 0];
                
                
                if doNotSendEvents ==0
                    if stimOnFlag ==1 % only sends stim on at the first draw of moving grating
                        AnalogueOutEvent(daq, 'STIM_ON');
                        stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
                        stimOnFlag = 0;
                    end
                end
                
                % draw grating on screen
                Screen('DrawTexture', windowPtr, gratingid, [], dstRect , Angle(cndOrder(trialCnd)), 0 , [], [modulateCol], [], [], propertiesMat' );
                Screen('DrawingFinished', windowPtr);
                
                vbl = Screen('Flip', windowPtr, vbl + frameWaitTime);
            end
        end
        
        stimOnFlag =1;
        for frameNo =1:totalNumFrames
            % Increment phase by cycles/s:
            phase = phase + phaseincrement;
            %create auxParameters matrix
            propertiesMat = [phase, freqPix, currentContrastLevel, 0];
            
            % draw grating on screen
            %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
            
            Screen('DrawTexture', windowPtr, gratingid(constrastNo), [], dstRect , Angle(angleNo), [], [], [], [], [], propertiesMat' );
            Screen('DrawingFinished', windowPtr);
            
            if doNotSendEvents ==0
                if stimOnFlag ==1 % only sends stim on at the first draw of moving grating
                    AnalogueOutEvent(daq, 'STIM_ON');
                    stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
                    stimOnFlag = 0;
                end
            end
            
            %             Screen('DrawDots', windowPtr, screenCentre, [5], [1 0 0], [] , [], []); % Fixation/ screen centre spot
            
            % Flip to the screen
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'SCREEN_REFRESH');
                stimCmpEvents(end+1,:)= addCmpEvents('SCREEN_REFRESH');
            end
            
            vbl = Screen('Flip', windowPtr, vbl + frameWaitTime);
            
            
            % Abort requested? Test for keypress:
            if KbCheck
                break;
            end
        end
        
        % Abort requested? Test for keypress:
        if KbCheck
            break;
        end
        
        if doNotSendEvents ==0
            if rampTime == 0
                AnalogueOutEvent(daq, 'STIM_OFF');
                stimCmpEvents(end+1,:)= addCmpEvents('STIM_OFF');
            end
        end
        
        if rampTime > 0
            % start constrast ramp off
            for frameNo =contrast_rampFrames:-1:1
                % Increment phase by cycles/s:
                phase = phase + phaseincrement;
                %create auxParameters matrix
                propertiesMat = [phase, freqPix, contrastLevels(frameNo), 0];
                % draw grating on screen
                Screen('DrawTexture', windowPtr, gratingid, [], dstRect , Angle(cndOrder(trialCnd)), 0 , [], [modulateCol], [], [], propertiesMat' );
                Screen('DrawingFinished', windowPtr);
                
                vbl = Screen('Flip', windowPtr, vbl + frameWaitTime);
            end
            
            
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'STIM_OFF');
                stimCmpEvents(end+1,:)= addCmpEvents('STIM_OFF');
            end
            
            %% Post Stim
            vbl = Screen('Flip', windowPtr, vbl + frameWaitTime);
            WaitSecs(ITItime);
            
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'TRIAL_END');
                stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_END');
            end
        end
    end
    
    %% save things before close
    if doNotSendEvents ==0
        saveCmpEventFile(stimCmpEvents, dataDir, indentString, timeSave);
    end
    
    % Clear screen
    sca;
end

