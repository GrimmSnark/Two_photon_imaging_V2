function [tifStack,xyShifts, options_nonrigid] = imageRegistration(tifStack,imageRegistrationMethod,spatialResolution,filterCutoff,templateImage)
% [tifStack,xyShifts] = imageRegistration(tifStack,imageRegistrationMethod,spatialResolution,filterCutoff,templateImage)
% Registers imaging stack to a template image using either a DFT-based subpixel method ('subMicronMethod') or a
% rigid-body transform ('downsampleReg'). The template image can be directly specified, or the
% the first 100 images are used. If the filter cutoff is empty, then no spatial filtering is done to the images.
%
% by David Whitney (david.whitney@mpfi.org), Max Planck Florida Institute, 2017.


if(nargin<2) || isempty(imageRegistrationMethod), imageRegistrationMethod = 'subMicronMethod'; end % can be either subMicronMethod or downsampleReg
if(nargin<3) || isempty(spatialResolution), spatialResolution = 1.3650; end % in microns per pixel
if(nargin<4) || isempty(filterCutoff), filterCutOff  = [20,150];   end % [lowpass cutoff, highpass cutoff] in units of microns
if(nargin<5), templateImage = [];         end % templateImage is ignored when empty
imgsForTemplate     = [1:100];                % how many images to use for the template
useSpatialFiltering = ~isempty(filterCutOff); % spatially filters the images in an attempt to reduce noise that may impair registration
t0=tic;

options_nonrigid = [];

% Generate a spatially filtered template
if(isempty(templateImage))
    templateImg = uint16(mean(tifStack(:,:,imgsForTemplate),3));
else
    templateImg = templateImage;
end

if(useSpatialFiltering)
    templateImg = real(bandpassFermiFilter(templateImg,-1,filterCutOff(2),spatialResolution));        % Lowpass filtering step
    templateImg = imfilter(templateImg,fspecial('average',round(filterCutOff(1)/spatialResolution))); % Highpass filtering step
end

% Register each image to the template
numberOfImages = size(tifStack,3);
xyShifts       = zeros(2,numberOfImages);
xyShiftsGPU       = gpuArray(zeros(2,numberOfImages));


templateImgGPU = gpuArray(templateImg);
tifStackGPU = gpuArray(tifStack);



% parfor_progress(numberOfImages);
disp('Starting to calculate frame shifts');

if strcmp(imageRegistrationMethod, 'nonRigid')
    options_nonrigid = NoRMCorreSetParms('d1',size(tifStack,1),'d2',size(tifStack,2),'grid_size',[32,32],'mot_uf',4,'bin_width',200,'max_shift',29,'max_dev',3,'us_fac',50,'init_batch',200);
    [tifStack,xyShifts,~,options_nonrigid,~] = normcorre_batch(tifStack,options_nonrigid, templateImage);
    
else
    
    %     tGPU = tic;
    parfor_progress(numberOfImages);
    parfor ii = 1:numberOfImages
        % Get current image to register to the template image and pre-process the current frame.
        
        parfor_progress; % get progress in parfor loop
        
        sourceImgGPU = tifStackGPU(:,:,ii);
        if(useSpatialFiltering)
            sourceImgGPU = real(bandpassFermiFilterGPU(sourceImgGPU,-1,filterCutOff(2),spatialResolution));        % Lowpass filtering step
            sourceImgGPU = imfilter(sourceImgGPU,fspecial('average',round(filterCutOff(1)/spatialResolution))); % Highpass filtering step
        end
        
        % Determine offsets to shift image
        switch imageRegistrationMethod
            case 'subMicronMethod'
                [~,output2]=subMicronInPlaneAlignmentGPU(templateImgGPU,sourceImgGPU);
                xyShiftsGPU(:,ii) = output2(3:4);
            case 'downsampleReg'
                [xyShifts(:,ii)] = downsampleReg_singleImage(sourceImg,templateImg);
        end
    end
    %     GPUTime = toc(tGPU);
    parfor_progress(0);
    
    disp('Finished calculating frame shifts');
    disp('Starting to apply frame shifts');
    
    xyShifts = gather(xyShiftsGPU);
    tifStack = shiftImageStack(tifStack,xyShifts([2 1],:)'); % Apply actual shifts to tif stack
    
end

timeElapsed = toc(t0);
sprintf('Finished registering imaging data - Time elapsed is %4.2f seconds',timeElapsed);