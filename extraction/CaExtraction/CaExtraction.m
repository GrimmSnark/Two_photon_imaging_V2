function experimentStructure = CaExtraction(experimentStructure, channel2Use)
% Function enacts main Ca trace analysis for movie files, applys motion
% correction shifts which were previously calculated, exacts rawF for cells
% and neuropil, does neuropil correction, calculates dF/F and segements out
% traces into cell x cnd x trace and makes averages & STDs per cnd
%
% Inputs - experimentStructure (structure containing all experimental data)
%
%          channel2Use: can specify channel to analyse if there are more
%                       than one recorded channel
%                      (OPTIONAL) default = 2 (green channel)
%
% Outputs - experimentStructure (updated structure)

%% set defaults

if nargin <2 || isempty(channel2Use)
    channel2Use = 2; % sets default channel to use if in multi channel recording
end

%% Basic setup of tif stack

% sets up ROI manager for this function
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();

% read in tiff file
vol = read_Tiffs(experimentStructure.fullfile,1);
if ndims(vol) ~=3
    vol = readMultipageTifFiles(experimentStructure.prairiePath);
end


% check number of channels in imaging stack
channelIndxStart = strfind(experimentStructure.filenamesFrame{1}, '_Ch');
for i =1:length(experimentStructure.filenamesFrame)
    channelIdentity{i} = experimentStructure.filenamesFrame{i}(channelIndxStart:channelIndxStart+3);
end
channelNo = unique(channelIdentity);

% chooses correct channel to analyse in multichannel recording
if length(channelNo)>1
    volSplit =  reshape(vol,size(vol,1),size(vol,2),[], length(channelNo));
    vol = volSplit(:,:,:,channel2Use);
end

% apply imageregistration shifts if there are shifts to apply
if isprop(experimentStructure, 'options_nonrigid') && ~isempty(experimentStructure.options_nonrigid) % if using non rigid correctionn
    registeredVol = apply_shifts(vol,experimentStructure.xyShifts,experimentStructure.options_nonrigid);
elseif  ~isempty(experimentStructure.xyShifts)
    registeredVol = shiftImageStack(vol,experimentStructure.xyShifts([2 1],:)'); % Apply actual shifts to tif stack
else % if there are no motion correction options, ie the image stack loaded is already motion corrected
    registeredVol = vol;
end

% transfers to FIJI
registeredVolMIJI = MIJ.createImage( 'Registered Volume', registeredVol,true);

%% start running raw trace extraction

% allocate fields
experimentStructure.rawF = [];
experimentStructure.rawF_neuropil =[];
experimentStructure.xPos = zeros(experimentStructure.cellCount,1);
experimentStructure.yPos = zeros(experimentStructure.cellCount,1);

for x = 1:experimentStructure.cellCount
    % Select cell ROI in ImageJ/FIJI
    fprintf('Processing Cell %d\n',x)
    
    % Get cell ROI name and parse out (X,Y) coordinates
    RC.select(x-1); % Select current cell
    currentROI = RC.getRoi(x-1);
%     [tempLoc1,tempLoc2] = strtok(char(RC.getName(x-1)),'-');
%     experimentStructure.yPos(x) =  str2double(tempLoc1);
%     experimentStructure.xPos(x) = -str2double(tempLoc2);

    experimentStructure.yPos(x) =  currentROI.getYBase;
    experimentStructure.xPos(x) = currentROI.getXBase;

    
    % Get the fluorescence timecourse for the cell and neuropil ROI by
    % using ImageJ's "z-axis profile" function.
    for isNeuropilROI = 0:1
        ij.IJ.getInstance().toFront();
        
        plotTrace = ij.plugin.ZAxisProfiler.getPlot(registeredVolMIJI);
        RT(:,1) = plotTrace.getXValues();
        RT(:,2) = plotTrace.getYValues();
        
        if isNeuropilROI
            %RC.setName(sprintf('Neuropil ROI %d',i));
            experimentStructure.rawF_neuropil(x,:) = RT(:,2);
        else
            %RC.setName(sprintf('Cell ROI %d',i));
            experimentStructure.rawF(x,:) = RT(:,2);
            RC.select((x-1)+experimentStructure.cellCount); % Now select the associated neuropil ROI
        end
    end
end

%% subtract neuropil signal

% Compute the neuropil-contributed signal from our cells, and eliminate
% them from our raw cellular trace
[experimentStructure.correctedF, experimentStructure.neuropCorrPars]=estimateNeuropil(experimentStructure.rawF,experimentStructure.rawF_neuropil); % neuropil subtraction calculated from Dipoppa et al 2018


%% Define a moving and fluorescence baseline using a percentile filter
experimentStructure.rate      = 1/experimentStructure.framePeriod; % frames per second
experimentStructure.baseline  = 0*experimentStructure.rawF;


for q =1:experimentStructure.cellCount
    fprintf('Computing baseline for cell %d \n', q);
    
    % Compute a moving baseline with a 60s percentile lowpass filter smoothed by a 60s Butterworth filter
    offset = 5000; % helps get around dividing my zero errors...
    [~,percentileFiltCutOff(q)] = estimate_percentile_level((experimentStructure.correctedF(q,:)'+offset),length(registeredVol),length(registeredVol));
    
   lowPassFiltCutOff    = 30; %in seconds
    experimentStructure.baseline(q,:)  = baselinePercentileFilter((experimentStructure.correctedF(q,:)'+offset),experimentStructure.rate,lowPassFiltCutOff,percentileFiltCutOff(q));

end

% store percentile rank filter cutoff for each cell
experimentStructure.percentileFiltCutOff = percentileFiltCutOff;

% store corrected baseline (i.e remove offset)
experimentStructure.baselineCorrected = experimentStructure.baseline-offset;

%% computer delta F/F traces
experimentStructure.dF = ((experimentStructure.correctedF+offset)-experimentStructure.baseline)./experimentStructure.baseline;

end