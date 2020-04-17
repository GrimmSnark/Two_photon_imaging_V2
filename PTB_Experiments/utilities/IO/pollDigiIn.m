function dataOut =  pollDigiIn(daq, portOutNum)
% Polls the digital ports as fast as possible in the foreground. Tested
% with USB1208FS and USB1408FS
%
% Inputs -  daq (daq identifer)
%           portOutNum (0/1 for port A or B)
%
% Output - dataOut (8 bit integer os singal out)

reportId = 3;
TheReport = uint8(0);
NumberOfPorts = 2;

if IsWin
    % Windows needs some minimal polling time:
    options.secs = 0.001;
else
    options.secs = 0.000;
end

PsychHID('ReceiveReportsStop',daq);
PsychHID('GiveMeReports',daq);
PsychHID('ReceiveReports',daq, options);

% while 1
    % Emit query to device:
    PsychHID('SetReport',daq,2,reportId, TheReport);
    
    % Wait for result from device:
    inreport = [];
    while isempty(inreport)
        inreport = PsychHID('GetReport',daq,1,reportId,NumberOfPorts+1);
    end
    
    % output various port data
    if portOutNum == 0
        dataOut = inreport(2);
    elseif portOutNum ==1
        dataOut = inreport(3);
    else
        disp('Wrong Port Number');
        return
    end
    %     disp(dataOut);
    
% end
    
end
