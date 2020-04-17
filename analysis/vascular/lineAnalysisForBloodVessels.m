function lineAnalysisForBloodVessels(recordingDir)
% Function gets line plot intensity averages from 2P data. Used for
% examining blood vessel diameter without contrast agent (in F32
% application)

magSize = 300; % magnification for image viewing
%% Deals with ROI zip file creation and loading and makes neuropil surround ROIs

if contains(recordingDir, 'Raw') % if you specfy the raw folder then it finds the appropriate processed folder
    recordingDirRAW = recordingDir; % sets raw data path
    
    % sets processed data path
    recordingDirProcessed = createSavePath(recordingDir, 1, 1);
    recordingDirProcessed = recordingDirProcessed(1: find(recordingDirProcessed =='\', 2, 'last'));
    
elseif  contains(recordingDir, 'Processed')
    recordingDirProcessed = recordingDir; % sets processed data path
    recordingDirRAW = createRawFromSavePath(recordingDir); % sets raw data path
end

% open all the relevant images for ROI chosing
if exist([recordingDirProcessed 'STD_Stim_Sum.tif'], 'file')
    imageROI = read_Tiffs([recordingDirProcessed 'STD_Stim_Sum.tif'],1);
else
    firstSubFolder = returnSubFolderList(recordingDirProcessed);
    
    if isempty(preproFolder2Open) % if not otherwise specified chooses the latest preprocessing folder
        preproFolder2Open = length(firstSubFolder);
    end
    
    recordingDirProcessed = [firstSubFolder(preproFolder2Open).folder '\' firstSubFolder(preproFolder2Open).name '\']; % gets analysis subfolder
    
    try
        imageROI = read_Tiffs([recordingDirProcessed 'STD_Stim_Sum.tif'],1);
    catch
        disp('Average image not found, check filepath or run prepData.m  or prepDataMultiSingle.m on the recording folder')
        return
    end
end

% load experimentStructure
load([recordingDirProcessed 'experimentStructure.mat']);

% Get imaging data and motion correct
% load experimentStructure
load([recordingDirProcessed 'experimentStructure.mat']);

vol = read_Tiffs(experimentStructure.fullfile,1);
if ndims(vol) ~=3
    vol = readMultipageTifFiles(experimentStructure.prairiePath);
end
% apply imageregistration shifts
registeredVol = shiftImageStack(vol,experimentStructure.xyShifts([2 1],:)'); % Apply actual shifts to tif stack

% transfers to FIJI
intializeMIJ;
registeredVolMIJI = MIJ.createImage( 'Registered Volume', registeredVol,false);


% initalize MIJI
intializeMIJ;
ij.IJ.setTool('LINE');


% get image to FIJI
MIJImageROI = MIJ.createImage('ROI_image',imageROI,false); %#ok<NASGU> supressed warning as no need to worry about

if exist([experimentStructure.savePath 'Pixel Orientation Selectivity_native.tif'], 'file')
    pixelPref = read_Tiffs([experimentStructure.savePath 'Pixel Orientation Selectivity_native.tif'],1);
end

if exist('pixelPref', 'var')
    
    prefImp = ij.IJ.openImage([experimentStructure.savePath 'Pixel Orientation Selectivity_native.tif']);
    prefImpConvert = ij.process.ImageConverter(prefImp);
    prefImpConvert.convertToGray16();
    
    prefImpProcess = prefImp.getProcessor();
    MIJImageROIImpProcess = MIJImageROI.getProcessor();
    
    pixelPrefStack = ij.ImageStack(prefImpProcess.getWidth, prefImpProcess.getHeight);
        pixelPrefStack.addSlice(MIJImageROI.getTitle, MIJImageROIImpProcess);
    pixelPrefStack.addSlice(prefImp.getTitle, prefImpProcess);
    
    stackImagePlusObj = ij.ImagePlus('Pixel Orientation Stack.tif', pixelPrefStack);
    stackImagePlusObj.show;
    stackImagePlusObj.setSlice(2);
    ij.IJ.run(stackImagePlusObj, "Enhance Contrast", "saturated=0.35 normalize");
    WaitSecs(0.2);
    ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=500 y=50']);
else
    stackImagePlusObj = MIJImageROI;
end

happy = 0;
while happy == 0
    response = MFquestdlg([0.5,1],sprintf(['Choose straight line for analysis \n' ...
        'If you are happy to move on with processing click Continue \n' ...
        'If you want to rechoose another area click Clear All \n' ...
        'Or exit out of this window to exit script']), ...
        'Wait for user to do stuff', ...
        'Continue', ...
        'Clear All', ...
        'Continue');
    
    if isempty(response) || strcmp(response, 'Continue')
        happy =1; % kicks you out of loop if continue or exit
    else
        happy = 0;
    end
end

% create subfunction from here
% plotLineDynamics(stackImagePlusObj,registeredVolMIJI, experimentStructure,1 );
plotLineDynamicsForF32(stackImagePlusObj,registeredVolMIJI, experimentStructure, 0, 1);

hold;
end
