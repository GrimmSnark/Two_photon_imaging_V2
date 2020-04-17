function PTB_TestColorSquareWave(stimCenter, preStimTime, stimTime)
% Scrap code used to test out colors and gamma correction with psychtoolbox

fullfieldStim =1;
width = 0;
backgroundColor =[0.1 0.1 0.1 1];
contrast = 1;


freq = 0.05 ; % in cycles per degree
freq = 1/freq; % hack hack hack
freqPix1 = degreeVisualAngle2Pixels(2,freq);
freqPix =1/freqPix1; % use the inverse as the function below takes bloody cycles/pixel...




screenNumber = max(Screen('Screens')); % makes display screen the secondary one
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', screenNumber); % uncomment for your setup


screenStimCentre = [0.5 * screenXpixels , 0.5 * screenYpixels];
% Set up relative stim centre based on degree visual angle

PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange', 1);
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible', 'applyAlsoToMakeTexture', 1);




[windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, [ backgroundColor ] ); %opens screen and sets background to grey


% load gamma table
% try
%     load 'C:\All Docs\calibrations\gammaTableGamma.mat'
% catch
%     load 'C:\PostDoc Docs\Two Photon Rig\calibrations\LCD monitor\gammaTableGamma.mat'
% end
% Screen('LoadNormalizedGammaTable', windowPtr, gammaTable1*[1 1 1]);

[gratingidManual, gratingrectManual, ~]  = createSquareWaveGrating(windowPtr,screenXpixels*1.5, screenXpixels*1.5, [1 0 0], backgroundColor(1:3), freqPix1);

%create all gratings on GPU.....should be very fast
% [gratingid, gratingrect] = CreateProceduralSquareWaveGrating(windowPtr, screenXpixels*1.5, screenXpixels*1.5, backgroundColor, [], contrast);



% Increment phase by cycles/s:
phase = 0;
%create auxParameters matrix
propertiesMat = [phase, freqPix, contrast, 0];
% draw grating on screen
%Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
WaitSecs(3);

% Screen('DrawTexture', windowPtr, gratingid, gratingrect, [] ,0 , [] , [], [1 0 0], [], [], propertiesMat' );
% Screen('Flip', windowPtr);
% WaitSecs(5)
% Screen('Flip', windowPtr);

shiftperframe = 3;
xoffset=0;

for i = 1:300
xoffset = xoffset + shiftperframe;

srcRect=[xoffset 0 xoffset + screenXpixels screenYpixels];

Screen('DrawTexture', windowPtr, gratingidManual, srcRect, gratingrectManual ,0 , [] , [], [], [], [], propertiesMat' );
Screen('Flip', windowPtr);

end

WaitSecs(5);

Screen('Flip', windowPtr);

sca;


end