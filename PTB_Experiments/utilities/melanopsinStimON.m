function melanopsinStimON(arduinoPointer, channel,level,duration)
% Turns on melanopsin LED via serial port connection to arduino
%
% Inputs: arduinoPointer- pointer to board
%         channel - 9: Blue LED, 10: Red LED
%         level - 16bit value for intensity (65535 = min, 0 = max)
%         duration - duration in ms

string = [num2str(channel) ',' num2str(level) ':' num2str(duration) '\n'];
fprintf(arduinoPointer,'%s',string );
end