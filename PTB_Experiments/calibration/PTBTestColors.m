function PTBTestColors
% Displays black & white screen for defined on & off times to see how the
% screen stim and send events into Prairie sync up

%% set up parameters of stimuli
clc
sca;


%% intial set up of experiment
Screen('Preference', 'VisualDebugLevel', 1); % removes welcome screen
PsychDefaultSetup(2); % PTB defaults for setup
screenNumber = max(Screen('Screens')); % makes display screen the secondary one


% Define black, white and grey for background
% r g b
b = 0/255;
color = [1 1 1];

PsychImaging('PrepareConfiguration');
[windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, color); %opens screen and sets background to grey

%% START STIM PRESENTATION


WaitSecs(5); % intial wait time

while ~KbCheck
        Screen('Flip', windowPtr);
    
end

% Clear screen
sca;

end