function plotOrientationContrastOSIDepth(filepath, plotDiffCellTypes)


metricNo2Use  = 3; 

if nargin < 2 || isempty(plotDiffCellTypes)
   plotDiffCellTypes = 0; 
end

%% gather the data
filepathList = dir([filepath '\**\*experimentStructure.mat']);
for x = 1:length(filepathList)
    [OSIMetrics_perRecording{x}, metricIdentifiers, recordingLocs(x,:)] = gatherOrientationMetrics(filepathList(x).folder , 1:4, []);
end


%%
%%%%%%%%% For single type of cells
if plotDiffCellTypes == 0
%% set up figure for depth plot
f1 = figure('units','normalized','outerposition',[0 0 0.4 1]);
contrasts = [0.2 0.4 0.6 0.8 1];

lineStyles = linspecer(size(OSIMetrics_perRecording,2)+1,'blue');

% for each depth
for c =1: length(OSIMetrics_perRecording)
    
    currentData = OSIMetrics_perRecording{c};
    subplot(length(OSIMetrics_perRecording), 1, c);
    
    % for each contrast
    for i = 1:size(currentData,2)
        medianNo = median(currentData(:,i,metricNo2Use));
        hist1 = histfitV2(currentData(:,i,metricNo2Use),50, 'kernel', 0, length(currentData(:,i,metricNo2Use)));
        set(hist1(1),'color',lineStyles(i+1,:), 'DisplayName', ['Con-' num2str(contrasts(i)) '  OSI: ' num2str(medianNo)])
        hold on;
    end
    
    title(['Z Location: ' num2str(recordingLocs(c,3)) ' Number Cells = ' num2str(size(currentData,1))]);
    legend
    ylabel('Relative Frequency (%)')
end

xlabel('OSI (1-CV)')

saveas(f1, [ filepath '\OSI_CV_depths_PR.fig']);
saveas(f1, [ filepath '\OSI_CV_depths_PR.png']);

%% set up all cells plot
OSIMetrics_animal = [];

for z =1:length(OSIMetrics_perRecording)
    OSIMetrics_animal = cat(1, OSIMetrics_animal,OSIMetrics_perRecording{x});
end


f2 = figure('units','normalized','outerposition',[0 0 0.3 0.3]);
contrasts = [0.2 0.4 0.6 0.8 1];

lineStyles = linspecer(size(OSIMetrics_animal,2)+1,'blue');

for i = 1:size(OSIMetrics_animal,2)
    
    medianNo = median(OSIMetrics_animal(:,i,1));
    hist1 = histfitV2(OSIMetrics_animal(:,i,1),50, 'kernel', 0, length(OSIMetrics_animal(:,i,1)));
    set(hist1(1),'color',lineStyles(i+1,:), 'DisplayName', ['Con-' num2str(contrasts(i)) '  OSI: ' num2str(medianNo)])
    hold on;
end


ylabel('Relative Frequency (%)');
xlabel('OSI (1-CV)');
title(['Number Cells = ' num2str(size(OSIMetrics_animal,1))]);
legend

saveas(f2, [filepath '\OSI_CV_all_Cells_PR.fig']);
saveas(f2, [filepath '\OSI_CV_all_Cells_PR.png']);

close all

else
%% %%%%%%% For two type of cells, ie PV and non PV
%% set up figure for depth plot
f1 = figure('units','normalized','outerposition',[0 0 0.6 1]);
contrasts = [0.2 0.4 0.6 0.8 1];

% for each depth
counter = 0;
for c =1: length(OSIMetrics_perRecording)
   
    for b = 0:1
        counter = counter +1;
        if b ==0
            lineStyles = linspecer(size(OSIMetrics_perRecording,2)+1,'blue');
        else
            lineStyles = linspecer(size(OSIMetrics_perRecording,2)+1,'red');
        end
        
        % limit data to either channel non overlap (0) or channel overlap
        % (1) cells
        currentData = OSIMetrics_perRecording{c};
        currentData = currentData(currentData(:,1,end)==b,:,:);
        
        
        subplot(length(OSIMetrics_perRecording), 2, counter);
        
        % for each contrast
        for i = 1:size(currentData,2)
            medianNo = median(currentData(:,i,metricNo2Use));
            hist1 = histfitV2(currentData(:,i,metricNo2Use),50, 'kernel', 0, length(currentData(:,i,metricNo2Use)));
            set(hist1(1),'color',lineStyles(i+1,:), 'DisplayName', ['Con-' num2str(contrasts(i)) '  OSI: ' num2str(medianNo)])
            hold on;
        end
        
        title(['Z Location: ' num2str(recordingLocs(c,3)) ' Number Cells = ' num2str(size(currentData,1))]);
        legend
        ylabel('Relative Frequency (%)')
    end
end

xlabel('OSI (1-CV)')

saveas(f1, [ filepath '\OSI_CV_depths_CellType_PR.fig']);
saveas(f1, [ filepath '\OSI_CV_depths_CellType_PR.png']);

%% set up all cells plot
OSIMetrics_animal = [];

for z =1:length(OSIMetrics_perRecording)
    OSIMetrics_animal = cat(1, OSIMetrics_animal,OSIMetrics_perRecording{x});
end


f2 = figure('units','normalized','outerposition',[0 0 0.6 0.3]);
contrasts = [0.2 0.4 0.6 0.8 1];

for b = 0:1
    counter = counter +1;
    if b ==0
        lineStyles = linspecer(size(OSIMetrics_perRecording,2)+1,'blue');
    else
        lineStyles = linspecer(size(OSIMetrics_perRecording,2)+1,'red');
    end
    
    
    currentData = OSIMetrics_animal(OSIMetrics_animal(:,1,end)==b,:,:);
    subplot(1, 2, b+1);
    
    for i = 1:size(currentData,2)
        
        medianNo = median(currentData(:,i,metricNo2Use));
        hist1 = histfitV2(currentData(:,i,metricNo2Use),50, 'kernel', 0, length(currentData(:,i,metricNo2Use)));
        set(hist1(1),'color',lineStyles(i+1,:), 'DisplayName', ['Con-' num2str(contrasts(i)) '  OSI: ' num2str(medianNo)])
        hold on;
    end
    
    ylabel('Relative Frequency (%)');
    xlabel('OSI (1-CV)');
    title(['Number Cells = ' num2str(size(currentData,1))]);
    legend
end


saveas(f2, [filepath '\OSI_CV_all_Cells_CellType_PR.fig']);
saveas(f2, [filepath '\OSI_CV_all_Cells_CellType_PR.png']);

close all
end
    

end