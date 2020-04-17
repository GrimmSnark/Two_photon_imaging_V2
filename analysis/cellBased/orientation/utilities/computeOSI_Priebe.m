function OSI = computeOSI_Priebe(responseAngles, response)
% Computes OSI based on Priebe method ( see Pattadkal et al 2018)
% Inputs- responseAngles: vector of angles used for orientation tuning
%                         curve
%         response: vector same size as responseAngles of the tuning curve
%
% Output- OSI: oirentation selectivity index value

sinResponse = (response * sin(deg2rad(responseAngles*2))') ^2;
cosResponse = (response * cos(deg2rad(responseAngles*2))') ^2;
OSI = (sqrt((sinResponse + cosResponse)))/ sum(response);

end