function PTB_ZStackFlicker(dutyCycle, stimTime, dropRed)


%% set up parameters of stimuli
clc
sca;

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
widthInPix = degreeVisualAngle2Pixels(3,0);

%spatial frequency
freq = 0.05 ; % in cycles per degree
freq = 1/freq; % hack hack hack
freqPix = degreeVisualAngle2Pixels(3,freq);
freqPix =1/freqPix; % use the inverse as the function below takes bloody cycles/pixel...

contrast =  1 ; % contrast for grating
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Angle =[0    45    90   135 ]; % angle in degrees

numCnd = length(Angle);

%% intial set up of experiment
Screen('Preference', 'VisualDebugLevel', 0); % removes welcome screen
PsychDefaultSetup(2); % PTB defaults for setup
screenNumber = max(Screen('Screens')); % makes display screen the secondary one


% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', screenNumber); % uncomment for your setup
screenStimCentre = [0.5 * screenXpixels , 0.5 * screenYpixels]; % screen centre

% Define black, white and grey
white = WhiteIndex(screenNumber);

if dropRed == 1
    grey = [0 0.5 0.5];
else
    grey = white / 2;
end



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

PsychImaging('PrepareConfiguration');

% load gamma table
try
    load 'C:\All Docs\calibrations\gammaTableGamma.mat'
catch
    load 'C:\PostDoc Docs\Two Photon Rig\calibrations\LCD monitor\gammaTableGamma.mat'
end
oldTable = Screen('LoadNormalizedGammaTable', windowPtr, gammaTable1*[1 1 1]);


%create all gratings on GPU.....should be very fast

[gratingid, gratingrect] = CreateProceduralSineGrating(windowPtr, screenXpixels*1.5, screenXpixels*1.5, backgroundColorOffset, [], 0.5);


% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', windowPtr);
frameWaitTime = ifi - 0.5;

% Get frame rate fro moving patch
frameRate=Screen('FrameRate',screenNumber);

% Get the number of frames stim needs to be on for
totalNumFrames = frameRate * stimTime;

% Get Duty frame on frame off
totalOnFrame = round(totalNumFrames*dutyCycle);
totalOffFrame = totalNumFrames - totalOnFrame;


%% START STIM PRESENTATION

vbl = Screen('Flip', windowPtr);
while ~KbCheck
    % randomizes the order of the conditions for this block
    cndOrder = datasample(1:numCnd,numCnd,'Replace', false);
    
    vbl = Screen('Flip', windowPtr, vbl + frameWaitTime);
    
    for trialCnd = 1:length(cndOrder)
        
        for frameNo =1:totalOnFrame % duty ON presentation loop
            
            propertiesMat = [phase, freqPix, contrast, 0];
            
            % draw grating on screen
            Screen('DrawTexture', windowPtr, gratingid, [], [] , Angle(cndOrder(trialCnd)), 0 , [], [modulateCol], [], [], propertiesMat' );
            Screen('DrawingFinished', windowPtr);
            
            vbl = Screen('Flip', windowPtr, vbl + frameWaitTime);
            
            % Abort requested? Test for keypress:
            if KbCheck
                break;
            end
            
        end % end stim presentation loop
        
        for frameNo =1:totalOffFrame % duty OFF presentation loop
            
            
            %draw on rect
            Screen('FillRect', windowPtr, [grey] , [] );
            
            %draw on rect
            Screen('Flip', windowPtr);
            
            % Abort requested? Test for keypress:
            if KbCheck
                break;
            end
            
        end % end stim presentation loop
        
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


Screen('LoadNormalizedGammaTable', windowPtr, oldTable);
% Clear screen
sca;
end