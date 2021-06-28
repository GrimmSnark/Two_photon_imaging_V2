function PTB_FlickerStim(stimTime, stimType, varargin)


%% set up parameters of stimuli
clc
sca;

p = inputParser;
p.addParameter('image2Use','C:\PostDoc Docs\code\matlab\Two_photon_imaging_V2\PTB_Experiments\',@isstr);
p.addParameter('imageSet2Use', 'C:\PostDoc Docs\code\matlab\Two_photon_imaging_V2\PTB_Experiments\',@isstr);
p.addParameter('imageOrder', 1 ,@(x) assert(isnumeric(x) && isscalar(x))); % imageOrder, 1 = random order the set, 2 = in series as loaded from dir

p.parse(varargin{:});

%Stimulus
offColor = [0 0.5 0.5];

switch stimType
    case 1 % flicker block color
        onColor  = [0 1 1];
        
    case 2 % flicker loaded image and block color
        image2UseFilepath = p.Results.image2Use;
    case 3 % flicker image set
        imageSet2UseFilepath = p.Results.imageSet2Use;
    case 4 % white noise stimulus
        
    case 5 % repeat white noise stimulus set with block color

end


%% intial set up of experiment
Screen('Preference', 'VisualDebugLevel', 0); % removes welcome screen
PsychDefaultSetup(2); % PTB defaults for setup
screenNumber = max(Screen('Screens')); % makes display screen the secondary one


% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', screenNumber); % uncomment for your setup
screenStimCentre = [0.5 * screenXpixels , 0.5 * screenYpixels]; % screen centre


PsychImaging('PrepareConfiguration');
% Screen('Preference', 'SkipSyncTests', 1);
% Screen('Preference', 'ScreenToHead', 0, 0, 1);

% try to open screen, can have issues on windows, so retry till it works
count = 0;
errorCount = 0;
while count == errorCount
    try
        [windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, offColor); %opens screen and sets background to grey
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


% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', windowPtr);
frameWaitTime = ifi - 0.5;

% Get frame rate fro moving patch
frameRate=Screen('FrameRate',screenNumber);

% Get the number of frames stim needs to be on for
totalNumFrames = frameRate * stimTime;

% load in images if required

switch stimType
    case 1 % flicker block color
        
    case 2 % flicker loaded image and block color
        flickerImage = imread(image2UseFilepath);
        % Make the image into a texture
        flickerImagePtr = Screen('MakeTexture', windowPtr, flickerImage);
        
    case 3
        images2Load = dir(imageSet2UseFilepath);
        
        for a = 1:length(images2Load)
            flickerImagePtr(a) = Screen('MakeTexture', windowPtr, [images2Load(a).folder '\' images2Load(a).name]);
        end
        
    case 4 
        
end



%% START STIM PRESENTATION

vbl = Screen('Flip', windowPtr);
while ~KbCheck
    
    vbl = Screen('Flip', windowPtr, vbl + frameWaitTime);
    
    %% For case 1/2, block color OR single image flicker
    if stimType == 1 || stimType == 2
        for frameNo =1:totalNumFrames % duty ON presentation loop
            
            switch stimType
                case 1 % flicker block color
                    Screen('FillRect', windowPtr, onColor , [] );
                    
                case 2 % flicker loaded image and block color
                    Screen('DrawTexture', windowPtr, flickerImagePtr, [], [], 0);
            end
            
            vbl = Screen('Flip', windowPtr, vbl + frameWaitTime);
            
            % Abort requested? Test for keypress:
            if KbCheck
                break;
            end
        end % end stim presentation loop
        
        for frameNo =1:totalNumFrames % duty OFF presentation loop
            %draw on rect
            Screen('FillRect', windowPtr, offColor , [] );
            
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
        
        % Abort requested? Test for keypress:
        if KbCheck
            break;
        end
        
        
    elseif stimType == 3
        %% For case 3, repeat stimulus set from image
        
        if imageOrder == 1
            imageOrderVector = randperm(length(flickerImagePtr));
        elseif imageOrder == 2
            imageOrderVector = 1:length(flickerImagePtr);
        end
        
        for imageNo = imageOrderVector
            for frameNo =1:totalNumFrames % duty ON presentation loop
                
                Screen('DrawTexture', windowPtr, flickerImagePtr(imageNo), [], [], 0);
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
        end
        % Abort requested? Test for keypress:
        if KbCheck
            break;
        end
        
    elseif stimType == 4
         %% For case 4, repeat white noise stimulus set

        whiteNoiseStim=imresize(double(im2bw(rand(40,40),.5)),36,'nearest');
        flickerImagePtr = Screen('MakeTexture', windowPtr, whiteNoiseStim);
        
        for frameNo =1:totalNumFrames % duty ON presentation loop
            
            
            Screen('DrawTexture', windowPtr, flickerImagePtr, [], [] , 0, 0 , [], [0 1 1]);
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
        
        elseif stimType == 5
         %% For case 5, repeat white noise stimulus set with block color

        whiteNoiseStim=imresize(double(im2bw(rand(40,40),.5)),36,'nearest');
        flickerImagePtr = Screen('MakeTexture', windowPtr, whiteNoiseStim);
        
        for frameNo =1:totalNumFrames % duty ON presentation loop
            
            
            Screen('DrawTexture', windowPtr, flickerImagePtr, [], [] , 0, 0 , [], [0 1 1]);
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
        
        for frameNo =1:totalNumFrames % duty OFF presentation loop
            %draw on rect
            Screen('FillRect', windowPtr, offColor , [] );
            
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
end

Screen('LoadNormalizedGammaTable', windowPtr, oldTable);
% Clear screen
sca;
end