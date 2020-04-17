function PTBDutyCycle(dutyCycle, stimTime ,width, stimCenter, dropRed, numReps, varargin)
% Visual stimulus script which presents fullfield flicker stimulus 
%
% options width (degrees) for full screen leave blank
% stimCenter [0,0] (degrees visual angle from screen center)
% pre stimulus spontaneous activity period (preStimTime, in seconds)
% stim time (seconds)
% dropRed 1/0 (drops the red channel completely, useful as mice do not see
% red)
% numReps (number of blocks of all stim repeats, if blank is infinite)
% varargin (if filled DOES NOT send events out via DAQ)

% Visual stimulus script which presents moving sinsuiodal gratings of
% different orientations
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


% Should not change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataDir = 'C:\PostDoc Docs\Ca Imaging Project\PTB_Timing_Files\'; % save dir for timing files
timeSave = datestr(now,'yyyymmddHHMMSS');
indentString = 'DutyCycle_';

stimCmpEvents = [1 1] ;

if dropRed ==1
    Col = [0 1 1];
else
    Col = [1 1 1];
end

%Stimulus
widthInPix = degreeVisualAngle2Pixels(1,width);
heightInPix =widthInPix;
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

screenStimCentreOffset(1) = degreeVisualAngle2Pixels(1,stimCenter(1));
screenStimCentreOffset(2) = degreeVisualAngle2Pixels(1,stimCenter(2));

screenStimCentre = screenCentre + screenStimCentreOffset;

% Define black, white and grey

PsychImaging('PrepareConfiguration');

% look into PsychImaging('AddTask', 'General', 'UseGPGPUCompute', apitype [, flags]);???

PsychImaging('AddTask','General', 'FloatingPoint32Bit'); % sets accuracy of frame buffer to 32bit floating point

[windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, [0 0 0] ); %opens screen and sets background to black

% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', windowPtr);

% Get frame rate fro moving patch
frameRate=Screen('FrameRate',screenNumber);

% Get the number of frames stim needs to be on for
totalNumFrames = frameRate * stimTime;

% Get Duty frame on frame off
totalOnFrame = round(totalNumFrames*dutyCycle);
totalOffFrame = totalNumFrames - totalOnFrame;


%% START STIM PRESENTATION

HideCursor(windowPtr, []);

if doNotSendEvents ==0
    % trigger image scan start
    DaqDConfigPort(daq,0,0);
    err = DigiOut(daq, 0, 255, 0.1);
end

while ~KbCheck
    tic;
    for currentStimNum = 1:numReps
        stimOnFlag =1;
        for frameNo =1:totalOnFrame % duty ON presentation loop
            
            %draw on rect
            Screen('FillRect', windowPtr, Col , [] );
            
            if doNotSendEvents ==0
                if stimOnFlag ==1 % only sends stim on at the first draw of moving grating
                    AnalogueOutEvent(daq, 'STIM_ON');
                    stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
                    stimOnFlag = 0;
                    
                end
            end
            
            % Flip to the screen
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'SCREEN_REFRESH');
                stimCmpEvents(end+1,:)= addCmpEvents('SCREEN_REFRESH');
            end
            Screen('Flip', windowPtr);
            disp('Stim On');
            
            % Abort requested? Test for keypress:
            if KbCheck
                break;
            end
            
        end % end stim presentation loop
        %%
        for frameNo =1:totalOffFrame % duty OFF presentation loop
            
            
              %draw on rect
            Screen('FillRect', windowPtr, [0 0 0] , [] );
            if doNotSendEvents ==0
                    AnalogueOutEvent(daq, 'STIM_OFF');
                    stimCmpEvents(end+1,:)= addCmpEvents('STIM_OFF');
          
            end
            
            %draw on rect
            Screen('Flip', windowPtr);
                      disp('Stim OFF');
            
            % Flip to the screen
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'SCREEN_REFRESH');
                stimCmpEvents(end+1,:)= addCmpEvents('SCREEN_REFRESH');
            end
            
            % Abort requested? Test for keypress:
            if KbCheck
                break;
            end
            
        end % end stim presentation loop
        
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

