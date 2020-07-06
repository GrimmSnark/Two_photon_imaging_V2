classdef dendriteStructureClass < dynamicprops
    % dendriteStructure Class, this object holds all information
    % analysis relating to a dendrite imaging analysis. This object has
    % guidance on all standard metrics calculated. There may be some
    % undocumented entries created by developing analyses. If you wish to
    % add standard fields to this class, add the fieldname to the entries
    % in properties with appropriate comments.

    % This holds all the standard entries in the class 
    properties
        %% Calcium analysis entries
        
        % number of cell ROIs chosen to analysis
        % see also runCaAnalysisWrapper chooseROIs CaAnalysis
        cellCount
        
 
        % vector of x center postions for each cell
        % see also runCaAnalysisWrapper CaAnalysis CaExtraction
        xPos
        
        % vector of y center postions for each cell
        % see also runCaAnalysisWrapper CaAnalysis CaExtraction
        yPos
        
        % raw fluorescence value average for each cell ROI for each frame
        % cellNo x frame
        % see also runCaAnalysisWrapper CaAnalysis CaExtraction
        rawF
       
        % trial raw fluorescence per cell split into conditions
        % rawFperCnd{cell}{conditon}(framNo,rep)
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        rawFperCnd
        
        % the length in frames of a single trial
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        meanFrameLength
        
        % trial dF per cell split into conditions, for first frame before
        % stimulus subtraction
        % dFperCndFBS{cell}{conditon}(framNo,rep)
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        dFperCndFBS
        
        % average dF per cell split into conditions, for first frame before
        % stimulus subtraction
        % dFperCndMeanFBS{cell}(framNo,rep)
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        dFperCndMeanFBS
        
        % standard deviation dF per cell split into conditions, for first 
        % frame before stimulus subtraction 
        % dFperCndSTDFBS{cell}(framNo,rep)
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        dFperCndSTDFBS
        
        % trial prestim cell dF split into conditions, for first frame
        % before stimulus subtraction 
        % dFpreStimWindowFBS{cell}{rep,condition}
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        dFpreStimWindowFBS
        
        % average prestim cell dF split into conditions, for first frame
        % before stimulus subtraction 
        % dFpreStimWindowAverageFBS{cell}{rep,condition}
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        dFpreStimWindowAverageFBS
        
        % trial stim cell dF split into conditions, for first frame
        % before stimulus subtraction 
        % dFstimWindowFBS{cell}{rep,condition}
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        dFstimWindowFBS
        
        % average stim cell dF split into conditions, for first frame
        % before stimulus subtraction 
        % dFstimWindowAverageFBS{cell}{rep,condition}
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        dFstimWindowAverageFBS
        
        %% Analysis metric entries
       
        % ZScore of preferrred condition for each cell
        % ZScore calculation = (maxStimData - prestimMean) /prestimSD
        % see also calculateOSIPopulation_wrapper calculateOSIPopulation
        ZScore 
       
        % struct of orientation selectivity index info for each cell
        % cell no x number second condition dimension, ie color/SF etc
        % struct currently contains:
        %
        % Van Hooser 2014 - Based on condition mean values
        %     Orientation selectivity index (OSI)- compute_orientationindex
        %     Direction selectivity index(DSI)- compute_directionindex
        %     Circular varience OSI (1-CV)[OSI_CV] - compute_circularvariance
        %
        % .VHStruct - Based on Van Hooser curve fitting
        % [oridir_fitindexes,computeOSI_Priebe]
        %     OSI - ot_index_rectified
        %     DSI - dir_index_rectified
        %     preferred angle - dirpref
        %     OSI_PR - Priebe based OSI on van hooser fit
        %         NB See function for more detail on other entries
        %
        % .LSStruct - Based on Sincich curve fitting
        % [dualGaussianFitMS,computeOSI_Priebe]
        %     preferred angle - Peak1Loc
        %     OSI - Priebe based OSI on sincich fit
        %         NB See function for more detail on other entries
        % see also calculateOSIPopulation_wrapper calculateOSIPopulation calculateOSI
        OSIStruct
        
        % flag to show whether cell is found in both recording channels 
        % of 2 channel imaging 0 - only functional channel, 1- functional &
        % structural channel
        % see also checkDualChannelExpression
        ChannelOverlap
        
    end
    methods
        function deleteprop(obj,propName)
            % Allows for deletion of non standard entries into the class
            % Called by experimentStructure.deleteprop('FieldName');
            propMeta = findprop(obj,propName);
            
            if isa(propMeta, 'meta.DynamicProperty')
                delete(propMeta);
            else
                disp([propMeta.Name ' is not a dynamic property, can not delete']);
            end
        end
        
        function varargout = subsref(obj,s)
            % Passes through all references in class, allows for custom
            % error throw
            try
                [varargout{1:nargout}] = builtin('subsref',obj,s);
            catch ME
                error([ME.message ' If ''' s(1).subs ''' is a property/variable please make sure that it has been created with .addprop(''' s(1).subs ''') first.']);
            end
        end
        
        function obj = subsasgn(obj,s,varargin) 
            % Passes through all assignments in class, allows for custom
            % error throw
            try
                obj = builtin('subsasgn',obj,s,varargin{:});
            catch ME
                error([ME.message ' Use .addprop(''' s(1).subs ''') to create the property/variable before assigning it.']);
            end
        end
    end
end

