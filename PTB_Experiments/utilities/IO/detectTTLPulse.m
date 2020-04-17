function detectTTLPulse(daq,portOutNum, digitalValue, edgeDetection)
% Detects TTL pulses from USB 1208FS/USB1408FS in the foreground, used to
% wait for TTL before continuing on with rest of code
%
% Inputs -  daq (daq identifer)
%           portOutNum (0/1 for port A or B)
%           digitalValue (expected value of TTL pulse, ie 128)
%           edgeDetection (1/2 for rising or falling edge detection)

currentDigiState = pollDigiIn(daq, portOutNum); % setting baseline to current DigitalIn (This may cause detection issues)
valueBuffer = [currentDigiState currentDigiState]; 

if edgeDetection == 1 % rising edge detection
    TTLTrigger = digitalValue;
elseif edgeDetection == 2 % falling edge detection
    TTLTrigger = -digitalValue;
end

slopeDiff = 0;
while slopeDiff ~= TTLTrigger % will poll continuously until TTL edge is dectected
    
    valueBuffer(1) = valueBuffer(2); % fills buffer based on last value
    valueBuffer(2) =  pollDigiIn(daq, portOutNum); % gets new value
    slopeDiff = valueBuffer(2)- valueBuffer(1); % calculates if there is any difference
end

disp('TTL Detected');

end