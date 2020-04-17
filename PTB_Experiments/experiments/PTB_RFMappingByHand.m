function PTB_RFMappingByHand(sendOutSignalsFlag, varargin)
% course manual mapping program, does not output any events but plays
% moving gabor continously. sendOutSignalsFlag is a binary flag on whether
% of not send out stim on/off signals to bruker system varargin can contaon
% a grey level of the background screen (0-255) Allows the following
% commands
%
% Esc = ends experiement
% up Arrow = moves stim up the screen
% down Arrow = moves stim down screen
% left Arrow = moves stim left
% right Arrow = moves stim right
% space Key = toggles stim on and off
% enter Key = increases rotation of gabor
% back space = decreases rotation of gabor
% plus key =increase radius of gabor
% minus ky = decreases radius of gabor

%% set up parameters of stimuli
clc
sca;

% Should not change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

waitframes = 1;
initialCenter = [0, 0];

%Stimulus
incrementAngle = 2;
stimeSizeRange = 2:incrementAngle:50;
for i = 1:length(stimeSizeRange)
    widthInPix(i) = degreeVisualAngle2Pixels(2,stimeSizeRange(i));
end
pixelsPerPress = degreeVisualAngle2Pixels(2,1);

if isempty(varargin)
    bckgroundCol =128;
else
    bckgroundCol = varargin{1};
end
bckgrdRange = linspace(0,1, 256);

freq = 1 ; % in cycles per degree
freq = 1/freq; % hack hack hack
freqPix = degreeVisualAngle2Pixels(2,freq);
freqPix =1/freqPix; % use the inverse as the function below takes bloody cycles/pixel...
phase = 0;
contrast =50;

cyclespersecond =2; % temporal frequency to stimulate all cells
sigma = widthInPix/8;
aspectRatio =1;
orientation =linspace(0, 337.5, 16);

for x = 1:length(stimeSizeRange)
    stimRect(:,x) = [0 0 widthInPix(x) widthInPix(x)];
end


%% % set up DAQ box

if sendOutSignalsFlag ==1
    daq =[];
    
    % set up DAQ
    if isempty(daq)
        clear PsychHID;
        daq = DaqDeviceIndex([],0);
    end
    
    dataDir = 'C:\PostDoc Docs\Ca Imaging Project\PTB_Timing_Files\'; % save dir for timing files
    timeSave = datestr(now,'yyyymmddHHMMSS');
    indentString = 'RF_mapping_';
    stimCmpEvents = [1 1] ;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up relative stim centre based on degree visual angle

%Screen('Preference', 'SkipSyncTests', 1);

PsychDefaultSetup(2); % PTB defaults for setup

screenNumber = max(Screen('Screens')); % makes display screen the secondary one

%% intial set up of experiment

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;

PsychImaging('PrepareConfiguration');

% try to open screen, can have issues on windows, so retry till it works
count = 0;
errorCount = 0;
while count == errorCount
    try
        [windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, [ backgroundColor(1:3) ] ); %opens screen and sets background to grey
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


% Create gabor gratings
backgrdColGabor = [bckgrdRange(bckgroundCol) bckgrdRange(bckgroundCol) bckgrdRange(bckgroundCol) 0];

for i =1:length(stimeSizeRange)
    [gabortex(i),  gaborrect(:,i)]= CreateProceduralGabor(windowPtr, widthInPix(i), widthInPix(i), [], backgrdColGabor , [], contrast);
end

% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', windowPtr);

% Get the size of the on screen window
% [screenXpixels, screenYpixels] = Screen('WindowSize', windowPtr); % uncomment for your setup

screenXpixels = 1915; % hard coded cause reasons.. weird screens % comment out for your setup
screenYpixels = 1535;

screenCentre = [0.5 * screenXpixels , 0.5 * screenYpixels]; % screen centre of Shel 1170 WEIRD, calcualted by physical measurement...

screenStimCentreOffset(1) = degreeVisualAngle2Pixels(2,initialCenter(1));
screenStimCentreOffset(2) = degreeVisualAngle2Pixels(2,initialCenter(2));

screenStimCentre = screenCentre + screenStimCentreOffset; % screenStimCentre actual refers to the top left corner of the stimulus....bloody PTB nonsense




% The avaliable keys to press
KbName('UnifyKeyNames')
escapeKey = KbName('ESCAPE');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
spaceKey = KbName('space');
enterKey = KbName('return');
backKey = KbName('backspace');
plusKey = KbName('+');
minusKey = KbName('-');
leftBracketKey = KbName('[{');
rightBracketKey = KbName(']}');

% Get frame rate fro moving patch
% frameRate=Screen('FrameRate',screenNumber);

% Get the number of frames stim needs to be on for
% totalNumFrames = frameRate * stimTime;

% Compute increment of phase shift per redraw:
phaseincrement = (cyclespersecond * 360) * ifi;

% Maximum priority level
topPriorityLevel = MaxPriority(windowPtr);
Priority(topPriorityLevel);

% This is the cue which determines whether we exit the demo
exitDemo = false ;

vbl  = Screen('Flip', windowPtr);
stimOn =0;
orientationNo = 1;
size = 4;
bckgrdRangeIndx = 20;
stimFirstOffFlag =0;
updateInfo = 0;
 stimRadius = (stimRect(3,size)/2);
%%

if sendOutSignalsFlag ==1
    AnalogueOutEvent(daq, 'TRIAL_START');
    stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_START');
    
end

% Loop the animation until the escape key is pressed
while exitDemo == false
    
    % Check the keyboard to see if a button has been pressed
    [~,~, keyCode] = KbCheck;
    
    % Depending on the button press, either move ths position of the square
    % or exit the demo
    if keyCode(escapeKey) % exit script
        exitDemo = true;
    elseif keyCode(leftKey) % move stim left
        screenStimCentre(1) = screenStimCentre(1) - pixelsPerPress;
        updateInfo = 1;
    elseif keyCode(rightKey) % move stim right
        screenStimCentre(1) = screenStimCentre(1) + pixelsPerPress;
        updateInfo = 1;
    elseif keyCode(upKey) % move stim up
        screenStimCentre(2) = screenStimCentre(2) - pixelsPerPress;
        updateInfo = 1;
    elseif keyCode(downKey) % move stim down
        screenStimCentre(2) = screenStimCentre(2) + pixelsPerPress;
        updateInfo = 1;
        
    elseif keyCode(spaceKey) % toggle stim on and off
        if stimOn ==1
            stimOn =0;
            stimFirstOffFlag = 1;
            disp('off');
            KbReleaseWait;
        elseif stimOn ==0
            stimOn =1;
            stimFirstOnFlag = 1;
            disp('on');
            KbReleaseWait;
            updateInfo = 1;
        end
        
    elseif keyCode(enterKey) && orientationNo < length(orientation) % incease orientation degree
        orientationNo = orientationNo + 1;
        KbReleaseWait;
        updateInfo = 1;
    elseif keyCode(backKey) && orientationNo > 1 % decreae orientation degree
        orientationNo = orientationNo - 1;
        KbReleaseWait;
        updateInfo = 1;
        
    elseif keyCode(plusKey) && size < length(stimeSizeRange) % increase size of stim
        size = size+1;
        updateInfo = 1;
        stimRadius = (stimRect(3,size)/2); % for setting actual stim position due to wierd drawing of stim (ie from top left of object)
    elseif keyCode(minusKey) && size > 1 % decrease sie of stim
        size = size-1;
        updateInfo = 1;
        stimRadius = (stimRect(3,size)/2);  % for setting actual stim position due to wierd drawing of stim (ie from top left of object)
        
        %     elseif keyCode(leftBracketKey) && bckgrdRangeIndx > 1
        %         bckgrdRangeIndx = bckgrdRangeIndx- 1;
        %     elseif keyCode(rightBracketKey) && bckgrdRangeIndx < 255
        %         bckgrdRangeIndx = bckgrdRangeIndx- 1;
    end
    
    
    
    % We set bounds to make sure our square doesn't go completely off of
    % the screen
    if screenStimCentre(1) - stimRadius < 0
        screenStimCentre(1) = stimRadius;
    elseif screenStimCentre(1)  + stimRadius > screenXpixels
        screenStimCentre(1) = screenXpixels - stimRadius;
    end
    
    if screenStimCentre(2) - stimRadius < 0
        screenStimCentre(2) = stimRadius;
    elseif screenStimCentre(2) + stimRadius > screenYpixels
        screenStimCentre(2) = screenYpixels - stimRadius;
    end
    
    
    % Increment phase by cycles/s:
    phase = phase + phaseincrement;
    %create auxParameters matrix
    propertiesMat = [phase, freqPix, sigma(size), contrast, aspectRatio, 0, 0 ,0];
    
    dstRect = OffsetRect(stimRect(:,size)', screenStimCentre(1) - stimRadius, screenStimCentre(2) - stimRadius);
    
    if stimOn ==1
        Screen('FillRect', windowPtr, backgrdColGabor);
        Screen('DrawTexture', windowPtr, gabortex(size), [], dstRect , orientation(orientationNo), [], [], [], [], kPsychDontDoRotation, propertiesMat' );
        
        if stimFirstOnFlag ==1 % only sends stim on at the first draw of moving grating
            if sendOutSignalsFlag ==1
                AnalogueOutEvent(daq, 'STIM_ON');
                stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
                stimFirstOnFlag = 0;
            end
        end
        
    elseif stimOn ==0
        Screen('FillRect', windowPtr, backgrdColGabor);
        vbl  = Screen('Flip', windowPtr, vbl + (waitframes - 0.5) * ifi);
        
        if stimFirstOffFlag == 1
            if sendOutSignalsFlag == 1
                AnalogueOutEvent(daq, 'STIM_OFF');
                stimCmpEvents(end+1,:)= addCmpEvents('STIM_OFF');
                
                stimFirstOffFlag = 0;
            end
        end
    end
    

%     Screen('DrawDots', windowPtr, screenStimCentre, [5], [1 0 0], [] , [], []);    
%     Screen('DrawDots', windowPtr, [ 0.5 * screenXpixels, screenYpixels]  , [10], [1 0 0], [] , [], []);
%     Screen('DrawDots', windowPtr, [ screenXpixels, 0.5 * screenYpixels]  , [10], [1 0 0], [] , [], []);  
%     Screen('DrawDots', windowPtr, [ 0.5 * screenXpixels, 0]  , [10], [1 0 0], [] , [], []);
%     Screen('DrawDots', windowPtr, [ 0, 0.5 * screenYpixels]  , [10], [1 0 0], [] , [], []);
  
    
    vbl  = Screen('Flip', windowPtr, vbl + (waitframes - 0.5) * ifi);
    
    if updateInfo == 1
        
        positionInDegrees(1) = pixels2DegreeVisualAngle(1, screenStimCentre(1) - screenCentre(1));
        positionInDegrees(2) = pixels2DegreeVisualAngle(1, screenCentre(2) - screenStimCentre(2));
        
        disp('###########################################');
        disp(['Stim size: ' num2str(stimeSizeRange(size))]);
        disp(['Stim centre location (in pix): ' num2str(screenStimCentre)]);
        disp(['Stim centre location (in degrees): ' num2str(positionInDegrees)]);
        disp(['Stim orientation: ' num2str(orientation(orientationNo))]);
        disp('###########################################');
        updateInfo = 0;
    end
end

if sendOutSignalsFlag ==1
    AnalogueOutEvent(daq, 'TRIAL_END');
    stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_END');
    
end

Screen('Close');
Screen('CloseAll');
sca;


%% save things before close

if sendOutSignalsFlag ==1
    saveCmpEventFile(stimCmpEvents, dataDir, indentString, timeSave);
end
Screen('LoadNormalizedGammaTable', windowPtr, oldTable);


end