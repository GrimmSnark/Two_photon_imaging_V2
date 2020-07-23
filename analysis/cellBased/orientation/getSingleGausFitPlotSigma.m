function getSingleGausFitPlotSigma(folder2Process, secondCndDimension)
% Fits single gaussian curve over orientation responses which span 0-180
% degrees or test orientation regardless of direction
% (PTBOrientationWColorMnky). Collates the sigma value (the tuning width)
% and the R2 value (goodness of fit and adds them to the
% experiementStructure.
%
% Inputs: folder2Process - processed data folder containing the
%                          experimentStructure.mat, or the fullfile to the
%                          experimentStructure.mat OR the structure itself
%
%          secondCndDimension - number of conditions in the second
%                               dimension, e.g. colors tested, ie 1 for
%                               black/white, 4 monkey color paradigm, or
%                               number of spatial frequencies etc
%                               default = 1

%% set defaults

% Allows for the folder2Process to be not the one set in
% experimentStructure.savePath
try
    load(folder2Process, '-mat');
    filePath2Use = dir(filepath);
    experimentStructure.savePath = [filePath2Use.folder '\'] ; 
catch
    load([folder2Process '\experimentStructure.mat']);
    experimentStructure.savePath = [folder2Process '\']; 
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
        if ~any(isnan(meanData))
            % fit the guassian
            x=interp1(meanData(orientationsBy2ndDim(i,:)),linspace(1,6,18));
            gausStruct = singleGaussianFit(x);
            
            % get the sigma (width of fit) R2 (goodness of fit)
            grandSigma(i,cell) = gausStruct(3);
            grandR2(i,cell) = gausStruct(end);
            
            if gausStruct(end) > 0.5 % R2 value threshold for fit
                gausWidth(i,cell) =gausStruct(3);
            else
                gausWidth(i,cell) = NaN;
            end
        else
            gausWidth(i,cell) = NaN;
        end
    end
end

%% fill maps per 2ndDim for Sigma
cellROIs = experimentStructure.labeledCellROI;
for i =1:secondCndDimension
    
    % sets up blank image
    cellMap = zeros(experimentStructure.pixelsPerLine);
    for cell = 1:experimentStructure.cellCount
            cellMap(cellROIs ==cell) = gausWidth(i,cell);
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

% deals with class object stuff
try
    experimentStructure.dFstimWindowAverageFBSSigmaFit = grandSigma;
    experimentStructure.dFstimWindowAverageFBSSigmaR2 = grandR2;
catch
    experimentStructure.addprop('grandSigma');
    experimentStructure.addprop('grandR2');
    
    experimentStructure.dFstimWindowAverageFBSSigmaFit = grandSigma;
    experimentStructure.dFstimWindowAverageFBSSigmaR2 = grandR2;
end

save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure', '-v7.3');

end