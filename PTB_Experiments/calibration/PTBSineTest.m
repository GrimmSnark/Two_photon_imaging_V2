function PTBSineTest()
% Test to display sine gratings at random locations in terms of degrees of
% degrees of visual angle


%% set up parameters of stimuli

timer = 0.2; %in s
firstTime =1;

%Stimulus
width = 10; % in degrees visual angle
widthInPix = degreeVisualAngle2Pixels(1,width);
heightInPix =widthInPix;
radius=widthInPix/2; % circlar apature in pixels

freq = 0.5 ; % in cycles per degree
freq = 1/freq; % hack hack hack
freqPix = degreeVisualAngle2Pixels(1,freq);
freqPix =1/freqPix; % use the inverse as the function below takes bloody cycles/pixel...

phase = 0;
contrast = 1 ; % should already be set by the sine grating creation??



backgroundColorOffset = [0.5 0.5 0.5 1]; %RGBA offset color
contrastPreMultiplicator = 1; % constrast
Angle =0; % angle in degrees


%% intial set up of experiment
PsychDefaultSetup(2); % PTB defaults for setup

screenNumber = max(Screen('Screens')); % makes display screen the secondary one
%%resolution = Screen('Resolution',screenNumber); %% may give weird result,
%%so hard coding for now

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;

PsychImaging('PrepareConfiguration');

% look into PsychImaging('AddTask', 'General', 'UseGPGPUCompute', apitype [, flags]);???

PsychImaging('AddTask','General', 'FloatingPoint32Bit'); % sets accuracy of frame buffer to 32bit floating point

[windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, grey); %opens screen and sets background to grey


while ~KbCheck
    %create grating on GPU.....should be very fast
    [gratingid, gratingrect] = CreateProceduralSineGrating(windowPtr, widthInPix, heightInPix, backgroundColorOffset, radius, contrastPreMultiplicator);
    
    % start grating in centre and rand choose from then on
    
    if firstTime ==1
        xc = 612;
        yc = 612;
        firstTime =0;
    else
        xc = randi(1920);
        yc = randi(1024);
    end
    
    %create auxParameters matrix
    dstRect = OffsetRect(gratingrect, xc, yc);
    propertiesMat = [phase, freqPix, contrast, 0];
    
    
    % draw grating on screen
    %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
    Screen('DrawTexture', windowPtr, gratingid, [], dstRect , Angle, [], [], [], [], [], propertiesMat' );
    
    % Flip to the screen
    
    Screen('Flip', windowPtr);

    WaitSecs(timer);
    Screen('Close', gratingid);
end

% Clear screen
sca;
end

