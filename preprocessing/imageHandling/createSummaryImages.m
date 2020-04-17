function experimentStructure = createSummaryImages(experimentStructure, imagingVol, saveRegMovie, experimentFlag, channelIdentifier, GPUOverride)
% Creates and saves a variety of summary images from the experimental data,
% ie registered image stack, SD maps for prestim and stim period. This
% function allows you to use GPU to calculate these images if you GPU
% memory size is larger 7Gb. See function inputs to override this limit. 
%
% Input- experimentStructure: experiment structure
%
%        imagingVol: single channel imaging stack, ie 512 x 512 x 
%                    noOfFrames
%        
%        saveRegMovie: flag 0/1 to save registered movie file
%
%        experimentFlag: flag 1/0 to create images which require experiment
%                        events
%
%        channelIdentifier: OPTIONAL, string identifier for channel, ie
%                           '_Ch1'
%
%        GPUOverride: set flag to 1 if you want to override the GPU size
%                     minimum and use it anyway to create images, in 
%                     general GPU is MUCH faster than CPU!!!
%
% Output- experimentStructure: experimentStructure updated

if nargin<5 
    channelIdentifier = [];
end

if nargin <6 || isempty(GPUOverride)
    GPUOverride = 0;
end

if saveRegMovie ==1
    %         savePath = createSavePath(dataDir, 1);
    disp('Saving registered image stack')
    saveastiff(imagingVol, [experimentStructure.savePath 'registered' channelIdentifier '.tif']);
    disp('Finished saving registered image stack');
    %     saveImagingData(vol,savePath,1,size(vol,3));
end

GPU_used = gpuDevice();
if experimentFlag == 1
    if GPU_used.TotalMemory > 6e+9 || GPUOverride == 1% uses GPU to do calc if large enough
        % Create and save STD sums
        [stimSTDSum, preStimSTDSum, stimMeanSum , preStimMeanSum ,experimentStructure] = createStimSTDAverageGPU(experimentStructure, imagingVol,channelIdentifier);        
    else  % otherwise uses CPU..
        % Create and save STD sums
        [stimSTDSum, preStimSTDSum, stimMeanSum , preStimMeanSum ,experimentStructure] = createStimSTDAverage(imagingVol, experimentStructure, channelIdentifier);
    end
end

% save common images
saveastiff(stimSTDSum, [experimentStructure.savePath 'STD_Stim_Sum' channelIdentifier '.tif']);
saveastiff(preStimSTDSum, [experimentStructure.savePath 'STD_Prestim_Sum ' channelIdentifier '.tif']);
saveastiff(stimMeanSum, [experimentStructure.savePath 'Mean_Stim_Sum' channelIdentifier '.tif']);
saveastiff(preStimMeanSum, [experimentStructure.savePath 'Mean_Prestim_Sum' channelIdentifier '.tif']);



% Create STD average image and save

% deals with issues of stack size
stdVol = zeros(size(imagingVol,1), size(imagingVol,2));

if size(imagingVol,3)< 2000
    stdVol = std(double(imagingVol), [], 3);
    stdVol = uint16(mat2gray(stdVol) * 65535);
else
    yyLim = size(imagingVol,1);
    xxLim = size(imagingVol,2);
    parfor yy = 1:yyLim
        for xx = 1:xxLim
            tempData = std2(imagingVol(yy,xx,:));
            stdVol(yy,xx) = tempData;
        end
    end
    stdVol = uint16(mat2gray(stdVol) * 65535);
end

saveastiff(stdVol, [experimentStructure.savePath 'STD_Average' channelIdentifier '.tif']);

%Create normal average image and save
meanVol = mean(imagingVol,3);
meanVol = uint16(mat2gray(meanVol) * 65535);

saveastiff(meanVol, [experimentStructure.savePath 'Average' channelIdentifier '.tif']);

end