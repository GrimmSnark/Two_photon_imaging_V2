function err = AnalogueOut(daq, port, signal, waitTime)
% function sends out digital signal using the DaqAOut function but also
% incorperates a wait time in seconds before resetting to 0

err = DaqAOut(daq,port,signal);
WaitSecs(waitTime);
err = DaqAOut(daq,port,0);

end