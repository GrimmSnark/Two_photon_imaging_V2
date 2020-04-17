function [gratingid, gratingrect, gratingMatrix] = createSquareWaveGrating(windowPtr,width, height, onColor, backgroundColor, cycleInPix, fastCreation)
% Creates square wave grating object for psychtoolbox with defined off and
% on colors, very fast if using the fast creation option on GPU
%
% Inputs: windowPtr - PTB pointer to the screen for grating presentation
%         width - width of grating in pixels
%         height - height of grating in pixels
%         onColor - RGB triplet for on color
%         backgroundColor - RGB triplet for off color
%         cycleInPix - spatial frequency of grating in pixels
%         fastCreation - flag to create stimulus on GPU(1), very fast OR on
%         CPU (0) slower
%
% Outputs: gratingid - PTB pointer to the grating 
%          gratingrect - PTB pointer to the grating bounding box
%          gratingMatrix - The matrix of the image created

%% build grating
% calculate on/off pix cycle
onPeriod = round(cycleInPix/2);

% get full cycle in pixels
gratingLine = [ones(1, onPeriod) zeros(1, onPeriod)];

% get number of cycles per screen
numOfCycles = ceil(width/length(gratingLine));

% build grating RGB matrix

if fastCreation ==1
    % if fast creation set, only produces single row, this gets
    % automatically turned into a full grating by make texture A LOT
    % FASTER!!
    onCol = reshape(repmat(onColor, onPeriod, 1), [1,onPeriod,length(onColor)]);
    offCol = reshape(repmat(backgroundColor, onPeriod, 1), [1,onPeriod,length(onColor)]);
    gratingMatrix = repmat([onCol offCol], 1, numOfCycles, 1);
else
    onCol = permute(repmat(onColor, height, 1, onPeriod), [1 3 2]);
    offCol = permute(repmat(backgroundColor, height, 1, onPeriod), [1 3 2]);
    gratingMatrix = repmat([onCol offCol], 1, numOfCycles,1);
end

%% Add to PTB
gratingid=Screen('MakeTexture', windowPtr, gratingMatrix);
% Query and return its bounding rectangle:
gratingrect = Screen('Rect', gratingid);



end