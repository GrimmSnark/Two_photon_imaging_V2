function experimentStructure = createCellFOVLimit(filepath)
% Allows you to make a 0/1 flag for l cells to include/exclude from
% subfield in the recording
%
% Inputs: filepath - filepath of recording to check

%%

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



intializeMIJ;

try
    MIJ.run('Close');
    MIJ.closeAllWindows;
catch
end

% sets up ROI manager for this function
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();


% Sets up diolg box to allow for user input to choose cell ROIs
opts.Default = 'Continue';
opts.Interpreter = 'tex';

questText = [{'Select new subfield by using ROI'} ...
    {'Select the subfield and press "t" to add to ROI manager'} {''} ...
    {'If you are happy to move on with analysis click  \bfContinue\rm'} ...
    {'Or click  \bfExit Script\rm or X out of this window to exit script'}];

response = questdlg(questText, ...
    'Check and choose ROIs', ...
    'Continue', ...
    'Exit Script', ...
    opts);


% deals with repsonse
switch response
    
    case 'Continue' % if continue, goes on with analysis
        COPatchROINum = RC.getCount();
        disp(['You have selected ' num2str(COPatchROINum) ' Patch, moving on...']);
        
        % save subfield patch FIJI ROIs
        RC.runCommand('Save', [experimentStructure.savePath '\SubfieldROI.zip']); % saves zip file

        
    case 'Exit Script' % if you want to exit and end
        return
    case ''
        return
end

%Open cell ROIs for this recordings
RC.runCommand('Open', [experimentStructure.savePath '\ROIcells.zip']); % opens zip file


% split ROI handles
ROIobjects = RC.getRoisAsArray;
COROIs = ROIobjects(1:COPatchROINum);
cellROIs = ROIobjects(COPatchROINum+1:end);


% Check whether a cell ROI is contained within a subfield patch
for q =1:COPatchROINum %for each  subfield patch
    [labeledCO, XYLocsCO ] = createFilledMatlabROIFromFIJIROI(COROIs(q),experimentStructure);
    
    for x = 1:experimentStructure.cellCount % for each Cell
        [labeledCell, XYLocsCell ] = createFilledMatlabROIFromFIJIROI(cellROIs(x), experimentStructure);
        
        polyCO = polyshape(XYLocsCO);
        polyCell = polyshape(XYLocsCell);
        
        intersectPoly = intersect(polyCO, polyCell);
        
        if ~isempty(intersectPoly.Vertices)
            if size(intersectPoly.Vertices) == size(polyCell.Vertices)
                subfieldFlag(q,x) = 1; % if completely contained within CO ROI
            else
                subfieldFlag(q,x) = 2; % if straddles the CO ROI
            end
        else
            subfieldFlag(q,x) = 0; % if completely outside CO ROI
        end  
    end
end

if ~isprop(experimentStructure, 'subfieldPatchFlag')
    experimentStructure.addprop('subfieldPatchFlag');
end
experimentStructure.subfieldPatchFlag = sum(subfieldFlag,1)'; % reduces array to vector

 save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure', '-v7.3');

end



