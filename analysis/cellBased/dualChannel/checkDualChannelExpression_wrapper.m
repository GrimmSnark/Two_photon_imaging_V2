function  checkDualChannelExpression_wrapper(directory, startDirNo, channel2Check)
% Wrapper to run though all subfolders of directory to check whether cell
% ROIs are visible in both recording channels.
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

%% start FIJI
try
   MIJ.closeAllWindows; 
catch
    intializeMIJ;
end

subFolders = dir([directory '**\experimentStructure.mat']);

for i = startDirNo:length(subFolders)
    checkDualChannelExpression([subFolders(i).folder '\'], channel2Check);
end
end