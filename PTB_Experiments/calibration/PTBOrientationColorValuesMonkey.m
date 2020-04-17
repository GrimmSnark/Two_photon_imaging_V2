function [colorValues, colorDescriptors] = PTBOrientationColorValuesMonkey
% Holds the cone capture levels for the LCD monitor for the monkey color
% experiments. Calculted based of LCDmonitorCalibrations.m
% Outputs:      colorValues- values of cone capture for background (1,:)
%                            and subsequent color levels
%               colorDescriptors- Array of strings which describes each
%                                 condition for MATLAB disp output

colorValues(1,:)=[.3099 .2675 .6920]' ;     % example for all equal
colorDescriptors{1}= 'Equal Capture';

%% weighted towards L range =====================================
% (CM^-1)*[.57 .57 .5]'
colorValues(end+1,:)=[.3017 .3407 .6886]';  % example equal L+ & M+ at pi/4
colorDescriptors{end+1}= 'L+ & M+';

% (CM^-1)*[.64 .5 .5]'
colorValues(end+1,:)=[.9715 .1968 .6750]';  % example L++ & M0
colorDescriptors{end+1}= 'L++ & M0';

% (CM^-1)*[.57 .43 .5]'
colorValues(end+1,:)=[.9796 .1235 .6784]';  % example equal L+ & M- at pi/4
colorDescriptors{end+1}= 'L+ & M-';

% (CM^-1)*[.5 .36 .5]' 
colorValues(end+1,:)=[.3180 .1942 .6955]';  % example equal L- & M- at pi/4 
colorDescriptors{end+1}= 'L- & M-';

% (CM^-1)*[.43 .43 .5]'
colorValues(end+1,:)=[.9878 .0502 .6818]';  % example L0 & M--
colorDescriptors{end+1}= 'L0 & M--'; 


%% L/M vs S
% (CM^-1)*[.7 .7 .7]'
colorValues(end+1,:)=[.4338 .3744 .9689]';  % example equal L/M+ & S+ at pi/4
colorDescriptors{end+1}= 'L/M+ & S+';

% (CM^-1)*[.9 .9 .5]'
colorValues(end+1,:)=[.2633 .6862 .6725]';  % example L/M++ & S0
colorDescriptors{end+1}= 'L/M++ & S0'; 

% (CM^-1)*[.7 .7 .3]'
colorValues(end+1,:)=[.1394 .5793 .3957]';  % example equal L/M+ & S- at pi/4
colorDescriptors{end+1}= 'L/M+ & S-'; 

% (CM^-1)*[.3 .3 .3]' 
colorValues(end+1,:)=[.1859 .1605 .4152]';  % example equal L/M- & S- at pi/4 
colorDescriptors{end+1}= 'L/M- & S-';

% (CM^-1)*[.5 .5 .1]'
colorValues(end+1,:)=[.0154 .4723 .1189]';  % example L/M0 & S--
colorDescriptors{end+1}= 'L/M0 & S--';

end