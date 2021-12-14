function [averageIntensity, zPos] = getDispersionIntensity(folder2Use, channel2Use)
% Allows user to set background threshold to count only microbead pixels
% and then gets an average intensity per pixel for each z position in depth
%
% Inputs: folder2Use - filepath to the dispersion folder to analyse
%
%         channel2Use - number of channel to analyse
%
% Outputs: averageIntensity - average pixel intensity by z slice number
%
%          zPos - z position in microns for each slice
%%
% find the z stack images
file2Use = dir([folder2Use '**\ZS*\*\ZStack_Ch' num2str(channel2Use) '.tif']);

if length(file2Use) > 1
    file2Use = file2Use(1);
end

% load experimentStructure
load([file2Use.folder '\experimentStructure.mat']);

% get z position list
zPos = experimentStructure.positionsPerFrame(:,3);

% read in data
imageStack = read_Tiffs([file2Use.folder '\' file2Use.name]);

% get image to FIJI
MIJImageStack = MIJ.createImage('ImageStack',imageStack,true); %#ok<NASGU> supressed warning as no need to worry about
WaitSecs(0.2);
ij.IJ.run('Set... ', ['zoom=' num2str(300) ' x=10 y=50']);


%% FIJI set threshold

ij.IJ.runMacro('setAutoThreshold(''Default dark'')');
MIJ.run('Threshold...');


% Sets up diolg box to allow for user input to choose cell ROIs
opts.Default = 'Continue';
opts.Interpreter = 'tex';

questText = [{'Set Threshold for the stack'} ...
    {''} ...
    {'Once this is set and thresholded continue'} ...
    {'If you are happy to move on with analysis click  \bfContinue\rm'}];

response = questdlg(questText, ...
    'Check and choose ROIs', ...
    'Continue', ...
    opts);


% deals with repsonse
switch response
    
    case 'Continue' % if continue, goes on with analysis

    case ''
end

%% extract data in matlab

% bring threholded back into Matlab
imageStackThresh = MIJ.getImage('ImageStack');

% binarize
imageStackBinary = logical(imageStackThresh);

% get average intensity per pixel per slice
for q = 1:size(imageStackBinary,3)
    
    % num of pixels above threshold
    noPixelsPerSlize =  recursiveSum(imageStackBinary(:,:,q));
    
    if noPixelsPerSlize> 0
        
        imSlice = imageStack(:,:,q);
        
        sumIntensity = sum(imSlice(imageStackBinary(:,:,q)));
        
        averageIntensity(q) = sumIntensity/noPixelsPerSlize;
    end
end

MIJ.closeAllWindows;
end