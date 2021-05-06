function savePath = getParentFolder(filepath)
% Gets the parent directory of current directory in filepath


pathParts = strsplit(filepath, '\');

if isfolder(filepath)
    pathParts(end-1:end) =[];
elseif isfile(filepath)
    pathParts(end) =[];
end


% recombine path
savePath = strjoin(pathParts, '\');
savePath= strcat(savePath, '\');

end