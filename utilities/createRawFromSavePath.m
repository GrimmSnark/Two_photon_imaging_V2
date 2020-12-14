function rawPath = createRawFromSavePath(directory)
% creates raw path folder and fullfile based on the processed data folder path

% Inputs-  directory: fullfile for save path
%
% Output-  rawPath: fullfile for raw data directory
%% defaults
if nargin < 3
    doNOTmakeDir = 0;
end

delimeter = '\';
delimeterEnd = '\';

%% split the path up
pathParts = split(directory, '\');
pathParts = pathParts(~cellfun('isempty',pathParts)) ;
strcmp(pathParts, 'Processed');
pathParts{ans} = 'Raw';

% recombine path
rawPath = strjoin(pathParts(1:end-1), delimeter);
rawPath= strcat(rawPath, delimeterEnd);

end