function checkDendriteCellOverlap(fiepathCellList, image2Use)

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
%% set up figure with callback functions


end