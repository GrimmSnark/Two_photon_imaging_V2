function plotFitsPerTrialCell(experimentStructure, fitGrandStruct, cellNo,  noOrientations, angleMax, secondCndDimension)

%% set defaults

saveDir = 'D:\Data\2P_Data\Processed\Monkey\M10_Sully_BF797C\run_11_OIST - Copy\TSeries-04042019-0932-012\20200423154339\trialOrientationFits\nonSigPatch\';

if nargin < 4 || isempty(noOrientations)
    noOrientations = 6;
end

if nargin < 5 || isempty(angleMax)
    angleMax = 180;
end

if nargin < 6 || isempty(secondCndDimension)
    secondCndDimension = 4;
end

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
            
            originalData=interp1(data2Use,linspace(1,length(angles),18));
            
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