load 'S:\#Data\2PhotonImg\color calibration\Dell_LCD_monitor_RGB_calibration_15Feb2019.mat';

load 'G:\LGN color\calibration\Schnapf_spectra.mat';

lcs=ones(201,1);   % available for filtering


S=zeros(3,201);n=1;         % to make S in eq. (7), Cone Sensitivities

for i=1:2:401

    S(:,n)=10.^(Schnapf_spectra(i,2:4)');

    n=n+1;

end;


% NOTE: Set the gun level to use

P=[redgun(:,3).*lcs greengun(:,3).*lcs bluegun(:,3).*lcs];

 

CM=S*P;

CM=CM/max(CM(:));               % normalized Calibration Matrix (CM)

 

allP=(1*redgun(:,2))+(.392*greengun(:,2)+(.84*bluegun(:,2))); 

pr=sum(allP.*(S(1,:)'))/sum(allP);

pg=sum(allP.*(S(2,:)'))/sum(allP);

pb=sum(allP.*(S(3,:)'))/sum(allP);

% adjust coeffs until pr, pg and pb are equal

rgbFilter=[1 .392 .84]'   % example

 

% cone catch rates computed from

cone_catch = CM*rgbFilter


% to compute the inverse relation

(CM^-1)*cone_catch 

 

%%

 

%% at 100 gun level


rgbFilter=[.3099 .2675 .6920]' ;     % example for all equal


% % (CM^-1)*[.5665-(.0665*pi4) .436+(.064*pi4) .5]'

%  rgbFilter=[.5774 .2237 .7755]';  % example equal L+ & M- at pi/4

% % (CM^-1)*[.5665-(.0665*pi4) .563-(.063*pi4) .5]'

%  rgbFilter=[.3644 .2812 .7754]';    % example equal L+ & M+ at pi/4

% % (CM^-1)*[.4335+(.0665*pi4) .436+(.064*pi4) .5]'

%  rgbFilter=[.3650 .2417 .7768]';    % example equal L- & M- at pi/4

% %  rgbFilter=[.7251 .2311 .7739]';  % example L+ & M0

% %  rgbFilter=[.7290 .1631 .7762]';  % example L0 & M-


% weighted towards L range =====================================

% (CM^-1)*[.57 .57 .5]'

rgbFilter=[.3017 .3407 .6886]';  % example equal L+ & M+ at pi/4

% (CM^-1)*[.64 .5 .5]'

rgbFilter=[.9715 .1968 .6750]';  % example L++ & M0

% (CM^-1)*[.57 .43 .5]'

rgbFilter=[.9796 .1235 .6784]';  % example equal L+ & M- at pi/4

% (CM^-1)*[.5 .36 .5]' 

 rgbFilter=[.3180 .1942 .6955]';  % example equal L- & M- at pi/4 

% (CM^-1)*[.43 .43 .5]'

rgbFilter=[.9878 .0502 .6818]';  % example L0 & M--


% (CM^-1)*[.7 .7 .7]'

rgbFilter=[.4338 .3744 .9689]';  % example equal L/M+ & S+ at pi/4

% (CM^-1)*[.9 .9 .5]'

rgbFilter=[.2633 .6862 .6725]';  % example L/M++ & S0

% (CM^-1)*[.7 .7 .3]'

rgbFilter=[.1394 .5793 .3957]';  % example equal L/M+ & S- at pi/4

% (CM^-1)*[.3 .3 .3]' 

 rgbFilter=[.1859 .1605 .4152]';  % example equal L/M- & S- at pi/4 

% (CM^-1)*[.5 .5 .1]'

rgbFilter=[.0154 .4723 .1189]';  % example L/M0 & S--


  

% cone catch rates computed from

cone_catch = CM*rgbFilter