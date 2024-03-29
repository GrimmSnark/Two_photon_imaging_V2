function killFlag = chooseROIs(folder2Process, useNetSegementation, trainedNetLocation, checkChannelOverlap, saveFlag)
% Batch file for choosing all ROIs in multiple image stacks, is more user
% input efficient that old method. Also allows user to classify ROIs as
% coexpressing in both channels of 2 channel recording (ie for PV vs non PV
% identification)
%
% Inputs- recordingDir: fullfile to folder containing TSeries Images
%
%
%         useNetSegementation: 0/1 flag to use neural net segementation to
%                              prime cell ROIs
%
%         traineNetLocation: OPTIONAL, indicates the location of the neural
%                            net to use for cell ROI selection, if empty
%                            uses default location
%
%         checkChannelOverlap: Indicates whether you want to
%                              categorize cell ROIs into color channel
%                              overlapping or not, ie whether it show
%                              co-expression. Only affects recordings with
%                              two color channels
%                               0 == do not categorize
%                               1 == categorize (DEFAULT)
%
%         saveFlag: Indicated whether you want to save the
%                   checkChannelOverlap output within this function. If you
%                   are running this function as part of the
%                   runCaAnalysisWrapper it will save the results in
%                   CaAnalysis
%                   0 == do not save (DEFAULT)
%                   1 == save here
%
% Output: killFlag: Flag set to one of you want to exit thescript during
%                   diologue

%% set default

killFlag = 0;

% get the appropriate magnification for ROI image
screenDim = get(0,'ScreenSize');
if screenDim(3) > 2000
    magSize = 300; % magnification for image viewing in %
else
    magSize = 200; % magnification for image viewing in %
end

% if you want to use neural net to prime the ROI selection
if useNetSegementation == 1
    % if you have not specifed a location for the net, tries the default
    % location
    
    if nargin <3 || isempty(trainedNetLocation)
        % works out where the neural net is located (in the ROIExtraction subfolder within the extraction folder of the root code directory)
        tempPath = mfilename('fullpath');
        splitPath = split(tempPath,'\');
        
        % find root dir location
        rootDirName = 'Two_photon_imaging_V2';
        indexMatch = find(ismember(splitPath, rootDirName));
        
        % create string for root dir
        rootFolderInd = join(splitPath(1:indexMatch), '\');
        
        % create string to locate net .mat
        netDir = [rootFolderInd{:} '\extraction\ROIExtraction\'];
        
        % serach for and set fullpath for net
        netFiles = dir([netDir '*.mat']);
        trainedNetLocation = [netFiles(end).folder '\' netFiles(end).name]; % sets default trained neural net location
    end
end

if nargin <4 || isempty(checkChannelOverlap)
    checkChannelOverlap = 1;
end

if nargin <5 || isempty(saveFlag)
    saveFlag = 0;
end

%% Create the appropriate images for ROI extraction

% finds all the relevant images for ROI choosing
files = dir([folder2Process 'STD_Average*']);

if size(files,1) ==1 % if single channel recording
    imageROI = read_Tiffs([folder2Process files.name],1); % reads in average image
    imageROI = uint16(mat2gray(imageROI)*65535);
    imageROI = imadjust(imageROI); % saturate image to make neural net prediction better
end

% initalize MIJI and get ROI manager open
intializeMIJ;
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();


%  if multiple channels, build the average image for ROI extraction
if size(files,1) >1 % if multiple channel recording
    
    % This section uses mostly ImageJ/FIJI code, ie java
    
    % open both images in FIJI
    impChan1 = ij.IJ.openImage([folder2Process 'STD_Average_Ch1.tif']);
    impChan2 = ij.IJ.openImage([folder2Process 'STD_Average_Ch2.tif']);
    
    % get processor for each images
    chan1Process = impChan1.getProcessor();
    chan2Process = impChan2.getProcessor();
    
    % do background subbtraction to clean up the image a bit
    ij.plugin.filter.BackgroundSubtracter().rollingBallBackground(chan1Process, 50, 0, 0 ,0,0,0);
    ij.plugin.filter.BackgroundSubtracter().rollingBallBackground(chan2Process, 50, 0, 0 ,0,0,0);
    
    % make a stack of the images
    chanStack = ij.ImageStack(chan1Process.getWidth, chan1Process.getHeight);
    chanStack.addSlice(impChan1.getTitle, chan1Process);
    chanStack.addSlice(impChan2.getTitle, chan2Process);
    
    chanStackImagePlus = ij.ImagePlus('Channel Stack', chanStack);
    
    % do a max projection across the images, get the brightest cells
    % regardless of the channel
    maxIntensityImp = ij.plugin.ZProjector.run(chanStackImagePlus, 'max');
    maxIntensityImp.show;
    
    % get the image matrix and rescale to use the full 16bit
    imageROI = MIJ.getImage('MAX_Channel Stack');
    imageROI = uint16(mat2gray(imageROI)*65535);
    
    % save image
    if ~exist([folder2Process 'Max_Project.tif'])
        saveastiff(imageROI, [folder2Process 'Max_Project.tif']);
    end
    
    maxIntensityImp.close;
    imageROI = imadjust(imageROI); % saturate image to make neural net prediction better
end


% get image to FIJI
MIJImageROI = MIJ.createImage('ROI_image',imageROI,true); %#ok<NASGU> supressed warning as no need to worry about
ij.process.ImageConverter(MIJImageROI).convertToRGB;


%load in STD images indivdually
stdImages = dir([folder2Process 'STD_Average_*']);

% get all the FIJI stuff for each image
for i =1:length(stdImages)
    eval(['imp' num2str(i) '= ij.IJ.openImage([folder2Process stdImages(' num2str(i) ').name]);']);
    eval(['processorSTD' num2str(i) '= imp' num2str(i) '.getProcessor();']);
end

% create empty stack
pixelSTDStack = ij.ImageStack(imp1.getWidth, imp1.getHeight);

% fill stack with images
for i =1:length(stdImages)
    eval(['pixelSTDStack.addSlice(imp' num2str(i) '.getTitle, processorSTD' num2str(i) ');']);
end

% display stack
stackImagePlusObjSTD = ij.ImagePlus('STD Stack.tif', pixelSTDStack);
stackImagePlusObjSTD.show;
ij.process.ImageConverter(stackImagePlusObjSTD).convertToRGB;





% load in pixel preference images if they exist
pixelSelectivityImages = dir([folder2Process 'Pixel Orientation Pref_native*']);

% get all the FIJI stuff for each image
for i =1:length(pixelSelectivityImages)
    eval(['imp' num2str(i) '= ij.IJ.openImage([folder2Process pixelSelectivityImages(' num2str(i) ').name]);']);
    eval(['processor' num2str(i) '= imp' num2str(i) '.getProcessor();']);
end

% create empty stack
pixelPrefStack = ij.ImageStack(imp1.getWidth, imp1.getHeight);

% fill stack with images
for i =1:length(pixelSelectivityImages)
    eval(['pixelPrefStack.addSlice(imp' num2str(i) '.getTitle, processor' num2str(i) ');']);
end

% display stack
stackImagePlusObj = ij.ImagePlus('Pixel Orientation Stack.tif', pixelPrefStack);
stackImagePlusObj.show;
ij.process.ImageConverter(stackImagePlusObj).convertToRGB;

% load in pixel selectivity images if they exist
pixelSelectivityImages = dir([folder2Process 'Pixel Orientation Selectivity_native*LCS.tif']);

% get all the FIJI stuff for each image
for i =1:length(pixelSelectivityImages)
    eval(['imp' num2str(i) '= ij.IJ.openImage([folder2Process pixelSelectivityImages(' num2str(i) ').name]);']);
    eval(['processorSelect' num2str(i) '= imp' num2str(i) '.getProcessor();']);
end

% create empty stack
pixelSelectivityStack = ij.ImageStack(imp1.getWidth, imp1.getHeight);

% fill stack with images
for i =1:length(pixelSelectivityImages)
    eval(['pixelSelectivityStack.addSlice(imp' num2str(i) '.getTitle, processorSelect' num2str(i) ');']);
end

% display stack
stackImagePlusObjSelect = ij.ImagePlus('Pixel Pref Stack.tif', pixelSelectivityStack);
stackImagePlusObjSelect.show;
ij.process.ImageConverter(stackImagePlusObjSelect).convertToRGB;


MIJ.run("Concatenate...", "  title=[Full Stack] open image1=ROI_image  image2=[STD Stack.tif] image3=[Pixel Orientation Stack.tif] image4=[Pixel Pref Stack.tif]");
MIJImageROI.close;
% set window size and make the image easier to view
WaitSecs(0.2);
ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=10 y=50']);
ij.IJ.run('Enhance Contrast', 'saturated=0.35');

% open ROI tool
MIJ.run("Cell Magic Wand Tool");
ij.IJ.runMacro('setTool("rectangle");');


%% Deal with ROI selection

% Check if there are already ROIs selected for this recording

if exist([folder2Process 'ROIcells.zip'], 'file')
    disp([folder2Process  ' contains a valid ROI file!']);
    RC.runCommand('Open', [folder2Process 'ROIcells.zip']); % opens ROI file
    
    % Query user if you want to use previously chosen ROIs
    answer = MFquestdlg([0.5,0.5], 'Would you like to use previously chosen ROIs?', ...
        'Choose your ROIs', ...
        'Yes','No', 'Yes');
    % Handle response
    switch answer
        case 'Yes'
            useNetSegementation = 0;
        case 'No'
            useNetSegementation = 1;
            RC.runCommand('Delete'); % resets ROIs if you select clear all
        case ''
            useNetSegementation = 0;
    end
end



% If you want to use neural net segmentation to prime ROI extraction
if useNetSegementation
    net = load(trainedNetLocation, 'net');
    net = net.net;
    
    % segment image
    patch_seg = semanticseg(imageROI, net, 'outputtype', 'uint8');
    
    % filter to get rid of graininess
    segmentedImage = medfilt2(patch_seg,[3,3]);
    segmentedImage(segmentedImage==1) = 0;
    segmentedImage(segmentedImage==2) = 255;
    
    % create image in FIJI
    MIJSegNetImage = MIJ.createImage('Net_seg_image',segmentedImage,true); %#ok<NASGU> supressed warning as no need to worry about
    
    % process in FIJI
    SegNetProcessor = MIJSegNetImage.getProcessor;
    SegNetProcessor.invertLut;
    
    % watershed to try and break up some ROIS
    ij.plugin.filter.EDM().toWatershed(SegNetProcessor);
    MIJSegNetImage.updateAndDraw();
    
    MIJ.run( 'Analyze Particles...', 'size=20-Infinity clear add');
    
    MIJSegNetImage.close;
end

RC.runCommand('Show All');

% Sets up diolg box to allow for user input to choose cell ROIs
opts.Default = 'Continue';
opts.Interpreter = 'tex';

questText = [{'Check ROIs and remove any covering multiple cells'} ...
    {'Select the Cell Magic Want and press "t" to add to ROI manager'} {''} ...
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
        ROInumber = RC.getCount();
        disp(['You have selected ' num2str(ROInumber) ' ROIs, moving on...']);
        RC.runCommand('Save', [folder2Process 'ROIcells.zip']); % saves zip file
        
    case 'Exit Script' % if you want to exit and end
        killFlag = 1;
        MIJ.closeAllWindows;
        return
    case ''
        killFlag = 1; % if you want to exit and end
        MIJ.closeAllWindows;
        return
end

% Clean up windows
MIJ.run('Close');

%% do channel overlap analysis

if checkChannelOverlap == 1 && size(files,1) >1
    % finds the overlap image
    overlapFilename = dir([folder2Process 'Overlap*']);
    
    % figure out which average image is the other channel
    averageImages = dir([folder2Process 'Average*']);
    
    for x = 1:length(averageImages)
        channelNo(x) = averageImages(x).name(end-4);
    end
    
    match = strfind(channelNo, overlapFilename.name(end-4));
    channelNo(match)= [];
    channelNo = str2double(channelNo);
    
    % open the images and create the color version
    overlapIm = read_Tiffs([folder2Process overlapFilename.name]);
    channelAverageIm = read_Tiffs([folder2Process averageImages(channelNo).name]);
    
    overlapRGB = cat(3,mat2gray(overlapIm),mat2gray(channelAverageIm), zeros(size(channelAverageIm)));
    
    % display image in figure and prime overlap user data
    imageHandle = imshow(overlapRGB, 'Border','tight', 'InitialMagnification',magSize);
    figHandle = gcf;
    
    % get cell overlap identities from ROI manager, in case this has been
    % run before and prime the overlap cell array
    for x = 1:ROInumber
        % Select cell ROI in ImageJ/FIJI
        
        currentROI = RC.getRoi(x-1);
        
        % get the channel overlap identity
        try
            ROIColor = [currentROI.getStrokeColor.getRed, currentROI.getStrokeColor.getGreen, currentROI.getStrokeColor.getBlue];
        catch
            ROIColor = [0 255 255];
        end
        
        if ROIColor == [255 0 0]
            ChannelOverlap(x,1) = 1;
        else
            ChannelOverlap(x,1) = 0;
        end
        
    end
    
    colorsROI = [0 1 1; 1 0 0];
    figHandle.UserData = ChannelOverlap;
    
    % transfer ROIs to matlab
    cellROIs = RC.getRoisAsArray;
    imageROI = createLabeledROIFromImageJPixels([size(channelAverageIm)], cellROIs);
    
    boundaries = cell(ROInumber,1);
    %iterate through ROI number to get them in appropriate order and
    %borders
    for i = 1: ROInumber
        tempImageROI = imageROI;
        tempImageROI(tempImageROI~=i) = 0;
        tempBounds = bwboundaries(tempImageROI, 4, 'noholes');
        boundaries(i,1) =tempBounds(1);
    end
    
    % set ROIs on image with click button callback to toggle overlap
    % identity
    for i =1:ROInumber
        f = 1:length(boundaries{i,1});
        v = [boundaries{i,1}(:,2) boundaries{i,1}(:,1)];
        
        patch(imageHandle.Parent, 'Faces' ,f, 'Vertices', v, 'FaceColor', [0,0,0], 'FaceAlpha', 0.01,  'EdgeColor',colorsROI(ChannelOverlap(i)+1,:), 'LineWidth',0.5, 'Tag',num2str(i), ...
            'ButtonDownFcn', @(src,evnt)chooseROIsCallbck(src,evnt));
    end
    
    
    % Sets up diolg box to allow for user input to choose cell ROIs
    opts.Default = 'Continue';
    opts.Interpreter = 'tex';
    
    questText2 = [{'Check ROIs for Color Channel Overlap'} ...
        {'Click on cell ROIs to select those that overlap in the color channel'} {''} ...
        {'Cyan = no overlap, Red = overlap'} ...
        {'If you are happy to move on with analysis click  \bfContinue\rm'} ...
        {'Or click  \bfExit Script\rm or X out of this window to exit script'}];
    
    response = MFquestdlg([ 0.5 , 0.9 ], questText2, ...
        'Check and choose ROIs', ...
        'Continue', ...
        'Exit Script', ...
        opts);
    
    
    % deals with repsonse
    switch response
        
        case 'Continue' % if continue, goes on with analysis
            channelOverlapFlag = get(gcf, 'userdata');
            close;
        case 'Exit Script' % if you want to exit and end
            killFlag = 1;
            close;
            return
        case ''
            killFlag = 1; % if you want to exit and end
            close;
            return
    end
    
    % change ROI colors in FIJI and save the cell idenitiies if requested,
    % otherwise they will be saved in the CaAnalysis function
    
    numOfDualChanCells = sum(channelOverlapFlag);
    disp(['You have selected ' num2str(numOfDualChanCells) '/' num2str(ROInumber) ' (' sprintf('%.2f',(numOfDualChanCells/ROInumber)*100) '%) ROIs, as dual channel moving on...']);
    
    % change FIJI ROI color to red if selected as channel overlap cell
    for x = 1:ROInumber
        
        if channelOverlapFlag(x) == 1
            % Select cell ROI in ImageJ/FIJI
            currentROI = RC.getRoi(x-1);
            currentROI.setStrokeColor(java.awt.Color(1, 0, 0));
        end
        
    end
    RC.runCommand('Save', [folder2Process 'ROIcells.zip']); % saves zip file
    
    
    % save the channel overlap stuff if required
    if saveFlag == 1
        % load experimentStructure
        load([folder2Process '\experimentStructure.mat']);
        experimentStructure.ChannelOverlap = channelOverlapFlag;
        save([experimentStructure.savePath '\experimentStructure.mat'], 'experimentStructure', '-v7.3');
        
    end
end

MIJ.closeAllWindows;

end
