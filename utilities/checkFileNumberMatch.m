function checkFileNumberMatch(dir1,dir2)

files1 = dir([dir1 '\**\*']);
files2 = dir([dir2 '\**\*']);

% dir1Size = DirSize(dir1);
% dir2Size = DirSize(dir2);

if length(files1) == length(files2)
   disp('File numbers match');
   
%    if dir1Size == dir2Size
%         disp('Folder sizes match'); 
%    else
%        disp('Folder sizes DO NOT match'); 
%    end
else
     disp('File numbers DO NOT match');
end

end