function plotSigmaFromSingleGausFit(filepath, secondCndDimension)
% Plots sigma value from LS orientation fit, ie tuning curve width for
% cells and reates a map to save
%
% Inputs:  filepath - processed data folder containing the
%                     experimentStructure.mat, or the fullfile to the
%                     experimentStructure.mat OR the structure itself
%
%          secondCndDimension - number of conditions in the second
%                               dimension, e.g. colors tested, ie 1 for
%                               black/white, 4 monkey color paradigm, or
%                               number of spatial frequencies etc
%                               default = 1

%% set defaults

% gets the experimentStructure
if ~isobject(filepath)
    try
        load(filepath, '-mat');
        filePath2Use = dir(filepath);
        experimentStructure.savePath = [filePath2Use.folder '\'] ;
    catch
        if exist([filepath '\experimentStructure.mat'], 'file' )
            load([filepath '\experimentStructure.mat']);
            experimentStructure.savePath = [filepath '\'];
        else
            folder2Try = dir([filepath '\**\experimentStructure.mat']);
            load([folder2Try.folder '\experimentStructure.mat']);
        end        
    end
else % if variable is the experimentStructure
    experimentStructure = filepath;
    clearvars filepath
end

if nargin <2 || isempty(secondCndDimension)
    secondCndDimension = 1;
end

% get the orientation groups for each of the second
totalCnds = 1:length(experimentStructure.cndTotal);
orientationsBy2ndDim = reshape(totalCnds,[],secondCndDimension)';

%% Get single guassian orientation fit per 2nd Dimension (ie color etc)

for cell = 1:experimentStructure.cellCount
    
    meanData = mean(cell2mat(experimentStructure.dFstimWindowAverageFBS{cell}));
    
    % for each second dimension condition
    for i =1:secondCndDimension
        
        % get guassian width
        try % if the fit did nto work sets the guasWidth to NaN
            gausWidth(cell,i) = experimentStructure.OSIStruct{cell,i}.LSStruct.Peak1Width;
            gausR2(cell,i) = experimentStructure.OSIStruct{cell,i}.LSStruct.rsquare;
            
            if gausR2(cell,i) < 0.5  % R2 value threshold for fit
                gausWidth(cell,i) = NaN;
            end
        catch
            gausWidth(cell,i) = NaN;
        end
    end
end

%% fill maps per 2ndDim for Sigma
cellROIs = experimentStructure.labeledCellROI;
for i =1:secondCndDimension
    
    % sets up blank image
    cellMap = zeros(experimentStructure.pixelsPerLine);
    for cell = 1:experimentStructure.cellCount
            cellMap(cellROIs ==cell) = gausWidth(cell, i);
    end
    grandMaps(:,:,i) = cellMap;
end

grandMapsNorm = grandMaps/max(grandMaps(:));

%% Plot maps
for i =1:secondCndDimension
    rgbMap = ind2rgb(round(grandMapsNorm(:,:,i)*256), [MSHot; 0.5 0.5 0.5]);
    colormap(MSHot);
    figMap = imshow(rgbMap);
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    colorBar = colorbar ;
    axis on
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    axis square
    tightfig;
    colorBar.Ticks = linspace(0,1, 5);
    colorBar.TickLabels = linspace(min(grandMaps(:)), max(grandMaps(:)), 5);
    
    saveas(gcf, [experimentStructure.savePath  'Gaus width _Cnd_' num2str(i) '.svg']);
    imwrite(rgbMap, [experimentStructure.savePath  'Gaus width native_Cnd_' num2str(i) '.tif']);              
end
end