function OSIStruct = gatherOSILegacy(experimentStructure, OSIStruct, zScoreThreshold)
% Gathers orientation tuning info produced by legacy scripts
% Inputs: experimentStructure - structure containing all the info
%
%         OSIStruct - structure containing collated popluation OSI info
%
%         zScoreThreshold - limit to count cells that are over the z score
%                           response threshold
%
% Output: OSIStruct - updated OSI structure


if ~isempty(zScoreThreshold)
    OSIStruct.OSI_list = [OSIStruct.OSI_list; experimentStructure.OSI_FBS(experimentStructure.ZScore_FBS>zScoreThreshold)];
    OSIStruct.DSI_list = [OSIStruct.DSI_list; experimentStructure.DSI_FBS(experimentStructure.ZScore_FBS>zScoreThreshold)];
    OSIStruct.OSI_CV_list = [OSIStruct.OSI_CV_list;experimentStructure.OSI_CV_FBS(experimentStructure.ZScore_FBS>zScoreThreshold)];
else
    OSIStruct.OSI_list = [OSIStruct.OSI_list; experimentStructure.OSI_FBS];
    OSIStruct.DSI_list = [OSIStruct.DSI_list; experimentStructure.DSI_FBS];
    OSIStruct.OSI_CV_list = [OSIStruct.OSI_CV_list;experimentStructure.OSI_CV_FBS];
end

if isfield(experimentStructure, 'PVCellIndent')
    OSIStruct.ChannelOverlap = [OSIStruct.ChannelOverlap;experimentStructure.PVCellIndent];
end

end
