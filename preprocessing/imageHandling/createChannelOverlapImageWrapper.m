function createChannelOverlapImageWrapper(directory, startDirNo, channel2Check, numPixels2Use)
% Runs through all the processed files in subfolders of 'directory' and
% calls the overlap image function
%
% Inputs- directory: filepath for the processed data folder, will search
%                    all subfolders for experimentStructure.mat
%
%         startDirNo: specify the number folder to start on (OPTIONAL)
%
%         channel2Check: Specify channel number to check for dual
%                        expression, ie 1 (red channel)/ 2(green channel)
%                        OPTIONAL- default = 1 (red channel)

%% Defaults
if nargin <2 || isempty(startDirNo)
    startDirNo = 1;
end

if nargin <3 || isempty(channel2Check)
    channel2Check = 1; % sets deafult channel to use if in mult
end


if nargin <4 || isempty(numPixels2Use)
    numPixels2Use = 100; % sets number of pixels to use for the averages
end

%%
folder2Process = dir([directory '**\experimentStructure.mat']);

for i = startDirNo:length(folder2Process)
    
    % load experimentStructure
    load([folder2Process(i).folder '\experimentStructure.mat']);
    
    % read in tiff file
    vol2Check = read_Tiffs(experimentStructure.fullfile,1);
    if ndims(vol2Check) ~=3
        vol2Check = readMultipageTifFiles(experimentStructure.prairiePath);
    end
    
    
    % check number of channels in imaging stack
    channelIndxStart = strfind(experimentStructure.filenamesFrame{1}, '_Ch');
    for i =1:length(experimentStructure.filenamesFrame)
        channelIdentity{i} = experimentStructure.filenamesFrame{i}(channelIndxStart:channelIndxStart+3);
    end
    channelNo = unique(channelIdentity);
    
    % chooses correct channel to analyse in multichannel recording
    if length(channelNo)>1
        volSplit =  reshape(vol2Check,size(vol2Check,1),size(vol2Check,2),[], length(channelNo));
        vol2Check = volSplit(:,:,:,channel2Check);
    end
    
    % apply imageregistration shifts if there are shifts to apply
    if isprop(experimentStructure, 'options_nonrigid') && ~isempty(experimentStructure.options_nonrigid) % if using non rigid correctionn
        registeredVol = apply_shifts(vol2Check,experimentStructure.xyShifts,experimentStructure.options_nonrigid);
    elseif  ~isempty(experimentStructure.xyShifts)
        registeredVol = shiftImageStack(vol2Check,experimentStructure.xyShifts([2 1],:)'); % Apply actual shifts to tif stack
    else % if there are no motion correction options, ie the image stack loaded is already motion corrected
        registeredVol = vol2Check;
    end
    
    
    createChannelOverlapImage(experimentStructure, registeredVol,['_Ch' num2str(channel2Check)], numPixels2Use);
end
end