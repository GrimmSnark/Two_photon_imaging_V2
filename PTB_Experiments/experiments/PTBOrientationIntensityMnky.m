function PTBOrientationIntensityMnky(width, stimCenter, preStimTime, stimTime, rampTime, blendDistance , numReps, contrastSpacing , staticPresentation, doNotSendEvents)
% Experiment which displays moving or static square wave black and white
% gratings of different intensity (contrast) levels
%
% options:  width - (degrees) for full screen leave blank
%           stimCenter - [0,0] (degrees visual angle from screen center)
%           preStimTime - pre stimulus spontaneous activity period (in
%                         seconds)
%           stimTime - stim time (seconds)
%           rampTime - ramp time added on and off for stimulus (seconds)
%           blendDistance - guassian blur window (degrees)
%           numReps - (number of blocks of all stim repeats, if blank is
%           infinite)
%           contrastSpacing - 1: linear spaced, 2: log spaced spacing of
%           contrast conditions
%           staticPresentation - 0/1 flag for static stimuli
%           doNotSendEvents - Flag to no send events out through USB-1208FS, 
%                             used for testing purposes 



%% set up parameters of stimuli
clc
sca;

if isempty(numReps)
    numReps = 100;
end

if isempty(width)
    width = 0;
end

if isempty(rampTime)
    rampTime = 0;
end

if nargin < 10 || isempty(doNotSendEvents)
    doNotSendEvents = 0;
end

% Should not change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataDir = 'C:\PostDoc Docs\Ca Imaging Project\PTB_Timing_Files\'; % save dir for timing files
timeSave = datestr(now,'yyyymmddHHMMSS');
indentString = 'OrientationWColorMnky_';

% stimTime = 1; %in s
ITItime = 5; % intertrial interval in seconds
% firstTime =1;
blockNum = 0;
stimCmpEvents = [1 1] ;

phase = 0;

%Stimulus
%width = 10; % in degrees visual angle
widthInPix = degreeVisualAngle2Pixels(2,width);
heightInPix =widthInPix;
radius=widthInPix/2; % circlar apature in pixels

blendDistancePixels = degreeVisualAngle2Pixels(2,blendDistance);

backgroundColor = [0.5 0.5 0.5 1];


%spatial frequency
freq = 0.05 ; % in cycles per degree
freq = 1/freq; % hack hack hack
freqPix = degreeVisualAngle2Pixels(2,freq);
%  freqPix =1/freqPix; % use the inverse as the function below takes bloody cycles/pixel...

cyclespersecond =0.5; % temporal frequency to stimulate all cells (in Hz)


% contrast levels

switch contrastSpacing
    case 1 % linspaced
        contrastLevels =  linspace(0,1,7);
        contrastLevels =  contrastLevels(2:end);
    case 2 % log spaced
        %        contrastLevels =  exp(linspace(log(1),log(2),7)); % contrast for grating
        contrastLevels =  log(linspace(exp(0),exp(1),7)); % contrast for grating
        %         contrastLevels = contrastLevels -1;
        contrastLevels =  contrastLevels(2:end);
end

% orientations = [0 45 90 135]; % 4 orientations
orientations = [0:30:150]; % 6 orientations
% orientations = [0:15:165]; % 12 orientations

Angle =repmat(orientations,[1 length(contrastLevels)]); % angle in degrees x number of colors

numCnd = length(Angle); % conditions = angle x colors

% Add stim parameters to structure for saving
stimParams.width = width;
stimParams.stimCenter= stimCenter;
stimParams.preStimTime = preStimTime;
stimParams.stimTime = stimTime;
stimParams.rampTime = rampTime;
stimParams.numReps = numReps;
stimParams.freq = freq;
stimParams.ITItime = ITItime;
stimParams.cyclespersecond = cyclespersecond;
stimParams.contrast = contrastLevels;
stimParams.blendDistance = blendDistance;
stimParams.Angle = Angle;

if doNotSendEvents ==0
    save([dataDir 'stimParams_' timeSave '.mat'], 'stimParams');
end


% make balanced numbers of left/right start movement stims
nOfDirectionPerOrien = length(orientations)/2;
directionStartPerOrientation = zeros(1, length(orientations));
directionStartPerOrientation(randperm(numel(directionStartPerOrientation), nOfDirectionPerOrien)) = 1;

%covert to logical
directionStartPerOrientation = logical(directionStartPerOrientation);

% get inverse for next colour
directionStartPerOrientation2 = ~directionStartPerOrientation;

directionStartPerOrientation = [directionStartPerOrientation; directionStartPerOrientation2];

blockMovementsBalanced = repmat(directionStartPerOrientation,length(contrastLevels)/2,1);

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


%% initial set up of experiment
Screen('Preference', 'VisualDebugLevel', 0); % removes welcome screen
Screen('Preference','SkipSyncTests', 0);
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

screenCentre = [0.5 * screenXpixels , 0.5 * screenYpixels];
% Set up relative stim centre based on degree visual angle

screenStimCentreOffset(1) = degreeVisualAngle2Pixels(2,stimCenter(1));
screenStimCentreOffset(2) = degreeVisualAngle2Pixels(2,stimCenter(2));

screenStimCentre = screenCentre + screenStimCentreOffset;

PsychImaging('PrepareConfiguration');
% PsychImaging('AddTask','General', 'FloatingPoint32Bit'); % sets accuracy of frame buffer to 32bit floating point

% look into PsychImaging('AddTask', 'General', 'UseGPGPUCompute', apitype [, flags]);???

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



[gratingid, gratingrect, ~]  = createSquareWaveGrating(windowPtr,screenXpixels*3, screenXpixels*3, [1 1 1], [0 0 0], freqPix, 1);


% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', windowPtr);
frameWaitTime = ifi - 0.5;

% Compute increment of phase shift per redraw:
phaseincrement = cyclespersecond * freqPix * ifi;


% Get frame rate fro moving patch
frameRate=Screen('FrameRate',screenNumber);

% Get the number of frames stim needs to be on for
totalNumFrames = frameRate * stimTime;

% Get number of frames for prestimulus time
preStimFrames = frameRate * preStimTime;

% Get frame number to interate over contrast ramp
contrast_rampFrames = round(frameRate *  rampTime);
contrastLevelsRamp = linspaceVector(zeros(length(contrastLevels),1), contrastLevels, contrast_rampFrames);


% set up gaussian window
% create alpha blend window
% blendDistance = 200;

% set up color channels for background
mask = ones(screenYpixels, screenXpixels+5, 3);

% background values
mask(:,:,1) = mask(:,:,1) * backgroundColor(1); % red value
mask(:,:,2) = mask(:,:,2) * backgroundColor(2); % green value
mask(:,:,3) = mask(:,:,3) * backgroundColor(3); % blue value

mask2 = NaN(screenYpixels, screenXpixels+5); %alpha mask
blendVec = linspace(1, 0, blendDistancePixels);
% blendVec= log(linspace(exp(1),exp(0), blendDistancePixels));
% blendVec= exp(logspace(log(2),log(1), blendDistancePixels));
% blendVec = [blendVec/max(blendVec) 0];


for i =1:length(blendVec)
    mask2(i:end-(i-1),i:end-(i-1)) =  blendVec(i);
end

mask = cat(3,mask,mask2);
masktex=Screen('MakeTexture', windowPtr, mask);




%% START STIM PRESENTATION

% HideCursor(windowPtr, []);

if doNotSendEvents ==0
    % trigger image scan start with digital port A
    DaqDConfigPort(daq,0,0); % configure port A for output
    err = DigiOut(daq, 0, 255, 0.1);
    
    DaqDConfigPort(daq,1,1) % configure port B for input
end

experimentStartTime = tic;

for currentBlkNum = 1:numReps
    % randomizes the order of the conditions for this block
    cndOrder = datasample(1:numCnd,numCnd,'Replace', false);
    blockNum = blockNum+1;
    
    for trialCnd = 1:length(cndOrder)
        
        xoffset=0;
        
        % Get trial cnds
        trialParams = Angle(cndOrder(trialCnd)); % get angle identity
        indexForOrientation = find(Angle==trialParams, 1); % get index for that angle
        
        % get color condition
        currentConstrastLevel = ceil(cndOrder(trialCnd)/length(orientations));
        %             modulateCol = colorLevels(currentColLevel, :);
        
        % get first direction flag ( 0 == left first, 1 == right first)
        directionFlag = blockMovementsBalanced(currentConstrastLevel, indexForOrientation);
        
        if directionFlag == 0
            movementDirection = 'Postive';
            movementEvent1 = 'POSITIVE_MOVEMENT';
            movementEvent2 = 'NEGATIVE_MOVEMENT';
        else
            movementDirection = 'Negative';
            movementEvent1 = 'NEGATIVE_MOVEMENT';
            movementEvent2 = 'POSITIVE_MOVEMENT';
        end
        
        
        if doNotSendEvents ==0
            AnalogueOutEvent(daq, 'TRIAL_START');
            stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_START');
        end
        
        
        % get current time till estimated finish
        currentTimeUsed = toc(experimentStartTime);
        timeLeft = (totalTime - currentTimeUsed)/60;
        
        
        %display trial conditions
        
        fprintf(['Block No: %i of %i \n'...
            'Condition No: %i \n'...
            'Trial No: %i of %i \n' ...
            'Contrast Cnd: %.3f (No. %i of %i) \n' ...
            'Orientation: %.1f degrees \n'...
            'First Direction = %s \n' ...
            'Estimated Time to Finish = %.1f minutes \n' ...
            '############################################## \n'] ...
            ,blockNum, numReps ,cndOrder(trialCnd), trialCnd, length(cndOrder) , contrastLevels(currentConstrastLevel), currentConstrastLevel, length(contrastLevels) , trialParams(1), movementDirection, timeLeft);
        
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
        vbl = Screen('Flip', windowPtr);
        
        
        %% start constrast ramp on
        if rampTime > 0
            for frameNo =1:contrast_rampFrames
                
                if directionFlag == 0
                    movementOperator = '+';
                else
                    movementOperator = '-';
                end
                
                % Increment phase by cycles/s:
                if staticPresentation ==0
                    xoffset = eval(['xoffset ' movementOperator ' phaseincrement']);
                end
                
                % makes rolling buffer so grating doesn't reach limit
                % of presentation
                if xoffset < 1
                    xoffset = xoffset + freqPix;
                elseif xoffset > freqPix
                    xoffset = xoffset - freqPix;
                end
                
                srcRect=[xoffset 0 xoffset + screenXpixels*1.5 screenXpixels*1.5];
                
                if doNotSendEvents ==0
                    if stimOnFlag ==1 % only sends stim on at the first draw of moving grating
                        AnalogueOutEvent(daq, 'STIM_ON');
                        stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
                        
                        % add movement direction event
                        AnalogueOutEvent(daq, movementEvent1);
                        stimCmpEvents(end+1,:)= addCmpEvents(movementEvent1);
                        
                        stimOnFlag = 0;
                    end
                end
                
                
                
                Screen('BlendFunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('DrawTexture', windowPtr, gratingid, srcRect, [] , Angle(cndOrder(trialCnd)), [] , contrastLevelsRamp(currentConstrastLevel,frameNo), [], [], [] );
                
                Screen('DrawTexture', windowPtr, masktex, [], [], 0);
                Screen('DrawingFinished', windowPtr);
                
                vbl = Screen('Flip', windowPtr, vbl + frameWaitTime);
                
                % Abort requested? Test for keypress:
                if KbCheck
                    break;
                end
            end
        end
        %% First movement direction
        for frameNo =1:totalNumFrames/2 % stim presentation loop
            %                 phase = phase + phaseincrement;
            % Increment phase by cycles/s:
            
            if directionFlag == 0
                movementOperator = '+';
            else
                movementOperator = '-';
            end
            
            % Increment phase by cycles/s:
            if staticPresentation ==0
                xoffset = eval(['xoffset ' movementOperator ' phaseincrement']);
            end
            
            
            % makes rolling buffer so grating doesn't reach limit
            % of presentation
            if xoffset < 1
                xoffset = xoffset + freqPix;
            elseif xoffset > freqPix
                xoffset = xoffset - freqPix;
            end
            
            srcRect=[xoffset 0 xoffset + screenXpixels*1.5 screenXpixels*1.5];
            
            
            Screen('DrawTexture', windowPtr, gratingid, srcRect, [] , Angle(cndOrder(trialCnd)), [] , contrastLevels(currentConstrastLevel), [], [], [] );
            Screen('DrawTexture', windowPtr, masktex, [], [], 0);
            
            if doNotSendEvents ==0
                if rampTime == 0
                    if stimOnFlag ==1 % only sends stim on at the first draw of moving grating
                        AnalogueOutEvent(daq, 'STIM_ON');
                        stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
                        
                        % add movement direction event
                        AnalogueOutEvent(daq, movementEvent1);
                        stimCmpEvents(end+1,:)= addCmpEvents(movementEvent1);
                        
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
            vbl = Screen('Flip', windowPtr, vbl + frameWaitTime);
            
            % Abort requested? Test for keypress:
            if KbCheck
                break;
            end
            
        end % end stim presentation loop
        
        % Abort requested? Test for keypress:
        if KbCheck
            break;
        end
        
        %% second movement direction
        
        % add movment direction event
        if doNotSendEvents ==0
            AnalogueOutEvent(daq, movementEvent2);
            stimCmpEvents(end+1,:)= addCmpEvents(movementEvent2);
        end
        
        for frameNo =1:totalNumFrames/2 % stim presentation loop
            
            if directionFlag == 0
                movementOperator = '-';
            else
                movementOperator = '+';
            end
            
            % Increment phase by cycles/s:
            if staticPresentation ==0
                xoffset = eval(['xoffset ' movementOperator ' phaseincrement']);
            end
            
            
            % makes rolling buffer so grating doesn't reach limit
            % of presentation
            if xoffset < 1
                xoffset = xoffset + freqPix;
            elseif xoffset > freqPix
                xoffset = xoffset - freqPix;
            end
            
            srcRect=[xoffset 0 xoffset + screenXpixels*1.5 screenXpixels*1.5];
            
            Screen('DrawTexture', windowPtr, gratingid, srcRect, [] , Angle(cndOrder(trialCnd)), [] , contrastLevels(currentConstrastLevel), [], [], [] );
            Screen('DrawTexture', windowPtr, masktex, [], [], 0);
            Screen('DrawingFinished', windowPtr);
            
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
        %% ramp off
        if rampTime > 0
            % start constrast ramp off
            for frameNo =contrast_rampFrames:-1:1
                
                if directionFlag == 0
                    movementOperator = '-';
                else
                    movementOperator = '+';
                end
                
                % Increment phase by cycles/s:
                if staticPresentation ==0
                    xoffset = eval(['xoffset ' movementOperator ' phaseincrement']);
                end
                
                
                
                % makes rolling buffer so grating doesn't reach limit
                % of presentation
                if xoffset < 1
                    xoffset = xoffset + freqPix;
                elseif xoffset > freqPix
                    xoffset = xoffset - freqPix;
                end
                
                
                srcRect=[xoffset 0 xoffset + screenXpixels*1.5 screenXpixels*1.5];
                
                
                
                Screen('DrawTexture', windowPtr, gratingid, srcRect, [] , Angle(cndOrder(trialCnd)), [] , contrastLevelsRamp(currentConstrastLevel,frameNo), [], [], [] );
                Screen('DrawTexture', windowPtr, masktex, [], [], 0);
                Screen('DrawingFinished', windowPtr);
                
                vbl = Screen('Flip', windowPtr, vbl + frameWaitTime);
                
            end
            
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'STIM_OFF');
                stimCmpEvents(end+1,:)= addCmpEvents('STIM_OFF');
            end
            
        end
        
        vbl = Screen('Flip', windowPtr, vbl + frameWaitTime);
        
        % Abort requested? Test for keypress:
        if KbCheck
            break;
        end
        
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
toc(experimentStartTime);

%% save things before close
if doNotSendEvents ==0
    saveCmpEventFile(stimCmpEvents, dataDir, indentString, timeSave);
end

ShowCursor([],[windowPtr],[]);
Screen('LoadNormalizedGammaTable', windowPtr, oldTable);

% Clear screen
sca;
end

