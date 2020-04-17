function OSIStruct = gatherOSI(experimentStructure, OSIStruct, zScoreThreshold)
% Gathers orientation tuning info
% Inputs: experimentStructure - structure containing all the info
%
%         OSIStruct - structure containing collated popluation OSI info
%
%         zScoreThreshold - limit to count cells that are over the z score
%                           response threshold
%
% Output: OSIStruct - updated OSI structure

%% get the data

    for i = 1:experimentStructure.cellCount
       OSI(i) =  experimentStructure.OSIStruct(i).VHStruct.OSI_PR;
       DSI(i) =  experimentStructure.OSIStruct(i).VHStruct.dir_index_rectified;
    end
    
    OSI_CV = [experimentStructure.OSIStruct.OSI_CV];
    %% If using z score threshold, filter the data
    
if ~isempty(zScoreThreshold)
    OSIStruct.OSI_list = [OSIStruct.OSI_list; OSI(experimentStructure.ZScore>zScoreThreshold)'];
    OSIStruct.DSI_list = [OSIStruct.DSI_list; OSI(experimentStructure.ZScore>zScoreThreshold)'];
    OSIStruct.OSI_CV_list = [OSIStruct.OSI_CV_list;OSI_CV(experimentStructure.ZScore>zScoreThreshold)'];
else
    OSIStruct.OSI_list = [OSIStruct.OSI_list; OSI'];
    OSIStruct.DSI_list = [OSIStruct.DSI_list; DSI'];
    OSIStruct.OSI_CV_list = [OSIStruct.OSI_CV_list; OSI_CV'];
end

% gather dual channel stuff if needed
if isfield(experimentStructure, 'ChannelOverlap')
    OSIStruct.ChannelOverlap = [OSIStruct.ChannelOverlap;experimentStructure.ChannelOverlap];
    
elseif isfield(experimentStructure, 'PVCellIndent')
    OSIStruct.ChannelOverlap = [OSIStruct.ChannelOverlap;experimentStructure.PVCellIndent];
end

end
