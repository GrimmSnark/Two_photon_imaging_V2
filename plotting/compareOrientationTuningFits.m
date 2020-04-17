function compareOrientationTuningFits(experimentStructureOrFilepath, cellNo, noOrientations, angleMax)
% Plots different orientation tuning curve fits to compare different
% methods
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

if ~isstruct(experimentStructureOrFilepath)
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

if nargin < 4 || isempty(angleMax)
    angleMax = 360;
end


data = experimentStructure.dFstimWindowAverageFBS;


%% plot the things
for i =cellNo
    
    % create figure
    figHandle = figure('units','normalized','outerposition',[0 0 1 1]);
    
    % get angles for labels
    angles     = linspace(0,angleMax,noOrientations+1);
    angles     = angles(1:end-1);
    
    % get mean data
    dataMean= mean(cell2mat(data{i}));
    
    % get fits
    vhFit = experimentStructure.OSIStruct(i).VHStruct.fit;
    
    % accounts for cells which were unable to fit
    try
        lsFit = experimentStructure.OSIStruct(i).LSStruct.modelTrace;
    catch
        lsFit = zeros(length(vhFit),1);
    end
    
    % get various OSIs
    vhOSI = experimentStructure.OSIStruct(i).VHStruct.OSI_PR;
    vhOSIRect = experimentStructure.OSIStruct(i).VHStruct.ot_index_rectified;
    prOSI = experimentStructure.OSIStruct(i).LSStruct.OSI;
    OSI_CV = experimentStructure.OSIStruct(i).OSI_CV;
    
    % get pref angle
    %      vhPrefOri = experimentStructure.OSIStruct(i).VHStruct.dirpref;
    %     prPrefOri = experimentStructure.OSIStruct(i).PRStruct.;
    
    % plot the fits and averages
    hold on
    plot(vhFit(1,:),vhFit(2,:), 'r', 'LineWidth',2);
    plot(vhFit(1,:),lsFit,'k', 'LineWidth',2);
    plot(angles, dataMean, '-*b', 'LineWidth',2,'MarkerSize',10);
    
    % labels
    legend([{'Van Hooser'},{'Sincich'}, {'Real Data'}]);
    ylabel('\DeltaF/F')
    xlabel(sprintf('Stimulus direction (%s)', char(176)));
    xlim([0 360]);
    
    % title
    title(['Cell Number: ' num2str(i) '     OSI-Circular Variance: ' num2str(OSI_CV) '      OSI-VH / Rectified: ' num2str(vhOSI) '/ ' num2str(vhOSIRect) '     OSI-PR: ' num2str(prOSI)]);
    
    if ~exist([experimentStructure.savePath 'compFit\'], 'dir')
        mkdir([experimentStructure.savePath 'compFit\']);
    end
    
    saveas(figHandle, [experimentStructure.savePath 'compFit\compareFits Cell ' num2str(i) '.tif']);
    close
end
end