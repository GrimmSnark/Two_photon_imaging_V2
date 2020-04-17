function savePath = createSavePath(directory, matlabOrMIJI, doNOTmakeDir)
% creates save path folder and fullfile based on the data folder path for
% matlab or FIJI
%
% Inputs-  directory: image data directory for the t series
%          matlabOrMIJI: switch for string type to create for
%                        1 = Matlab
%                        2 = FIJI/MIJI
%
%          doNOTmakeDir: 0/1 flag for only create the fullfile and not the
%                        folder, (OPTIONAL) defaault is 1 = create
%                        directory
%
% Output-  savePath: fullfile for save path, if doNOTmake is set to 1, will
%                    out partial string excluding current date time

%% defaults
if nargin < 3
    doNOTmakeDir = 0;
end

if matlabOrMIJI == 1
    delimeter = '\';
    delimeterEnd = '\';
elseif matlabOrMIJI == 2
    delimeter = '\\\';
    delimeterEnd = '\\';
end

%% split the path up
pathParts = split(directory, '\');
pathParts = pathParts(~cellfun('isempty',pathParts)) ;
strcmp(pathParts, 'Raw');
pathParts{ans} = 'Processed';

if doNOTmakeDir ==0
    pathParts{end+1} = datestr(now,'yyyymmddHHMMSS');
end

% recombine path
savePath = strjoin(pathParts, delimeter);
savePath= strcat(savePath, delimeterEnd);

% make folder
if doNOTmakeDir ==0
    if ~exist(savePath)
        mkdir(savePath);
    end
end

end