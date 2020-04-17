function OSIStruct = calculateOSI(angles, dataMeans, dataSD, dataSEM)
% Calculates OSI and DSI based on all different versions of calculation for
% comparsion for single cell. Currently uses:
%
% van hooser Cell based -  OSI= (max + max_180 - max_90 - max_270)/(max)
%                          OSI= (maxrate - rate(oppositedirection))/maxrate
%
%                          DSI= (maxrate - rate(oppositedirection))/maxrate
%
%                          CV based on Ringach 2002
%
% van hooser Model based - Based on Carandini/Ferster 2000
%
% Sincich Model with Priebe Calculation - Sincich model fit with OSI
% calculated as in Pattadkal et al 2018
%
% Inputs: angles - vector of angles testedd (in degrees)
%         dataMeans - vector of mean respones
%         dataSD - vector of STD for the responses
%         dataSEM - vector of SEM for the responses
%
% Output: OSIStruct - OSI structure containing all the information

%% van hooser 2014 OSI

if max(angles) > 180
    % uses OSI based on full 360 range
    OSI = compute_orientationindex(angles, dataMeans);
else
    % % uses OSI based on full 180 range, ie direction selectivity
    OSI = compute_directionindex(angles, dataMeans);
end

% circular variance
 CV = compute_circularvariance( angles, dataMeans );
 OSI_CV = 1 - CV;
 
 % direction index
 DSI = compute_directionindex( angles, dataMeans );
 
%% van hooser model fit OSI
oriStruct.curve(1,:) = angles;
oriStruct.curve(2,:) = dataMeans;
oriStruct.curve(3,:) = dataSD;
oriStruct.curve(4,:) = dataSEM;

OSI_FitStruct_VH = oridir_fitindexes(oriStruct);
OSI_FitStruct_VH.OSI_PR = computeOSI_Priebe(OSI_FitStruct_VH.fit(1,:), OSI_FitStruct_VH.fit(2,:));
%% LS model fit OSI with Priebe Calculation
x=interp1(dataMeans,linspace(1,length(angles),36));

OSI_FitStruct_LS = [];
OSI_FitStruct_LS.OSI = 0;

% try to run this fit, sometimes may not work as response is too flat
try
OSI_FitStruct_LS = dualGaussianFitMS(x);

response = OSI_FitStruct_LS.modelTrace;
responseAngles = 1:length(response);

OSI_FitStruct_LS.OSI = computeOSI_Priebe(responseAngles, response);
catch
    
end

%% build OSIStruct

OSIStruct.OSI = OSI;
OSIStruct.DSI = DSI;
OSIStruct.CV = CV;
OSIStruct.OSI_CV = OSI_CV;
OSIStruct.VHStruct = OSI_FitStruct_VH;
OSIStruct.LSStruct = OSI_FitStruct_LS;
end