function AnalogueOutCode(daq, level)
% sends out pulse through the 1st analogue port of USB 14 etc at level(i.e
% 1-256)

% hard codes
port =0;
outputSignal = linspace(0, 1, 256); % for some unholy reason the DaqAOut function takes a number between 0-1 to output voltage in voltageRange FFS!!!
outputSignal = outputSignal(2:end); % removes 0 level from signal list
waitTime = 0.002;

signal = outputSignal(level);
AnalogueOut(daq, port, signal, waitTime);

end