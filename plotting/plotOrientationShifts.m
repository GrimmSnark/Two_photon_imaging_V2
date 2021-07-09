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

sigLevel = 0.05;

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
if ~isempty(thresholdZ)
%     oriPeaks = oriPeaks(experimentStructure.ZScore>thresholdZ,:);
%     zScoreThresholded = experimentStructure.ZScore(experimentStructure.ZScore>thresholdZ);
%     guasCurves = guasCurves(experimentStructure.ZScore>thresholdZ,:,:);

    zscoreSubfield = experimentStructure.ZScore(experimentStructure.subfieldPatchFlag ==1);
    subFieldZscore = zscoreSubfield > thresholdZ;

    oriPeaks = oriPeaks(experimentStructure.subfieldPatchFlag ==1,:);
    oriPeaks = oriPeaks(subFieldZscore,:);
    
    zScoreThresholded = zscoreSubfield(subFieldZscore);
    
    guasCurves = guasCurves(experimentStructure.subfieldPatchFlag ==1,:,:);
    guasCurves = guasCurves(subFieldZscore,:,:);
  
else
    zScoreThresholded = experimentStructure.ZScore;
end


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
%
% L v M
guasCurves = guasCurves(:,1:10:180,:);
for cellNo = 1:size(guasCurves,1)
    for cnd = 1: size(guasCurves,2)
        
        normVal = max([guasCurves(cellNo,:,1) guasCurves(cellNo,:,2)]);
        
        try
%         [hLvM(cellNo),pLvM(cellNo)] = kstest2(guasCurves(cellNo,:,1), guasCurves(cellNo,:,2));
%           [hLvM(cellNo),pLvM(cellNo)] = kstest2(guasCurves(cellNo,:,1)/normVal, guasCurves(cellNo,:,2)/normVal);
          [hLvM(cellNo),pLvM(cellNo)] = kstest2(guasCurves(cellNo,:,1)/max(guasCurves(cellNo,:,1)), guasCurves(cellNo,:,2)/max(guasCurves(cellNo,:,2)));
        
        
        %         curveData = [guasCurves(cellNo,:,1)  guasCurves(cellNo,:,2)]';
        %         sampleData = [ ones(size(guasCurves,2),1); ones(size(guasCurves, 2),1)*2];
        %         [pLvM(cellNo)] = AnDarksamtest([curveData sampleData]);
        catch
             hLvM(cellNo) = 0;
             pLvM(cellNo) = 1;
        end
    end
end

LvMCols = zeros(length(pLvM), 3);
lengthAccept = sum(pLvM < sigLevel);
LvMCols(pLvM < sigLevel,:) = repmat([1 0 0],lengthAccept,1);


% L v S
for cellNo = 1:size(guasCurves,1)
    for cnd = 1: size(guasCurves,2)
        
         normVal = max([guasCurves(cellNo,:,1) guasCurves(cellNo,:,4)]);
        try
%         [~,pLvS(cellNo)] = kstest2(guasCurves(cellNo,:,1), guasCurves(cellNo,:,4));
%         [~,pLvS(cellNo)] = kstest2(guasCurves(cellNo,:,1)/normVal, guasCurves(cellNo,:,4)/normVal);
[~,pLvS(cellNo)] = kstest2(guasCurves(cellNo,:,1)/max(guasCurves(cellNo,:,1)), guasCurves(cellNo,:,4)/max(guasCurves(cellNo,:,4)));
        

        %         curveData = [guasCurves(cellNo,:,1), guasCurves(cellNo,:,4)]';
        %         sampleData = [ ones(size(guasCurves,2),1); ones(size(guasCurves, 2),1)*2];
        %         [pLvS(cellNo)] = AnDarksamtest([curveData
        %         sampleData]);
        catch
            hLvM(cellNo) = 0;
            pLvM(cellNo) = 1;
        end
    end
end

LvSCols = zeros(length(pLvS), 3);
lengthAccept = sum(pLvS < sigLevel);
LvSCols(pLvS < sigLevel,:) = repmat([1 0 0],lengthAccept,1);


% M v S
for cellNo = 1:size(guasCurves,1)
    for cnd = 1: size(guasCurves,2)
        
        normVal = max([guasCurves(cellNo,:,2) guasCurves(cellNo,:,4)]);
        try
%         [~,pMvS(cellNo)] = kstest2(guasCurves(cellNo,:,2), guasCurves(cellNo,:,4));
%         [~,pMvS(cellNo)] = kstest2(guasCurves(cellNo,:,2)/normVal, guasCurves(cellNo,:,4)/normVal);
[~,pMvS(cellNo)] = kstest2(guasCurves(cellNo,:,2)/max(guasCurves(cellNo,:,2)), guasCurves(cellNo,:,4)/max(guasCurves(cellNo,:,4)));
        
        

        %         curveData = [guasCurves(cellNo,:,2)  guasCurves(cellNo,:,4)]';
        %         sampleData = [ ones(size(guasCurves,2),1); ones(size(guasCurves, 2),1)*2];
        %         [pMvS(cellNo)] = AnDarksamtest([curveData sampleData]);
        catch
             hLvM(cellNo) = 0;
            pLvM(cellNo) = 1;
        end

    end
end

MvSCols = zeros(length(pMvS), 3);
lengthAccept = sum(pMvS < sigLevel);
MvSCols(pMvS < sigLevel,:) = repmat([1 0 0],lengthAccept,1);



%% get angle shifts > 15  && > 30 for CO Patch and Interpatch

COSubField = experimentStructure.COIdent(experimentStructure.subfieldPatchFlag == 1);
COSubField = COSubField(subFieldZscore);

% LM
LMPatch = LvMRect(COSubField == 1);
LMInterPatch = LvMRect(COSubField == 0);

% LS
LSPatch = LvSRect(COSubField == 1);
LSInterPatch = LvSRect(COSubField == 0);

% MS
MSPatch = MvSRect(COSubField == 1);
MSInterPatch = MvSRect(COSubField == 0);


figHandle = figure('units','normalized','outerposition',[0 0 0.5 1]);

ax(1) = subplot(321);
histogram(ax(1), LMPatch, 100);
title('L Cone vs M Cone Patch');

ax(2) = subplot(322);
histogram(ax(2), LMInterPatch, 100);
title('L Cone vs M Cone Inter Patch');

ax(3) = subplot(323);
histogram(ax(3), LSPatch, 100);
title('L Cone vs S Cone Patch');

ax(4) = subplot(324);
histogram(ax(4), LSInterPatch, 100);
title('L Cone vs S Cone Inter Patch');

ax(5) = subplot(325);
histogram(ax(5), MSPatch, 100);
title('M Cone vs S Cone Patch');
xlabel('Angular Shift');


ax(6) = subplot(326);
histogram(ax(6), MSInterPatch, 100);
title('M Cone vs S Cone Inter Patch');

xlabel('Angular Shift');

subplotEvenAxes(gcf);
tightfig

saveas(gcf, [experimentStructure.savePath  'Hist Angular Shift CO Subfield.tif']);

%% scatter

figHandle = figure('units','normalized','outerposition',[0 0 0.5 1]);

% test Fits
% [pDM,usefulCmbs] = compareOrientationFitsRMSE(experimentStructure, 6, 180, 4);
% 
% if ~isempty(thresholdZ)
%     pDM = pDM(experimentStructure.ZScore>thresholdZ,:);
% end
% 
cellLabels = strsplit(num2str(1:length(zScoreThresholded)));

% LvMCols = zeros(length(pDM),3);


subplot(311);

% LvM_pVal = pDM(:,1);
% lengthAccept = sum(LvM_pVal < sigLevel);
% LvMCols(LvM_pVal < sigLevel,:) = repmat([1 0 0],lengthAccept,1);

figHandle = scatter(LvMRect,zScoreThresholded, '.','SizeData', 50, 'CData', LvMCols);
row = dataTipTextRow('CellNo:',cellLabels);
figHandle.DataTipTemplate.DataTipRows(end+1) = row;

hline(6,'k');
title('L Cone vs M Cone');

subplot(312);

% LvS_pVal = pDM(:,3);
% lengthAccept = sum(LvS_pVal < sigLevel);
% LvSCols(LvS_pVal < sigLevel,:) = repmat([1 0 0],lengthAccept,1);

figHandle = scatter(LvSRect,zScoreThresholded, '.','SizeData', 50, 'CData', LvSCols);
row = dataTipTextRow('CellNo:',cellLabels);
figHandle.DataTipTemplate.DataTipRows(end+1) = row;
title('L Cone vs S Cone');
hline(6,'k');
subplot(313);

% MvS_pVal = pDM(:,5);
% lengthAccept = sum(MvS_pVal < sigLevel);
% MvSCols(MvS_pVal < sigLevel,:) = repmat([1 0 0],lengthAccept,1);

figHandle = scatter(MvSRect,zScoreThresholded, '.','SizeData', 50, 'CData', MvSCols);
row = dataTipTextRow('CellNo:',cellLabels);
figHandle.DataTipTemplate.DataTipRows(end+1) = row;
hline(6,'k');
title('M Cone vs S Cone');

xlabel('Angular Shift');

subplotEvenAxes(gcf);
tightfig

saveas(gcf, [experimentStructure.savePath  'Scatter Angular Shift.fig']);
saveas(gcf, [experimentStructure.savePath  'Scatter Angular ShiftV5.tif']);

end