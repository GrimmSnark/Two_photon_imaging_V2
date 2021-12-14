function createCaImagingExampleMovieOrientation(recordingDirProcessed, frameRate)
% Creates example movie of Ca imaging 
%
% Input: recordingDirProcessed - processed data directory
%
%        frameRate - frame rate to use when creating movie

%%
orientationPNGFileLoc = 'C:\PostDoc Docs\code\matlab\Two_photon_imaging\plotting\grating_pngs\';

%chooses default frame rate to save with
if nargin<2
    experimentStructure.rate = 1/experimentStructure.framePeriod;
    frameRate = experimentStructure.rate/experimentStructure.rastersPerFrame;
end


load([recordingDirProcessed 'experimentStructure.mat'], '-mat');

% read in orientation indicator stack
fileList =dir([orientationPNGFileLoc '*.png']);

for i =1:length(fileList)
orientationPNGs(:,:,:,i) = imread([fileList(i).folder '\' fileList(i).name]);
end

%build frame by frame presentation stack
frameByframeIndicator = zeros(size(orientationPNGs,1), size(orientationPNGs,1), size(orientationPNGs,3) , length(experimentStructure.relativeFrameTimes)); 

for cnd = 1:length(experimentStructure.cndTrials) %for each condition
    for repNo = 1:length(experimentStructure.cndTrials{cnd})
        onFrame = experimentStructure.EventFrameIndx.STIM_ON(experimentStructure.cndTrials{cnd}(repNo));
        offFrame = experimentStructure.EventFrameIndx.STIM_OFF(experimentStructure.cndTrials{cnd}(repNo));
        frameByframeIndicator(:,:,:,onFrame:offFrame) = repmat(orientationPNGs(:,:,:,cnd), 1,1,1,(offFrame-onFrame+1));
    end
    
end

 frameByframeIndicator = uint8(frameByframeIndicator);
 frameByframeIndicatorReshaped = permute(frameByframeIndicator, [1 2 4 3]);


% read in calcium image stack
vol = read_Tiffs(experimentStructure.fullfile,1);
if ndims(vol) ~=3
    vol = readMultipageTifFiles(experimentStructure.prairiePath);
end
% apply imageregistration shifts
registeredVol = shiftImageStack(vol,experimentStructure.xyShifts([2 1],:)'); % Apply actual shifts to tif stack

%% ImageJ method
% initalize MIJI
intializeMIJ;
FIJI_object = MIJ.createImage('16Bit_gray', registeredVol, false);
ij.IJ.run(FIJI_object, '8-bit', '');
ij.IJ.save(FIJI_object, [experimentStructure.savePath '8_bit stack.tif']);
MIJ.closeAllWindows();


vol8bit = read_Tiffs([experimentStructure.savePath '8_bit stack.tif'],1,100,'uint8');
vol8bitRGB = repmat(vol8bit, [1,1,1,3]);
vol8bitRGB = permute(vol8bitRGB, [1 2 4 3 ]); 

% add frame by frame indicator to bottom right of image
vol8bitRGB(end-size(frameByframeIndicator,1)+1:end,end-size(frameByframeIndicator,1)+1:end,:,:) = frameByframeIndicator;
vol8bitRGB =  permute(vol8bitRGB, [1 2 4 3 ]);

% transfers to FIJI
FIJI_object = MIJ.createColor('Color Stack', vol8bitRGB, true);

% creates save string and saves
frameRateText = strrep(num2str(frameRate), '.', '-');
commandString = ['compression=Uncompressed frame=' num2str(frameRate) ' save=' experimentStructure.savePath '\' 'RegisteredWStim_' frameRateText 'Hz.avi'];
MIJ.run("AVI... ", commandString);


end