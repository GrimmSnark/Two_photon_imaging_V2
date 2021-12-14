function checkDendriteCellOverlap(fiepathCellList, image2Use)
% Compares the dendrite ROIs between two overlaying dendrite runs and
% doubles up the cell ROIs of the bottom layer to give three images
%
% Inputs: fiepathCellList - cell string of filepaths for the two recordings
%                           to use
%
%         image2Use - string of image name to use for stack
%                     DEFAULT = 'Max_Projection'
%
% USAGE: fiepathCellList = [{'D:\Data\2P_Data\Processed\Mouse\gCamp6s\AAVretro_LS_M4\20210715\run07\'}, {'D:\Data\2P_Data\Processed\Mouse\gCamp6s\AAVretro_LS_M4\20210715\run08'}];
%        checkDendriteCellOverlap(fiepathCellList);
%% defaults

if nargin < 2 || isempty(image2Use)
    image2Use = 'Max_Project';
end

intializeMIJ;

% close all FIJI windows
try
    MIJ.closeAllWindows;
catch
    
end

fiepathCellList{3} = fiepathCellList{2};
%% create patch figures and taken snapshot

roiIndicator = [ 2 2 1];
for i = 1:length(fiepathCellList)
    
    % read in images
    imageSearch = dir([fiepathCellList{i} '\**\'  image2Use '*tif']);
    
    try
    images2Stack(:,:,:,i) = createPatchROIOverlayImage([imageSearch.folder '\' imageSearch.name], roiIndicator(i));
    catch 
    end
end

%% recompile as stack
images2Stack = permute(images2Stack, [1 2 4 3]);

MIJ.createColor(images2Stack,1);
end