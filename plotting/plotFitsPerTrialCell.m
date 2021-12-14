function plotFitsPerTrialCell(experimentStructure,saveDir,  fitGrandStruct, cellNo,  noOrientations, angleMax, secondCndDimension)
% Creates orientation fits to each block of the recording for each cell for
% each second condition (ie cone condition) Plots a fit against each
% oreintation response
%
%          experimentStructure - experimentStructure containing all data
%
%          saveDir - fullfile to save directory
%
%          fitGrandStruct- structure containing all orientation data
%
%          cellNo- number or vector of numbers for cells to plot
%
%          noOrientations - number of orientations tested in the experiment
%                          ie 4/8 etc, default = 6
%
%          angleMax - 360 or 180 for the Max angle tested, default = 180
%
%          secondCndDimension - number of conditions in the second
%                               dimension, e.g. colors tested, ie 1 for
%                               black/white, 4 monkey color paradigm, or
%                               number of spatial frequencies etc
%                               default = 4
%
%
%% set defaults

% saveDir = 'D:\Data\2P_Data\Processed\Monkey\M10_Sully_BF797C\run_11_OIST - Copy\TSeries-04042019-0932-012\20200423154339\trialOrientationFits\nonSigPatch\';

if nargin < 4 || isempty(noOrientations)
    noOrientations = 6;
end

if nargin < 5 || isempty(angleMax)
    angleMax = 180;
end

if nargin < 6 || isempty(secondCndDimension)
    secondCndDimension = 4;
end

%%
data = experimentStructure.dFstimWindowAverageFBS;

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


%
peakSD = std(fitGrandStruct.peaks,[],3);
ConeText = [{'L Cone'} {'M Cone'} {'S Cone'}];

% for each cell
for c = 1:size(fitGrandStruct.fitStruct,1)
    
    % for each color
    for x = 1:size(fitGrandStruct.fitStruct,2)
        
        figHandle = figure('units','normalized','outerposition',[0 0 0.5 1]);
        
        % for each block
        for tr = 1:size(fitGrandStruct.fitStruct,3)
            
            data2Use = cell2mat(data{cellNo(c)}(tr,condtionsBy2ndDim(x,:)));
            
            originalData = interp1([ data2Use data2Use(1)],linspace(1,length(data2Use)+1,19)); % wrap around first condition and interp to number required + 1
            originalData = originalData(1:18); % limit to 18 numbers, ie input for single guassian fit
            
%             originalData=interp1(data2Use,linspace(1,length(angles),18));
            
            currentStruct = fitGrandStruct.fitStruct(c,x,tr);
            currentFit = currentStruct.modelTrace;
            
            subplot(size(fitGrandStruct.fitStruct,3),1,tr);
            plot(currentFit,'r');
            hold on
            plot([1:10:180],originalData, 'k');
            
        end
        
        
        subplotEvenAxes(gcf)
        tightfig
        suptitle(['Cell No. ' num2str(cellNo(c)) ' ' ConeText{x} ' Peak SD = ' num2str(peakSD(c,x))]);
        
        saveas(gcf, [saveDir  'Cell No. ' num2str(cellNo(c)) ' ' ConeText{x} '.tif']);
        close;
    end
end
    
    
end