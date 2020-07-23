function errorFolders = fixXYPostionError(filepaths)
% Fixes error that caused Cell x/Y locations to be completely wrong during
% chooseROIs
% Input:  filepath- filepath string of folder for the function to search
%                    through for experimentStructure.mats OR cell string
%                    array of multiple folders to run through, ie.
%                    [{D:\Data\M1}, {D:\Data\M2}]



intializeMIJ;
%% start grabbing data
if ~iscell(filepaths)
    filepaths = cellstr(filepaths);
end

count = 0;
% for each directory in filepaths
for q = 1:length(filepaths)
    
    filepathList = dir([filepaths{q} '\**\*experimentStructure.mat']);
    
    
    % for each of the subfolders in the filepath entry
    for i = 1:length(filepathList)
        
        % sets up ROI manager for this function
        RM = ij.plugin.frame.RoiManager();
        RC = RM.getInstance();
        
        % try to load experimentStructure.mat
        try
            load([filepathList(i).folder '\experimentStructure.mat']);
        catch
            count= count+1;
            disp(['Unable to load "' filepathList(i).folder '\experimentStructure.mat" PLease check folder and structure']);
            errorFolders{count} = filepathList(i).folder;
            continue
        end
        
        %% Create the appropriate images for ROI extraction
        if exist([filepathList(i).folder '\ROIcells.zip'], 'file')
            % finds all the relevant images for ROI chosing
            files = dir([filepathList(i).folder '\STD_Average*']);
            
            if size(files,1) ==1 % if single channel recording
                imageROI = read_Tiffs([filepathList(i).folder '\STD_Average.tif'],1); % reads in average image
                imageROI = uint16(mat2gray(imageROI)*65535);
                imageROI = imadjust(imageROI); % saturate image to make neural net prediction better
                
            else
                imageROI = read_Tiffs([filepathList(i).folder '\Max_Project.tif'],1); % reads in average image
            end
            
            % get image to FIJI
            MIJImageROI = MIJ.createImage('ROI_image',imageROI,true); %#ok<NASGU> supressed warning as no need to worry about
            RC.runCommand('Open', [filepathList(i).folder '\ROIcells.zip']); % opens ROI file
            
            %% get cell data
            for x = 1:experimentStructure.cellCount
                % Select cell ROI in ImageJ/FIJI
                fprintf('Processing Cell %d\n',x)
                
                % Get cell ROI name and parse out (X,Y) coordinates
                RC.select(x-1); % Select current cell
                currentROI = RC.getRoi(x-1);
                
                experimentStructure.yPos(x) =  currentROI.getYBase;
                experimentStructure.xPos(x) = currentROI.getXBase;
                
            end
            
            MIJ.closeAllWindows
            
            %% Save the updated experimentStructure
            save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure', '-v7.3');
        end
    end
end