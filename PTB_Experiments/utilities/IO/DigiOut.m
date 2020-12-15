function err = DigiOut(daq, port, signal, waitTime)
% function sends out digital signal using the DaqDOut function but also
% incorperates a wait time in seconds before resetting to 0

err = DaqDOut(daq,port,signal);
WaitSecs(waitTime);
err = DaqDOut(daq,port,0);

end