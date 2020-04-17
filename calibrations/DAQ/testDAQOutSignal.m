function testDAQOutSignal()
% Function to test output range of USB1408FS for signal generation to the
% Prairie computer. The idea being that we can use analogue signal to mimic
% digital numbers. levels = bit levels (8bit=256 etc)

%% create signal
%voltageRange = [0 4.096]; % voltage range of output in V
%outputVoltLevels = linspace(voltageRange(1), voltageRange(2), levels); % voltage output

levels = 256; % i.e 8 bit signal
outputSignal = linspace(0, 1, levels); % for some unholy reason the DaqAOut function takes a number between 0-1 to output voltage in voltageRange FFS!!!

%% Check DAQ box etc
daq =[];

%devices=PsychHIDDAQS;

if isempty(daq)
    clear PsychHID;
    daq = DaqDeviceIndex([],0);
end

% trigger image scan start
DaqDConfigPort(daq,0,0);
err = DigiOut(daq, 0, 255, 0.1);

% send out all levels of voltage in ascending order
for x = 1:100
%while ~KbCheck
    for i =1:length(outputSignal)
        err = AnalogueOut(daq, 0, outputSignal(i), 0.002);
        WaitSecs(0.002);
    end
    
    WaitSecs(0.01);
end
end