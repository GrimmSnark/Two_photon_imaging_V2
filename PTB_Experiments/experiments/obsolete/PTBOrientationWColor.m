function PTBOrientationWColor(width, stimCenter, preStimTime, stimTime, rampTime, numReps, varargin)
% Experiment which displays moving gratings at 2Hz
%
% options width (degrees) for full screen leave blank
% stimCenter [0,0] (degrees visual angle from screen center)
% pre stimulus spontaneous activity period (preStimTime, in seconds)
% stim time (seconds)
% dropRed 1/0 (drops the red channel completely, useful as mice do not see
% red)
% numReps (number of blocks of all stim repeats, if blank is infinite)
% varargin (if filled DOES NOT send events out via DAQ)


%% set up parameters of stimuli
clc
sca;


doNotSendEvents = 0;
fullfieldStim = 0;

if ~isempty(varargin)
    doNotSendEvents = 1;
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
indentString = 'OrientationWColor_';

% stimTime = 1; %in s
ITItime = 10; % intertrial interval in seconds
% firstTime =1;
blockNum = 0;
stimCmpEvents = [1 1] ;

phase = 0;

backgroundGreen = 0.5*0.7255; 
backgroundColorOffsetCy = [0 backgroundGreen 0.5 1]; %RGBA offset color
blueMax = 1;
greenMax = 0.7255;

%Stimulus
%width = 10; % in degrees visual angle
widthInPix = degreeVisualAngle2Pixels(2,width);
heightInPix =widthInPix;
radius=widthInPix/2; % circlar apature in pixels

%spatial frequency
freq = 0.05 ; % in cycles per degree
freq = 1/freq; % hack hack hack
freqPix = degreeVisualAngle2Pixels(2,freq);
freqPix =1/freqPix; % use the inverse as the function below takes bloody cycles/pixel...

cyclespersecond =1; % temporal frequency to stimulate all cells (in Hz)

contrast =  0.7 ; % contrast for grating
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Angle =[0    45    90   135   180   225   270   315  0    45    90   135   180   225   270   315]; % angle in degrees

numCnd = length(Angle); % conditions = angle x colors

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
Screen('Preference', 'VisualDebugLevel', 1); % removes welcome screen
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

% screenXpixels = 1915; % hard coded cause reasons.. weird screens % comment out for your setup
% screenYpixels = 1535;

screenCentre = [0.5 * screenXpixels , 0.5 * screenYpixels]; % screen centre of Shel 1170 WEIRD, calcualted by physical measurement...
% Set up relative stim centre based on degree visual angle

screenStimCentreOffset(1) = degreeVisualAngle2Pixels(2,stimCenter(1));
screenStimCentreOffset(2) = degreeVisualAngle2Pixels(2,stimCenter(2));

screenStimCentre = screenCentre + screenStimCentreOffset;

% Define grey
grey = [0 backgroundGreen 0.5];

PsychImaging('PrepareConfiguration');

% look into PsychImaging('AddTask', 'General', 'UseGPGPUCompute', apitype [, flags]);???

PsychImaging('AddTask','General', 'FloatingPoint32Bit'); % sets accuracy of frame buffer to 32bit floating point

[windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, [ grey ] ); %opens screen and sets background to grey

% load gamma table
try
    load 'C:\All Docs\calibrations\gammaTableGamma.mat'
catch
    load 'C:\PostDoc Docs\Two Photon Rig\calibrations\LCD monitor\gammaTableGamma.mat'
end
Screen('LoadNormalizedGammaTable', windowPtr, gammaTable1*[1 1 1]);

%create all gratings on GPU.....should be very fast
if fullfieldStim ==0
    [gratingidG, gratingrectG] = CreateProceduralSineGrating(windowPtr, widthInPix, heightInPix, backgroundColorOffsetCy, radius, contrast);
    [gratingidB, gratingrectB] = CreateProceduralSineGrating(windowPtr, widthInPix, heightInPix, backgroundColorOffsetCy, radius, contrast);
else
    [gratingidG, gratingrectG] = CreateProceduralSineGrating(windowPtr, screenXpixels*1.5, screenXpixels*1.5, backgroundColorOffsetCy, [], contrast);
    [gratingidB, gratingrectB] = CreateProceduralSineGrating(windowPtr, screenXpixels*1.5, screenXpixels*1.5, backgroundColorOffsetCy, [], contrast);
end


% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', windowPtr);

% Get frame rate fro moving patch
frameRate=Screen('FrameRate',screenNumber);

% Get the number of frames stim needs to be on for
totalNumFrames = frameRate * stimTime;

% Get number of frames for prestimulus time
preStimFrames = frameRate * preStimTime;

% Compute increment of phase shift per redraw:
phaseincrement = (cyclespersecond * 360) * ifi;

% Get frame number to interate over contrast ramp
contrast_rampFrames = frameRate *  rampTime;
contrastLevels = linspace(0, contrast, contrast_rampFrames);


%% START STIM PRESENTATION

HideCursor(windowPtr, []);

if doNotSendEvents ==0
    % trigger image scan start with digital port A
    DaqDConfigPort(daq,0,0); % configure port A for output
    err = DigiOut(daq, 0, 255, 0.1);
    
    DaqDConfigPort(daq,1,1) % configure port B for input
end

while ~KbCheck
    tic;
    for currentBlkNum = 1:numReps
        % randomizes the order of the conditions for this block
        cndOrder = datasample(1:numCnd,numCnd,'Replace', false);
        blockNum = blockNum+1;
        
        for trialCnd = 1:length(cndOrder)
            
            
            if cndOrder(trialCnd) <9
                colorThisTrial = 'Green';
                modulateCol = [0 greenMax  0.5];
                modualteColRamp = linspace(backgroundGreen, greenMax, contrast_rampFrames);
            else
                colorThisTrial = 'Blue';
                modulateCol = [0 backgroundGreen blueMax];
            end
            
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'TRIAL_START');
                stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_START');
            end
            
            % Get trial cnds
            trialParams = Angle(cndOrder(trialCnd));
            
            if fullfieldStim ==0
                dstRect = OffsetRect(gratingrect, screenStimCentre(1)-radius, screenStimCentre(2)-radius);
            else
                dstRect = [];
            end
            %display trial conditions
            
            fprintf(['Block No: %i \n'...
                'Condition No: %i \n'...
                'Trial No: %i of %i \n' ...
                'Orientation: %i degrees \n'...
                'Color: %s \n'...
                '############################################## \n'] ...
                ,blockNum,cndOrder(trialCnd), trialCnd, length(cndOrder), trialParams(1), colorThisTrial);
            
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
            
            % blank screen flips for prestimulus time period
            if doNotSendEvents ==0
                
                AnalogueOutEvent(daq, 'PRESTIM_ON');
                stimCmpEvents(end+1,:)= addCmpEvents('PRESTIM_ON');
            end
            
            for prestimFrameNp = 1:preStimFrames
                Screen('Flip', windowPtr);
            end
            
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'PRESTIM_OFF');
                stimCmpEvents(end+1,:)= addCmpEvents('PRESTIM_OFF');
            end
            
            stimOnFlag =1;
            % start constrast ramp on
            if rampTime > 0
                for frameNo =1:contrast_rampFrames
                    % Increment phase by cycles/s:
                    phase = phase + phaseincrement;
                    %create auxParameters matrix
                    propertiesMat = [phase, freqPix, contrastLevels(frameNo), 0];
                    % draw grating on screen
                    %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
                    
                    if doNotSendEvents ==0
                        if stimOnFlag ==1 % only sends stim on at the first draw of moving grating
                            AnalogueOutEvent(daq, 'STIM_ON');
                            stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
                            stimOnFlag = 0;
                        end
                    end
                    
                    if cndOrder(trialCnd) <9
                        Screen('DrawTexture', windowPtr, gratingidG, [], dstRect , Angle(cndOrder(trialCnd)), [] , [], [modulateCol], [], [], propertiesMat' );
                    else
                        Screen('DrawTexture', windowPtr, gratingidB, [], dstRect , Angle(cndOrder(trialCnd)), [] , [], [modulateCol], [], [], propertiesMat' );
                    end
                    Screen('Flip', windowPtr);
                end
            end
            
            for frameNo =1:totalNumFrames % stim presentation loop
                % Increment phase by cycles/s:
                phase = phase + phaseincrement;
                %create auxParameters matrix
                propertiesMat = [phase, freqPix, contrast, 0];
                
                % draw grating on screen
                %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
                
                if cndOrder(trialCnd) <9
                    Screen('DrawTexture', windowPtr, gratingidG, [], dstRect , Angle(cndOrder(trialCnd)), [] , [], [modulateCol], [], [], propertiesMat' );
                else
                    Screen('DrawTexture', windowPtr, gratingidB, [], dstRect , Angle(cndOrder(trialCnd)), [] , [], [modulateCol], [], [], propertiesMat' );
                end
                
                if doNotSendEvents ==0
                    if rampTime == 0
                        if stimOnFlag ==1 % only sends stim on at the first draw of moving grating
                            AnalogueOutEvent(daq, 'STIM_ON');
                            stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
                            stimOnFlag = 0;
                        end
                    end
                end
                
                %             Screen('DrawDots', windowPtr, screenCentre, [5], [1 0 0], [] , [], []); % Fixation/ screen centre spot
                
                % Flip to the screen
                if doNotSendEvents ==0
                    AnalogueOutEvent(daq, 'SCREEN_REFRESH');
                    stimCmpEvents(end+1,:)= addCmpEvents('SCREEN_REFRESH');
                end
                Screen('Flip', windowPtr);
                
%                 % Abort requested? Test for keypress:
                if KbCheck
                    break;
                end
%                 
            end % end stim presentation loop
            
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
            %             Screen('Flip', windowPtr);
            
            if rampTime > 0
                % start constrast ramp off
                for frameNo =contrast_rampFrames:-1:1
                    % Increment phase by cycles/s:
                    phase = phase + phaseincrement;
                    %create auxParameters matrix
                    propertiesMat = [phase, freqPix, contrastLevels(frameNo), 0];
                    % draw grating on screen
                    %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
                    
                    if cndOrder(trialCnd) <9
                        Screen('DrawTexture', windowPtr, gratingidG, [], dstRect , Angle(cndOrder(trialCnd)), [] , [], [modulateCol], [], [], propertiesMat' );
                    else
                        Screen('DrawTexture', windowPtr, gratingidB, [], dstRect , Angle(cndOrder(trialCnd)), [] , [], [modulateCol], [], [], propertiesMat' );
                    end
                    Screen('Flip', windowPtr);
                end
                
                if doNotSendEvents ==0
                    AnalogueOutEvent(daq, 'STIM_OFF');
                    stimCmpEvents(end+1,:)= addCmpEvents('STIM_OFF');
                end
                
            end
            
            Screen('Flip', windowPtr);
            
            WaitSecs(ITItime);
            
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'TRIAL_END');
                stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_END');
            end
        end
        % Abort requested? Test for keypress:
        if KbCheck
            break;
        end
    end % end number of blocks
    toc;
    break % breaks when reaches requested number of blocks
end

%% save things before close
if doNotSendEvents ==0
    saveCmpEventFile(stimCmpEvents, dataDir, indentString, timeSave);
end

ShowCursor([],[windowPtr],[]);

% Clear screen
sca;
end

