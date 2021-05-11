function display = OpenWindow(display)
%display = OpenWindow([display])
%
%Calls the psychtoolbox command "Screen('OpenWindow') using the 'display'
%structure convention.
%
%Inputs:
%   display             A structure containing display information with fields:
%       screenNum       Screen Number (default is 2)
%       bkColor         Background color (default is black: [0,0,0])
%       skipChecks      Flag for skpping screen synchronization (default is 2, or don't check)
%                       When set to 1, vbl sync check will be skipped,
%                       along with the text and annoying visual (!) warning
%                       When set to 2, the text and annoying visual (!)
%                       warning wil be skipped
%       loadGamma       Loads the gamma correction table (default 1, or
%                       load table)
%       displaySetup    Number reference to display setup, ie pixel per
%                       degree etc, see degreeVisualAngle2Pixels, DEFAULT==
%                       3, mouse setup RSB
%
%Outputs:
%   display             Same structure, but with additional fields filled in:
%       windowPtr       Pointer to window, as returned by 'Screen'
%       frameRate       Frame rate in Hz, as determined by Screen('GetFlipInterval')
%       resolution      [width,height] of screen in pixels
%       center          [x,y] center of screeen in pixels 
%       oldTable        Old gamma correction table ti reload after
%                       experiment end
%
%Note: for full functionality, the additional fields of 'display' should be
%filled in:
%
%       dist             distance of viewer from screen (cm)
%       width            width of screen (cm)

%Written 11/13/07 by gmb
% 9/17/09 gmb zre added the 'center' field in ouput of display structure.

if ~exist('display','var')
    display.screenNum = 2;
end

if ~isfield(display,'screenNum')
    display.screenNum = 2;
end

if ~isfield(display,'bkColor')
    display.bkColor = [0,0,0]; %black
end

if ~isfield(display,'skipChecks')
    display.skipChecks = 2;
end

if display.skipChecks == 1
    Screen('Preference', 'Verbosity', 0);
    Screen('Preference', 'SkipSyncTests',1);
    Screen('Preference', 'VisualDebugLevel',0);
    
elseif display.skipChecks == 2
    Screen('Preference', 'VisualDebugLevel',0);
    PsychDefaultSetup(2); % PTB defaults for setup
end

if ~isfield(display,'loadGamma')
    display.loadGamma = 1;
end

if ~isfield(display,'displaySetup')
    display.displaySetup = 3;
end


Screen('Preference', 'SuppressAllWarnings', 1);
PsychImaging('PrepareConfiguration');

% try to open screen, can have issues on windows, so retry till it works
count = 0;
errorCount = 0;
while count == errorCount
    try
        [display.windowPtr, res] = PsychImaging('OpenWindow',  display.screenNum, display.bkColor); %opens screen and sets background to grey
    catch
        disp(['Screen opening error detected......retrying']);
        errorCount = errorCount+1;
    end
    count = count+1;
end


% load gamma table
if display.loadGamma == 1
try
    load 'C:\All Docs\calibrations\gammaTableGamma.mat'
catch
    load 'C:\PostDoc Docs\Two Photon Rig\calibrations\LCD monitor\gammaTableGamma.mat'
end
display.oldTable = Screen('LoadNormalizedGammaTable', display.windowPtr, gammaTable1*[1 1 1]);
end


%Set the display parameters 'frameRate' and 'resolution'
display.frameRate = 1/Screen('GetFlipInterval',display.windowPtr); %Hz

if ~isfield(display,'resolution')
    display.resolution = res([3,4]);
end

display.center = floor(display.resolution/2);

end
