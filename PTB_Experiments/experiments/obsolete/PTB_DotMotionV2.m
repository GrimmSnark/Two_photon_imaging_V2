function PTB_DotMotionV2()

% 10000 dots by default:
dotDensity = 10000;

% 10 frames lifetime per dot by default:
dotLifetime = 20

% Is the script running in OpenGL Psychtoolbox? Abort, if not.
AssertOpenGL;

% Setup unified keyboard mapping:
KbName('UnifyKeyNames');
escape = KbName('ESCAPE');

% Find the screen to use for display:
screenid=max(Screen('Screens'));

% Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
% mogl OpenGL for Matlab wrapper:
InitializeMatlabOpenGL([], 0);

% Open a double-buffered full-screen window on the main displays screen,
% with fast Offscreen window support enabled and black background clear
% color. Fast Offscreen windows support is needed for moglFDF to work.
PsychImaging('PrepareConfiguration');
Screen('Preference', 'SkipSyncTests', 1);
PsychImaging('AddTask', 'General', 'UseFastOffscreenWindows');
[win , winRect] = PsychImaging('OpenWindow', screenid, 0);


    % Debug output settings for moglFDF: Most useful are -1 for real object
    % render and 1 for silhouette render, as well as 0 for normal op.
    moglFDF('DebugFlag', 0);

    % Stimulus parameters:

    % Size of the final output window to be drawn to:
    rect = Screen('Rect', win);
    
    % Texture coordinates on the surface of our demo object are in the
    % range 0.0 to 1.0 in both x- and y- direction:
    texCoordMin   = [0.0 , 0.0];
    texCoordMax   = [1.0 , 1.0];
    
    % Resolve motion with 512 x 512 resolution:
    texResolution = [256 , 256];
    
    % Probability with which a randomly located dot within the silhouette
    % is drawn -- Kind of "Signal to noise" ratio within the objects
    % silhouette, if the "object-induced dot motion" is considered the
    % signal and the noise is considered the noise.
    % Values between 0 - 1 are meaningful:
    BGSilhouetteAcceptanceProbability = 0.0;
    
    % Use max 'dotDensity' foreground dots for sampling the objects
    % surface: In the current moglFDF implementation, maxFGDots must be an
    % integral multiple of the dotLifetime!
    maxFGDots = (1 - BGSilhouetteAcceptanceProbability) * dotDensity;

    % Use max 'dotDensity' dots for background distribution:
    maxBGDots = dotDensity;
    
  % Use occlusion culling: Dots that would stick to the occluded part of
    % the 3D objects surface are not drawn. By default - if this parameter
    % is omitted or set > 1 - all dots are drawn, even "occluded" ones.
    zThreshold = 0.0001;
    
    fdf = moglFDF('CreateContext', win, rect, texCoordMin, texCoordMax, texResolution, maxFGDots, maxBGDots, dotLifetime, zThreshold, BGSilhouetteAcceptanceProbability);
   
    
        callbackEvalString = 'gluDisk(mysphere, 0.7, 100, 100);';
    fdf = moglFDF('SetRenderCallback', fdf, callbackEvalString);

    
end