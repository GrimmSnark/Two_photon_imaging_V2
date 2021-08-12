function displayStackOverlaysFIJI(folders,image2Use, ROI2Use, labelCol)
% Display summary images from different 2P recording runs and overlays
% their line ROIs. Allows user to check for overlap of dendrites etc.
% Requiires that you have run plotLineProfilesPerCnd.m
%
% Inputs: folders - 1xN string cell array of the processed folders to
%                   display
%
%         image2Use - string used to search for summary image to display
%                     from each recording, DEFAULT - 'LCS', so the lcs
%                     colored orientation selectivity map
%
%         ROIText - number to inidicate which ROIs to overlay
%                   1 = Line ROIs (DEFAULT)
%                   2 = dendrite oval ROIs
%                   [] = no ROIs to show
%
%         labelCol - color of ROI number labels
%                   1 = Black (DEFAULT)
%                   2 = White



%% Defaults
if nargin < 2 || isempty(image2Use)
    image2Use =  'LCS';
end

if nargin < 3 || isempty(ROI2Use)
    ROI2Use = 1;
end

if nargin < 4 || isempty(labelCol)
    labelCol = 1;
end

% get the appropriate magnification for ROI image
screenDim = get(0,'ScreenSize');
if screenDim(3) > 2000
    magSize = 300; % magnification for image viewing in %
else
    magSize = 200; % magnification for image viewing in %
end

% get correct ROI text pointer
switch ROI2Use
    
    case 1 % line ROIs
        ROIText = 'LineROIs';
    case 2
        ROIText = 'dendrites\dendriteROIs';
        
    case []
        ROIText = [];
end

%% Get and display data
noImages = size(folders,2);

% initalize MIJI and get ROI manager open
intializeMIJ;
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();

% open images
for i = 1:noImages
    imageName = dir([folders{i} '**\*' image2Use '*']);
    eval(['imp' num2str(i) '= ij.IJ.openImage([imageName.folder ''\'' imageName.name]);']);
    eval(['processor' num2str(i) '= imp' num2str(i) '.getProcessor();']);
end

% create empty stack
pixelPrefStack = ij.ImageStack(imp1.getWidth, imp1.getHeight);

% fill stack with images
for i =1:noImages
    eval(['pixelPrefStack.addSlice(imp' num2str(i) '.getTitle, processor' num2str(i) ');']);
end

% display stack
stackImagePlusObj = ij.ImagePlus('Pixel Orientation Stack.tif', pixelPrefStack);
stackImagePlusObj.show;


if ~isempty(ROIText)
    overlayPointer = ij.gui.Overlay;
    overlayPointer.drawLabels(1);
    %import ROIs
    for x = 1:noImages
        roiFilepath = dir([folders{x} '**\RawLinePic\' ROIText '.zip']);
        RC.runCommand('Open', [roiFilepath.folder '\' roiFilepath.name]); % opens ROI file
        
        ROInumber = RC.getCount();
        for q =1:ROInumber
            pointerROI = RC.getRoi(q-1); % Select current cell
            pointerROI.setPosition(x);
            
            overlayPointer.add(pointerROI, num2str(q));
            
        end
        RC.runCommand('Delete'); % resets ROIs
    end
    
    
    % displays overlay
    stackImagePlusObj.setOverlay(overlayPointer)
    
    % sets labels to correct numbers
    if labelCol == 1
        MIJ.run("Labels...", "color=black font=15 show use bold");
    else
        MIJ.run("Labels...", "color=white font=15 show use bold");
    end
end

% set window size and make the image easier to view
WaitSecs(0.2);
ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=10 y=50']);

%% Handle script exit

% Sets up diolg box to allow for user input to choose cell ROIs
opts.Default = 'Continue';
opts.Interpreter = 'tex';

questText = [{'Check ROI overlap'} ...
    {'Pan around imageb to check ROI overlap across different depths'} {''} ...
    {'If you are happy to close out analysis press  \bfContinue\rm'} ...
    {'Or click  \bfExit Script\rm or X out of this window to exit script without closing windows'}];

response = questdlg(questText, ...
    'Check and choose ROIs', ...
    'Continue', ...
    'Exit Script', ...
    opts);


% deals with repsonse
switch response
    case 'Continue' % if continue, goes on with analysis
        MIJ.closeAllWindows;
        return
    case 'Exit Script' % if you want to exit and end
        return
    case ''
        return
end

end