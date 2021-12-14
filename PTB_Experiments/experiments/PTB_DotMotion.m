function PTB_DotMotion(angle, backgroundCol)

if nargin < 2 || isempty(backgroundCol)
    backgroundCol = [0,0,0];
end

colorsMat = [0,255,255; 0 255 0; 0 0 255];
% colorsMat = [0,255,255; 255, 0 , 0 ; 0 255 0; 0 255 255];
% colorsMat = [0,255,255];

display.bkColor = backgroundCol;

dots.dotDensity = 3;
dots.speed = 10; % Speed of the dots (degrees/second)
dots.direction = angle;
dots.lifetime = 40;
dots.apertureSize = [];
dots.center = [0,0];
dots.color = [];
dots.size = 100;
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