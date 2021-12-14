function PTB_DotMotion(angle, backgroundCol)
% Presents random dot motion stimulus used for general activation of visual
% cortex
%
% Inputs: angle - general direction of dot motion 0-360
%
%         backgroundCol - rgb triplet(0-255) for background color
%                         DEFAULT = (0,0,0)
%% defaults
if nargin < 2 || isempty(backgroundCol)
    backgroundCol = [0,0,0];
end

% colors of dots n X 3 rgb triplet for dot color

colorsMat = [0,255,255; 0 255 0; 0 0 255];
% colorsMat = [0,255,255; 255, 0 , 0 ; 0 255 0; 0 255 255];
% colorsMat = [0,255,255];

display.bkColor = backgroundCol;

dots.dotDensity = 3; % density of the dots in the field
dots.speed = 10; % Speed of the dots (degrees/second)
dots.direction = angle; % angle of motion
dots.lifetime = 40; % Number of frames for each dot to live
dots.apertureSize = []; % fullfield for the screen
dots.center = [0,0]; % [x,y] Center of the aperture (degrees)
dots.color = [];
dots.size = 100; % Size of the dots (in pixels)
dots.coherence = 0;

[dots] =  createDotColorStructure(dots, colorsMat);

 duration = []; %seconds
try
    display = OpenWindow(display);
    movingDots(display,dots,duration);
catch ME
    Screen('LoadNormalizedGammaTable', display.windowPtr, display.oldTable);
    Screen('CloseAll');
    rethrow(ME)
    
end
Screen('CloseAll');
end