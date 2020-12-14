function createChannelOverlapImage(experimentStructure, vol,channelIdentifier, numPixels2Use)
% Function to create average based on the lowest n number of pixels in the
% time domain
% Input- experimentStructure: structure for this experiement
%
%        vol: registered 3D image stack
%        
%        channelIdentifier: String for identifying channel
%
%        numPixels2Use: number of pixels to use to create the average,
%                       DEFAULT = 100

%% defaults

if nargin < 4 || isempty(numPixels2Use)
   numPixels2Use = 100; 
end

%% get the image pixel values sorted 
sortedImage = sort(vol,3);
sortedAverage = uint16(mean(sortedImage(:,:,1:numPixels2Use),3));

%% save image
saveastiff(sortedAverage, [experimentStructure.savePath 'OverlapImage' channelIdentifier '.tif']);
end