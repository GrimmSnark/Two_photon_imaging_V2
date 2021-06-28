function PTB_DotMotion(angle)

dots.dotDensity = 20;
dots.speed = 5; % Speed of the dots (degrees/second)
dots.direction = angle;
dots.lifetime = 20;
dots.apertureSize = [];
dots.center = [0,0];
dots.color = [0,255,255];
dots.size = 8;
dots.coherence = 1;

 duration = []; %seconds
try
    display = OpenWindow([]);
    movingDots(display,dots,duration);
catch ME
    Screen('LoadNormalizedGammaTable', windowPtr, oldTable);
    Screen('CloseAll');
    rethrow(ME)
    
end
Screen('CloseAll');
end