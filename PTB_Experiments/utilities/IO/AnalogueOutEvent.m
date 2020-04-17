function AnalogueOutEvent(daq, string)
% sends out pulse through the 1st analogue port of USB 14 etc for string
% event


% hard codes
port =0;
outputSignal = linspace(0, 1, 256); % for some unholy reason the DaqAOut function takes a number between 0-1 to output voltage in voltageRange FFS!!!
outputSignal = outputSignal(2:end); % removes 0 level from signal list
waitTime = 0.002;
codes = prairieCodes();

% find voltage level equal to string event
level = find(strcmp(string, codes), 1);

signal = outputSignal(level);
AnalogueOut(daq, port, signal, waitTime);

end