classdef experimentStructureClass < dynamicprops
    % experimentStructure Class, this object holds all information
    % analysis relating to a single imaging recording. This object has
    % guidance on all standard metrics calculated. There may be some
    % undocumented entries created by developing analyses. If you wish to
    % add standard fields to this class, add the fieldname to the entries
    % in properties with appropriate comments.

    % This holds all the standard entries in the class 
    properties
        %% Prepocessing/prepData entries
        
        % string descriptor of experiment type, ie 'orientation' 
        % see also prepData
        experimentType
        
        % string of savefolder path for processed data, experimentStructure
        % see also prepData
        savePath
        
        % string of raw data folder path
        % see also prepData prepImagingMetaData
        prairiePath
        
        % string of full path to the raw event voltage .csv
        % see also prepData prepImagingMetaData
        prairiePathVoltage
        
        % string of full path to the Bruker .xml file for the recording
        % see also prepData prepImagingMetaData
        prairiePathXML
        
        % date time string of raw data acquisition
        % see also prepData prepImagingMetaData
        date
        
        % string for scan type from Bruker
        % ie 'TSeries Brightness Over Time Element'
        % see also prepData prepImagingMetaData
        scanType
        
        % string for scan mode from Bruker ie 'Galvo', 'Resonant' etc
        % see also prepData prepImagingMetaData
        scanMode
        
        % dwell time per pixel to the scan, in micro seconds
        % see also prepImagingMetaData
        dwellTime
        
        % time take to scan a full imaging frame in seconds
        % see also prepData prepImagingMetaData
        framePeriod
        
        % laser power values from PrairieView for both Insight & Femtotrain
        % Two value vector 1- Insight 2- Femtotrain
        % see also prepData prepImagingMetaData
        laserPower
        
        % excitation wavelength for Insight laser in nanometers
        % see also prepData prepImagingMetaData
        waveLengthExcitation
        
        % pixel scan lines per frame, this is the y axis size of the image
        % see also prepData prepImagingMetaData
        linesPerFrame
        
        % pixels per scan line, this is the x axis size of the image
        % see also prepData prepImagingMetaData
        pixelsPerLine
        
        % 3 number vector of microns per imaging pixel (X Y Z)
        % see also prepData prepImagingMetaData
        micronsPerPixel
        
        % name of the objective used for this recording
        % see also prepData prepImagingMetaData
        lensName
        
        % magnification of the objective used for this recording
        % see also prepData prepImagingMetaData
        lensMag
        
        % Numerical Aperture of the objective used for this recording
        % see also prepData prepImagingMetaData
        lensNA
        
        % Optical zoom of the objective used for this recording
        % see also prepImagingMetaData
        opticalZoom
        
        % Sensitivity of the photomultiplier tubes, vector of 2 numbers
        % 1- Red Channel, 2- Green Channel
        % see also prepData prepImagingMetaData
        PMTGain
        
        % 3 number vector of imaging location in microns (X Y Z)
        % related to microdrive position, Z position is the only one used
        % in analysis
        % see also prepData prepImagingMetaData
        currentPostion
        
        % number of images scanned to create single recorded image.
        % see also prepData prepImagingMetaData
        rastersPerFrame
        
        % laser power output from Bruker (no evidence this is accurate)
        % see also prepData prepImagingMetaData
        twoPhotonLaserPower
        
        % vector of absolute image frame times in ms (not used in analysis)
        % see also prepData prepImagingMetaData
        absoluteFrameTimes
        
        % vector of relative frame times in ms (zeroed to first frame)
        % see also prepData prepImagingMetaData
        relativeFrameTimes
        
        % cell array of frame names
        % see also prepData prepImagingMetaData
        filenamesFrame
        
        % string of fullfile for first image file
        % see also prepData prepImagingMetaData
        fullfile
        
        % structure of stimulus parameters used, all times in seconds
        % see also prepData prepTrialData
        stimParams
        
        % string of fullfile for the pyschtoolbox event file
        % see also prepData prepTrialData
        PTB_TimingFilePath
        
        % cell array of individual trial evnts cell contains time x evnt no
        % see also prepData prepTrialData
        rawTrials
        
        % logical vector length(trials) 1- valid, 0- invalid
        % invalid means that that trial did not have the correct essential
        % events
        % see also prepData prepTrialData
        validTrial
        
        % vector length(conditions) containing total number of repetitions 
        % see also prepData prepTrialData
        cndTotal
        
        % array of trial block event time and number (trial x time block)
        % see also prepData prepTrialData
        block
        
        % array of trial condition event time and num (trial x time cond)
        % see also prepData prepTrialData
        cnd
        
        % cell of conditions, each cell contains trial number for that cnd
        % see also prepData prepTrialData
        cndTrials
        
        % cell array of non essential events by trial
        % 2 x events : row1 = event text, row2 = array of occurcance in
        % trial x time event number x trial ( 1 x 2 x 80)
        % see also prepData prepTrialData
        nonEssentialEvent
        
        % structure of non essential events, occurance x trial in frame no
        % each event is the struture entry with the corresponding array
        % being occurance in trial x trial number ( 1 x 80 OR 295 x 80 etc)
        % see also prepData prepTrialData alignEvents2Frames
        EventFrameIndx
        
        % The frame shifts calculated from DFT rigid motion correction
        % This field is blank if non rigid motion correction used
        % Using 'subMicronMethod' option in prepData for motion correction
        % see also prepData imageRegistration
        xyShifts
        
        % The structure from no rigid motion correction
        % This field is blank if rigid motion correction used
        % Using 'nonRigid' option in prepData for motion correction
        % see also prepData imageRegistration normcorre_batch
        options_nonrigid
        
        % Image array by condition by repititon for SD during stim period
        % ie 512 x 512 x 8 x 10 
        % see also prepData createSummaryImages
        stimSTDImageCND
        
        % Image array by condition by repeat for SD during prestim period
        % ie 512 x 512 x 8 x 10 
        % see also prepData createSummaryImages
        preStimSTDImageCND
        
        % Image array by condition by repititon for mean during stim period
        % Only calculated if using GPU in createSummaryImages
        % ie 512 x 512 x 8 x 10 
        % see also prepData createSummaryImages
        stimMeanImageCND
        
        % Image array by condition by repeat for mean during prestim period
        % Only calculated if using GPU in createSummaryImages
        % ie 512 x 512 x 8 x 10 
        % see also prepData createSummaryImages
        preStimMeanImageCND
        
        % Image array by condition by repititon for SD during stim period
        % for Channel 1 (black if single channel recording)
        % ie 512 x 512 x 8 x 10 
        % see also prepData createSummaryImages
        stimSTDImageCND_Ch1
        
        % Image array by condition by repeat for SD during prestim period
        % for Channel 1 (black if single channel recording)
        % ie 512 x 512 x 8 x 10 
        % see also prepData createSummaryImages
        preStimSTDImageCND_Ch1
        
        % Image array by condition by repititon for mean during stim period
        % for Channel 1 (black if single channel recording)
        % Only calculated if using GPU in createSummaryImages
        % ie 512 x 512 x 8 x 10 
        % see also prepData createSummaryImages
        stimMeanImageCND_Ch1
        
        % Image array by condition by repeat for mean during prestim period
        % for Channel 1 (black if single channel recording)
        % Only calculated if using GPU in createSummaryImages
        % ie 512 x 512 x 8 x 10 
        % see also prepData createSummaryImages
        preStimMeanImageCND_Ch1
        
        
         % Image array by condition by repititon for SD during stim period
        % for Channel 2 (black if single channel recording)
        % ie 512 x 512 x 8 x 10 
        % see also prepData createSummaryImages
        stimSTDImageCND_Ch2
        
        % Image array by condition by repeat for SD during prestim period
        % for Channel 2 (black if single channel recording)
        % ie 512 x 512 x 8 x 10 
        % see also prepData createSummaryImages
        preStimSTDImageCND_Ch2
        
        % Image array by condition by repititon for mean during stim period
        % for Channel 2 (black if single channel recording)
        % Only calculated if using GPU in createSummaryImages
        % ie 512 x 512 x 8 x 10 
        % see also prepData createSummaryImages
        stimMeanImageCND_Ch2
        
        % Image array by condition by repeat for mean during prestim period
        % for Channel 2 (black if single channel recording)
        % Only calculated if using GPU in createSummaryImages
        % ie 512 x 512 x 8 x 10 
        % see also prepData createSummaryImages
        preStimMeanImageCND_Ch2
        
        %% Calcium analysis entries
        
        % number of cell ROIs chosen to analysis
        % see also runCaAnalysisWrapper chooseROIs CaAnalysis
        cellCount
        
        % image mask with the cell ROIs filled and numbered by their ident
        % see also runCaAnalysisWrapper CaAnalysis 
        labeledCellROI
        
        % image mask with the cell neuropil ROIs filled and numbered
        % by the corresponding cell identity 
        % see also runCaAnalysisWrapper CaAnalysis 
        labeledNeuropilROI
        
        % average radius of the cell ROIs
        % see also runCaAnalysisWrapper CaAnalysis calculateNeuropilRoiRadius
        averageROIRadius
        
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
        
        % raw fluorescence average for cell neuropil ROI for each frame
        % cellNo x frame
        % see also runCaAnalysisWrapper CaAnalysis CaExtraction
        rawF_neuropil
        
        % neuropil corrected fluorescence trace per cell per frame
        % cellNo x frame
        % calculated using method from Dipoppa et al 2018 
        % see also runCaAnalysisWrapper CaAnalysis CaExtraction estimateNeuropil
        correctedF
        
        % structure of neuropil parameters from estimateNeuropil
        % calculated using method from Dipoppa et al 2018 
        % see also runCaAnalysisWrapper CaAnalysis CaExtraction estimateNeuropil
        neuropCorrPars
        
        % rate of imaging recording in Hz
        % see also runCaAnalysisWrapper CaAnalysis CaExtraction
        rate
        
        % baseline filtered fluorescence trace for cell ROI for each frame
        % cellNo x frame
        % see also runCaAnalysisWrapper CaAnalysis CaExtraction baselinePercentileFilter
        baseline
        
        % baseline filtered fluorescence trace for cell ROI for each frame,
        % corrected to remove offset used in calculation (helps avoid
        % divide by negative number errors)
        % cellNo x frame
        % see also runCaAnalysisWrapper CaAnalysis CaExtraction
        baselineCorrected
        
        % percentage cut off used in baseline filter, using kernel density 
        % estimation (from CaImAn-MATLAB, Pnevmatikakis package)
        % see also runCaAnalysisWrapper CaAnalysis CaExtraction estimate_percentile_level
        percentileFiltCutOff
        
        % delta F/F for each cell x frame no
        % see also runCaAnalysisWrapper CaAnalysis CaExtraction 
        dF
        
        % the length in frames of a single trial
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        meanFrameLength
        
        % the frame numbers for stim ON and OFF relative to meanFrameLength
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        stimOnFrames
        
        % trial dF per cell split into conditions
        % dFperCnd{cell}{conditon}(framNo,rep)
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        dFperCnd
        
        % trial raw fluorescence per cell split into conditions
        % rawFperCnd{cell}{conditon}(framNo,rep)
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        rawFperCnd
        
        % average dF per cell split into conditions 
        % dFperCndMean{cell}(framNo,rep)
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        dFperCndMean
        
        % standard deviation dF per cell split into conditions 
        % dFperCndSTD{cell}(framNo,rep)
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        dFperCndSTD
        
        % trial prestim cell dF split into conditions
        % dFpreStimWindow{cell}{rep,condition}
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        dFpreStimWindow
        
        % average prestim cell dF split into conditions 
        % dFpreStimWindowAverage{cell}{rep,condition}
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        dFpreStimWindowAverage
        
        % trial stim cell dF split into conditions 
        % dFstimWindow{cell}{rep,condition}
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        dFstimWindow
        
        % average stim cell dF split into conditions
        % dFstimWindowAverage{cell}{rep,condition}
        % see also runCaAnalysisWrapper CaAnalysis splitDFIntoConditions
        dFstimWindowAverage
        
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
        
        % flag to show if cell is cytochrome oxidase patch or interpatch
        % ONLY for monkey data
        % 0 - interpatch, 1- patch, 2- bordering on both
        % see also checkCellROICOContourOverlap
        COIdent
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
                error([ME.message ' If ''' s.subs ''' is a property/variable please make sure that it has been created with .addprop() first.']);
            end
        end
        
        function obj = subsasgn(obj,s,varargin) 
            % Passes through all assignments in class, allows for custom
            % error throw
            try
                obj = builtin('subsasgn',obj,s,varargin{:});
            catch ME
                error([ME.message ' Use .addprop() to create the property/variable before assigning it.']);
            end
        end
    end
end

