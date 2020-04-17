function PTB_Melanopsin_Mnky_Flash(stimTime, postStimTime, numReps)
% Visual stimulus script with uses Paul's sheeple arduino LED stimulator to
% flash blue light stimulus. Used to test light evoked response during
% brain injection surgeries
%
% Inputs: stimTime - stimulus on time in seconds
%         postStimTime - inter trial interval in seconds
%         numReps - number of repeats of each stimulus

%% initial set up of experiment

% open arduino
ardBoard = serial('COM4', 'BaudRate', 9600,'Terminator','CR/LF');
fopen(ardBoard);

levelStim = 0; % max brightness

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display total experiment predicted time and query continue.....

lengthofTrial =  stimTime + postStimTime;
totalTrialNo =  numReps;
totalTime = lengthofTrial * totalTrialNo;

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('');
disp(['This experiment will take approx. ' num2str(totalTime) 's (' num2str(totalTime/60) ' minutes)']);
disp('If you want to procceed press SPACEBAR, if you want to CANCEL, pres ESC');
disp('');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

[secs, keyCode, deltaSecs] = KbWait([],2, inf);

keypressNo = find(keyCode);

if keypressNo == 27 % ESC code = 27
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% start experimen

experimentStartTime = tic;
for currentBlkNum = 1:numReps
    counter = 0;
    for trialCnd = 1:length(levelStim)
        channel = 9;
        counter = counter +1;
        % get current time till estimated finish
        currentTimeUsed = toc(experimentStartTime);
        timeLeft = (totalTime - currentTimeUsed)/60;
        
        if channel == 9
            channelText = 'Blue';
        elseif channel == 10
            channelText = 'Red';
        end
        
        %display trial conditions
        
        fprintf(['Block No: %i of %i \n'...
            'Condition No: %i of %i \n' ...
            'LED Color: %s \n' ...
            'Intensity: %d \n'...
            'Estimated Time to Finish = %.1f minutes \n' ...
            '############################################## \n'] ...
            ,currentBlkNum, numReps, counter, length(levelStim)*2, channelText, levelStim(trialCnd),  timeLeft);
        
        
        WaitSecs(preStimTime);
        
        melanopsinStimON(ardBoard, channel ,levelStim(trialCnd),stimTime*1000);
        WaitSecs(stimTime);
        
        WaitSecs(postStimTime);
        
        % Abort requested? Test for keypress:
        if KbCheck
            break;
        end
    end
    % Abort requested? Test for keypress:
    if KbCheck
        break;
    end
end

toc(experimentStartTime);

fclose(ardBoard);
clear ardBoard

end