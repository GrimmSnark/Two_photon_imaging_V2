function displayAllOrientationImages(filepath)
% Opens and displays all orientation summary images as a FIJI/ImageJ stack 
% so that you can view them easier 
%
% Inputs:  filepath - processed data folder containing the
%                     experimentStructure.mat, or the fullfile to the
%                     experimentStructure.mat OR the structure itself

%% default
% gets the experimentStructure
if ~isobject(filepath)
    try
        load(filepath, '-mat');
        filePath2Use = dir(filepath);
        experimentStructure.savePath = [filePath2Use.folder '\'] ;
    catch
        load([filepath '\experimentStructure.mat']);
        experimentStructure.savePath = [filepath '\'];
    end
else % if variable is the experimentStructure
    experimentStructure = filepath;
    clearvars filepath
end

% get the appropriate magnification for ROI image
screenDim = get(0,'ScreenSize');
if screenDim(3) > 2000
    magSize = 300; % magnification for image viewing in %
else
    magSize = 200; % magnification for image viewing in %
end

intializeMIJ;

%% Create the appropriate images

% finds all the relevant images for ROI chosing
files = dir([experimentStructure.savePath 'STD_Average*']);

if size(files,1) ==1 % if single channel recording
    imageROI = read_Tiffs([experimentStructure.savePath 'STD_Average.tif'],1); % reads in average image
    imageROI = uint16(mat2gray(imageROI)*65535);
    %     imageROI = imadjust(imageROI); % saturate image to make neural net prediction better
end

% initalize MIJI and get ROI manager open
intializeMIJ;
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();


%  if multiple channels, build the average image for ROI extraction
if size(files,1) >1 % if multiple channel recording
    
    % This section uses mostly ImageJ/FIJI code, ie java
    
    % open both images in FIJI
    impChan1 = ij.IJ.openImage([experimentStructure.savePath 'STD_Average_Ch1.tif']);
    impChan2 = ij.IJ.openImage([experimentStructure.savePath 'STD_Average_Ch2.tif']);
    
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
    MIJ.close;
    imageROI = uint16(mat2gray(imageROI)*65535);
    
    % save image
    if ~exist([experimentStructure.savePath 'Max_Project.tif'])
        saveastiff(imageROI, [experimentStructure.savePath 'Max_Project.tif']);
    end
    
    %     imageROI = imadjust(imageROI); % saturate image to make neural net prediction better
end


% get image to FIJI
MIJImageROI = MIJ.createImage('ROI_image',imageROI,true); %#ok<NASGU> supressed warning as no need to worry about
ij.process.ImageConverter(MIJImageROI).convertToRGB;


% load in pixel preference images if they exist
pixelPrefImages = dir([experimentStructure.savePath 'Pixel Orientation Pref_native*']);

% get all the FIJI stuff for each image
for i =1:length(pixelPrefImages)
    eval(['imp' num2str(i) '= ij.IJ.openImage([experimentStructure.savePath pixelPrefImages(' num2str(i) ').name]);']);
    eval(['processor' num2str(i) '= imp' num2str(i) '.getProcessor();']);
end

% create empty stack
pixelPrefStack = ij.ImageStack(imp1.getWidth, imp1.getHeight);

% fill stack with images
for i =1:length(pixelPrefImages)
    eval(['pixelPrefStack.addSlice(imp' num2str(i) '.getTitle, processor' num2str(i) ');']);
end

% display stack
stackImagePlusObj = ij.ImagePlus('Pixel Orientation Stack.tif', pixelPrefStack);
stackImagePlusObj.show; 
ij.process.ImageConverter(stackImagePlusObj).convertToRGB;


% load in pixel selectivity images if they exist
pixelSelectivityImages = dir([experimentStructure.savePath 'Pixel Orientation Selectivity_native*LCS.tif']);

% get all the FIJI stuff for each image
for i =1:length(pixelSelectivityImages)
    eval(['imp' num2str(i) '= ij.IJ.openImage([experimentStructure.savePath pixelSelectivityImages(' num2str(i) ').name]);']);
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


MIJ.run("Concatenate...", "  title=[Full Stack] open image1=ROI_image image2=[Pixel Orientation Stack.tif] image3=[Pixel Pref Stack.tif]");
% set window size and make the image easier to view
WaitSecs(0.2);
ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=10 y=50']);
ij.IJ.run('Enhance Contrast', 'saturated=0.35');

end