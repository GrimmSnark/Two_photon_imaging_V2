function compareOrientationTuningFitsLS(experimentStructureOrFilepath, cellNo, noOrientations, secondCndDimension, angleMax)
% Plots different orientation tuning curve fits to monkey data with LS fits
%
% Inputs:  experimentStructureOrFilepath - processed data folder containing
%                                          the experimentStructure.mat, or 
%                                          the fullfile to the
%                                          experimentStructure.mat
%
%          cellNo- number or vector of numbers for cells to plot
%
%          noOrientations - number of orientations tested in the experiment
%                          ie 4/8 etc, default = 8
%
%          angleMax - 360 or 180 for the Max angle tested, default = 360


%% set defaults

if ~isobject(experimentStructureOrFilepath)
    try
        load(experimentStructureOrFilepath, '-mat');
        filePath2Use = dir(experimentStructureOrFilepath);
        experimentStructure.savePath = [filePath2Use.folder '\'] ;
    catch
        load([experimentStructureOrFilepath '\experimentStructure.mat']);
        experimentStructure.savePath = [experimentStructureOrFilepath '\'];
    end
else
    experimentStructure = experimentStructureOrFilepath;
    delete experimentStructureOrFilepath;
end

if nargin < 2 || isempty(cellNo)
    try
        cellNo = 1:experimentStructure.cellCount;
    catch
        disp('No Cell ROIs found, please choose ROIs first!!!');
        return
    end
end

if nargin < 3 || isempty(noOrientations)
    noOrientations = 8;
end

if nargin < 4 || isempty(secondCndDimension)
    secondCndDimension = 4;
end


if nargin < 5 || isempty(angleMax)
    angleMax = 360;
end

data = cellfun(@mean,cellfun(@cell2mat,experimentStructure.dFstimWindowAverageFBS, 'Un', 0), 'Un', 0);


% checks if your inputs for condition numbers are correct
cndNo = noOrientations * secondCndDimension;
if cndNo~= length(experimentStructure.cndTotal)
    disp('Input wrong number of conditions, please fix!!');
    return
end

% split coditions into matrix by second dimension
condtionsBy2ndDim = reshape(1:cndNo,noOrientations, [])';

% get angle identities
angles = linspace(0, angleMax, noOrientations+1);
angles = angles(1:end-1);


ConeText = [{'L Cone'} {'M Cone'} {'LM Cone'} {'S Cone'}];

%% plot the things
for i =cellNo
   
    % create figure
    figHandle = figure('units','normalized','outerposition',[0 0 0.5 1]);
    for snd = 1:secondCndDimension
        
        subplot(secondCndDimension,1,snd);
        data2Use = data{i}(condtionsBy2ndDim(snd,:));
        
        originalData=interp1(data2Use,linspace(1,length(angles),18));
        
        
        lsFit = experimentStructure.OSIStruct{i,snd}.LSStruct.modelTrace;
        
        % plot the fits and averages
        hold on
        plot(lsFit,'k', 'LineWidth',2);
        plot(1:10:angleMax, originalData, '-*b', 'LineWidth',2,'MarkerSize',10);
        
        % labels
        if snd == 1
            legend([{'Sincich'}, {'Real Data'}]);
        end
        ylabel('\DeltaF/F')
        xlabel(sprintf('Stimulus direction (%s)', char(176)));
        xlim([0 angleMax]);
        title(ConeText{snd});
        
    end
    
    tightfig
    % title
    suptitle(['Cell Number: ' num2str(i)]);
    
    if ~exist([experimentStructure.savePath 'compFit\'], 'dir')
        mkdir([experimentStructure.savePath 'compFit\']);
    end
    
    saveas(figHandle, [experimentStructure.savePath 'compFit\compareFits Cell ' num2str(i) '.tif']);
    close

end
end