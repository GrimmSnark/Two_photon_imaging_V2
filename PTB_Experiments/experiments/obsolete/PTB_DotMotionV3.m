function PTB_DotMotionV3(angle)

%% open experiment stuff

AssertOpenGL;
KbName('UnifyKeyNames');

rseed = sum(100*clock); % Seed random number generator
rng(rseed,'v5uniform'); % v5 random generator
%rng(rseed,'twister'); % new default generator
screenInfo = struct('rseed',rseed);

% Open screen, make stuff behave itself in OS X with multiple monitors
Screen('Preference', 'VisualDebugLevel',2);
Screen('Preference', 'SkipSyncTests', 1);


screenNumber = max(Screen('Screens')); % makes display screen the secondary one


% Set the background color to the default background value - black
screenInfo.bckgnd = 0;
[screenInfo.curWindow, screenInfo.screenRect] = Screen('OpenWindow',screenNumber,...
    screenInfo.bckgnd,[],32,2);

% 0 for clear drawing, 1 for incremental drawing (does not clear buffer after flip)
screenInfo.dontclear = 0;

% Get the refresh rate of the screen
screenInfo.frameDur = Screen('GetFlipInterval',screenInfo.curWindow);
screenInfo.monRefresh = 1 / screenInfo.frameDur;

% Get screen center coordinates (pixels)
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', screenNumber); % uncomment for your setup
screenInfo.center = [0.5 * screenXpixels , 0.5 * screenYpixels]; % screen centre

[~, degreePerPix] = pixels2DegreeVisualAngle(3, 1000);

screenInfo.ppd = 1/degreePerPix;

HideCursor;


%% Dot stims

targets = setNumTargets(1); % initialize targets
dotInfo = createDotInfo; % initialize dots

targets = newTargets(screenInfo,targets,1, screenInfo.center(1), screenInfo.center(2), 1000, [0,255,255]);
% showTargets(screenInfo,targets,1);


% %%%%
dotInfo.apXYD = [0 0 screenXpixels];
dotInfo.maxDotTime =[];
dotInfo.keys = 'ESCAPE';
dotInfo.maxDotsPerFrame = 40000;
dotInfo.dotColor = [0 255 255];
dotInfo.dotSize = 3;
dotInfo.speed = 30;
dotInfo.dir = angle;
dotInfo.coh = 90 * 10;

[frames,rseed,start_time,end_time,response,response_time] = ...
    dotsX(screenInfo,dotInfo,targets);

closeExperiment; % clear the screen and exit

end
