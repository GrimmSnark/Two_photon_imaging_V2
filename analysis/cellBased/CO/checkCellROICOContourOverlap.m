function checkCellROICOContourOverlap(recordingDir, COImageFilepath)
% checks cell ROI overlay with CO contour png created by LS and creates
% flag for each cell to identify if it is a CO cell or not. Saves COIdent
% field to experimentStructure
%
% Inputs: recordingDir - filepath of recording to check
%         COImageFilepath - filepath to RGB image of CO patch borders which
%                           are overlaid on 2P recording image size (512 x
%                           512 pix)
%
% USAGE: checkCellROICOContourOverlap('D:\Data\2P_Data\Processed\Monkey\M10_Sully_BF797C\run_11_OIST\TSeries-04042019-0932-012\20200423154339\','D:\Data\2P_Data\Processed\Monkey\M10_Sully_BF797C\CO-contours.png')

intializeMIJ;

try
    MIJ.run('Close');
    MIJ.closeAllWindows;
catch
end

% sets up ROI manager for this function
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();

% load experimentStructure
load([recordingDir 'experimentStructure.mat']);


COImage = imread(COImageFilepath);
% transfers to FIJI
COImageMIJI = MIJ.createImage( 'CO_image_contours', COImage,true);

% get image in correct format, and get the CO ROIs
ij.process.ImageConverter(COImageMIJI).convertRGBStackToRGB
ij.IJ.run('16-bit');
ij.IJ.setThreshold(COImageMIJI, 1, 65535);
ij.plugin.filter.Analyzer(COImageMIJI).setOption("BlackBackground", 0);
MIJ.run('Convert to Mask');
MIJ.run('Analyze Particles...', 'add');
COPatchROINum =  RC.getCount();

% save CO Patch FIJI ROIs
COPatchSaveDir = dir(COImageFilepath);
RC.runCommand('Save', [COPatchSaveDir.folder '\ROICOPatches.zip']); % saves zip file

%Open cell ROIs for this recordings
RC.runCommand('Open', [recordingDir 'ROIcells.zip']); % opens zip file


% split ROI handles
ROIobjects = RC.getRoisAsArray;
COROIs = ROIobjects(1:COPatchROINum);
cellROIs = ROIobjects(COPatchROINum+1:end);


% Check whether a cell ROI is contained within any CO ROI
for q =1:COPatchROINum %for each CO ROI
    [labeledCO, XYLocsCO ] = createFilledMatlabROIFromFIJIROI(COROIs(q),experimentStructure);
    
    for x = 1:experimentStructure.cellCount % for each Cell
        [labeledCell, XYLocsCell ] = createFilledMatlabROIFromFIJIROI(cellROIs(x), experimentStructure);
        
        polyCO = polyshape(XYLocsCO);
        polyCell = polyshape(XYLocsCell);
        
        intersectPoly = intersect(polyCO, polyCell);
        
        if ~isempty(intersectPoly.Vertices)
            if size(intersectPoly.Vertices) == size(polyCell.Vertices)
                COFlag(q,x) = 1; % if completely contained within CO ROI
            else
                COFlag(q,x) = 2; % if straddles the CO ROI
            end
        else
            COFlag(q,x) = 0; % if completely outside CO ROI
        end  
    end
end

experimentStructure.COIdent = sum(COFlag,1)'; % reduces array to vector

save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure', '-v7.3');

end



