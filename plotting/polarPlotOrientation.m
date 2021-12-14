function polarPlotOrientation(filepath, cellNo, noOrientations, angleMax, secondCndDimension, data2Plot, colors)
% Creates and saves polar plots for orientation experiments, can process
% both orientation and combined orientation and color/SF experiments
%
% Inputs:  filepath - processed data folder containing the
%                     experimentStructure.mat, or the fullfile to the
%                     experimentStructure.mat OR the structure itself
%
%          cellNo- number or vector of numbers for cells to plot
%
%          noOrientations - number of orientations tested in the experiment
%                          ie 4/8 etc, default = 8
%
%          angleMax - 360 or 180 for the Max angle tested, default = 360
%
%          secondCndDimension - number of conditions in the second
%                               dimension, e.g. colors tested, ie 1 for
%                               black/white, 4 monkey color paradigm, or
%                               number of spatial frequencies etc
%                               default = 1
%
%           RGB triplet for colors for each of the different orientation
%           types ie for each color OPTIONAL, will use black for single
%           orientation or default to four colors


%% set defaults

% gets the experimentStructure
if ~isobject(filepath)
    try
        load(filepath, '-mat');
        filePath2Use = dir(filepath);
        experimentStructure.savePath = [filePath2Use.folder '\'] ;
    catch
        load([filepath '\experimentStructure.mat']);
        experimentStructure.savePath = [filepath '\'];
    end
else % if variable is the experimentStructure
    experimentStructure = filepath;
    clearvars filepath
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

if nargin < 5 || isempty(secondCndDimension)
    secondCndDimension = 1;
    colors = 'k';
end

if nargin < 6 || isempty(data2Plot)
    data2Plot = 1;
end



% set colors for plotting
if nargin < 7 || isempty(colors)
    % colors for monkey orientation colors
    colors = [1 0 0; 0 0.5 0; 1 0.5 0; 0 0 0.5];
end


%% get the data

% get data into useful form
meanData = cellfun(@mean,cellfun(@cell2mat,experimentStructure.dFstimWindowAverageFBS, 'Un', 0), 'Un', 0);
meanDataRearranged = cellfun(@(X) reshape(X,noOrientations,[]), meanData, 'Un', 0);


% get angles as rad
polarAngles = deg2rad(linspace(0, angleMax, noOrientations +1));

% for the cells listed
for x = cellNo
    
    switch data2Plot
        case 1
            % if there are multiple repeats of orientations, ie for every color
            if secondCndDimension> 1
                for i = 1:size(meanDataRearranged{1,x},2)
                    polarplot(polarAngles, [meanDataRearranged{1,x}(:,i) ; meanDataRearranged{1,x}(1,i)], 'color', colors(i,:), 'LineWidth', 2);
                    hold on
                end
            else
                polarplot(polarAngles, [meanDataRearranged{1,x} ; meanDataRearranged{1,x}(1)], 'color', colors, 'LineWidth', 2);
            end
            
            % format the plot properly
            polarPl = gca;
            polarPl.ThetaZeroLocation = 'bottom';
            polarPl.ThetaDir = 'clockwise';
            thetalim([0 angleMax]);
            
            if ~exist([experimentStructure.savePath 'polarPlots\'], 'dir')
                mkdir([experimentStructure.savePath 'polarPlots\']);
            end
            
            % saves
            saveas(gcf, [experimentStructure.savePath 'polarPlots\Polar Plot Cell ' num2str(x) '.tif']);
            saveas(gcf, [experimentStructure.savePath 'polarPlots\Polar Plot Cell ' num2str(x) '.svg']);
            close;
            
            
        case 2
            ang2plot = deg2rad(1:1:angleMax);
            % if there are multiple repeats of orientations, ie for every color
            if secondCndDimension> 1
                for i = 1:secondCndDimension
                    polarplot(ang2plot,experimentStructure.OSIStruct{x, i }.LSStruct.modelTrace  , 'color', colors(i,:), 'LineWidth', 2);
                    hold on
                end
            else
                polarplot(polarAngles, [meanDataRearranged{1,x} ; meanDataRearranged{1,x}(1)], 'color', colors, 'LineWidth', 2);
            end
            
            % format the plot properly
            polarPl = gca;
            polarPl.ThetaZeroLocation = 'bottom';
            polarPl.ThetaDir = 'clockwise';
            thetalim([0 angleMax]);
            
            if ~exist([experimentStructure.savePath 'polarPlots\'], 'dir')
                mkdir([experimentStructure.savePath 'polarPlots\']);
            end
            
            % saves
            saveas(gcf, [experimentStructure.savePath 'polarPlots\Polar Plot Fits Cell ' num2str(x) '.tif']);
            saveas(gcf, [experimentStructure.savePath 'polarPlots\Polar Plot Fits Cell ' num2str(x) '.svg']);
            close;
    end
end


end