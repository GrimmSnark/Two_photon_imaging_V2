function plotOrientationShifts(filepath, thresholdZ)

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

if nargin <2
    thresholdZ =[];
end

sigLevel = 0.01;

%% get orientation peaks from LS guas fits

for cellNo = 1:experimentStructure.cellCount
    for cnd = 1: size(experimentStructure.OSIStruct,2)
        try
            oriPeaks(cellNo,cnd) = experimentStructure.OSIStruct{cellNo,cnd}.LSStruct.Peak1Loc;
            guasCurves(cellNo, :, cnd) = experimentStructure.OSIStruct{cellNo,cnd}.LSStruct.modelTrace;
        catch
            oriPeaks(cellNo,cnd) = NaN;
            guasCurves(cellNo, :, cnd) = NaN;
        end
    end
end

% limit to those with zscore
oriPeaks = oriPeaks(experimentStructure.ZScore>thresholdZ,:);
zScoreThresholded = experimentStructure.ZScore(experimentStructure.ZScore>thresholdZ);
guasCurves = guasCurves(experimentStructure.ZScore>thresholdZ,:,:);


oriPeaksRad = circ_ang2rad(oriPeaks);

LvM = circ_rad2ang(angdiff(oriPeaksRad(:,1), oriPeaksRad(:,2)));
LvS = circ_rad2ang(angdiff(oriPeaksRad(:,1), oriPeaksRad(:,4)));
MvS = circ_rad2ang(angdiff(oriPeaksRad(:,2), oriPeaksRad(:,4)));

LvMRect = abs(LvM);
LvSRect = abs(LvS);
MvSRect = abs(MvS);

%% plot histograms
%
% subplot(311);
% histogram(LvMRect, 100);
% title('L Cone vs M Cone');
%
% subplot(312);
% histogram(LvSRect, 100);
% title('L Cone vs S Cone');
%
% subplot(313);
% histogram(MvSRect, 100);
% title('M Cone vs S Cone');
%
% xlabel('Angular Shift');
%
% subplotEvenAxes(gcf);
%
% saveas(gcf, [experimentStructure.savePath  'Histogram Angular Shift.tif']);
%
%
% %% 3d hists
%
% cellLabels = strsplit(num2str(1:length(zScoreThresholded)));
%
% subplot(311);
% hist3([LvMRect  zScoreThresholded], 'Nbins', [100 100]);
% figHandle = gcf;
% title('L Cone vs M Cone');
%
% subplot(312);
% hist3([LvSRect  zScoreThresholded], 'Nbins', [100 100]);
% title('L Cone vs S Cone');
%
% subplot(313);
% hist3([MvSRect  zScoreThresholded], 'Nbins', [100 100]);
% title('M Cone vs S Cone');
%
% xlabel('Angular Shift');
%
% subplotEvenAxes(gcf);
%
% saveas(gcf, [experimentStructure.savePath  'Histogram Angular Shift 3D.fig']);

%% ks testing

% L v M

for cellNo = 1:size(guasCurves,1)
    for cnd = 1: size(guasCurves,2)
        [hLvM(cellNo),pLvM(cellNo)] = kstest2(guasCurves(cellNo,:,1), guasCurves(cellNo,:,2));
        %         curveData = [guasCurves(cellNo,:,1)  guasCurves(cellNo,:,2)]';
        %         sampleData = [ ones(size(guasCurves,2),1); ones(size(guasCurves, 2),1)*2];
        %         [pLvM(cellNo)] = AnDarksamtest([curveData sampleData]);
    end
end

LvMCols = zeros(length(pLvM), 3);
lengthAccept = sum(pLvM < sigLevel);
LvMCols(pLvM < sigLevel,:) = repmat([1 0 0],lengthAccept,1);


% L v S
for cellNo = 1:size(guasCurves,1)
    for cnd = 1: size(guasCurves,2)
        [~,pLvS(cellNo)] = kstest2(guasCurves(cellNo,:,1), guasCurves(cellNo,:,4));
        
        %         curveData = [guasCurves(cellNo,:,1), guasCurves(cellNo,:,4)]';
        %         sampleData = [ ones(size(guasCurves,2),1); ones(size(guasCurves, 2),1)*2];
        %         [pLvS(cellNo)] = AnDarksamtest([curveData sampleData]);
    end
end

LvSCols = zeros(length(pLvS), 3);
lengthAccept = sum(pLvS < sigLevel);
LvSCols(pLvS < sigLevel,:) = repmat([1 0 0],lengthAccept,1);


% M v S
for cellNo = 1:size(guasCurves,1)
    for cnd = 1: size(guasCurves,2)
        [~,pMvS(cellNo)] = kstest2(guasCurves(cellNo,:,2), guasCurves(cellNo,:,4));
        
        %         curveData = [guasCurves(cellNo,:,2)  guasCurves(cellNo,:,4)]';
        %         sampleData = [ ones(size(guasCurves,2),1); ones(size(guasCurves, 2),1)*2];
        %         [pMvS(cellNo)] = AnDarksamtest([curveData sampleData]);
    end
end

MvSCols = zeros(length(pMvS), 3);
lengthAccept = sum(pMvS < sigLevel);
MvSCols(pMvS < sigLevel,:) = repmat([1 0 0],lengthAccept,1);



%% scatter

cellLabels = strsplit(num2str(1:length(zScoreThresholded)));

subplot(311);
figHandle = scatter(LvMRect,zScoreThresholded, '.','SizeData', 50, 'CData', LvMCols);
row = dataTipTextRow('CellNo:',cellLabels);
figHandle.DataTipTemplate.DataTipRows(end+1) = row;
title('L Cone vs M Cone');

subplot(312);
figHandle = scatter(LvSRect,zScoreThresholded, '.','SizeData', 50, 'CData', LvSCols);
row = dataTipTextRow('CellNo:',cellLabels);
figHandle.DataTipTemplate.DataTipRows(end+1) = row;
title('L Cone vs S Cone');

subplot(313);
figHandle = scatter(MvSRect,zScoreThresholded, '.','SizeData', 50, 'CData', MvSCols);
row = dataTipTextRow('CellNo:',cellLabels);
figHandle.DataTipTemplate.DataTipRows(end+1) = row;
title('M Cone vs S Cone');

xlabel('Angular Shift');

subplotEvenAxes(gcf);

saveas(gcf, [experimentStructure.savePath  'Scatter Angular Shift.fig']);
end