function y=singleGaussianFit(x)

% singleGaussianFit computes the best fitting of Gaussian function
% for orientation tuning curves.  It assumes single peaks over 180 degrees.
% It returns the fit structure.
%
% Form y=dualGaussianFit(x) where x = column vector of the tuning data
% ==============================
% Correcting for missing factor of 2 in denominator of exponent, 21 July
% 2011
% ==============================

xvalue=10*([1:length(x)]'-1);    
%data=smooth(x,3); 
data=filtfilt(hann(3),sum(hann(3)),x)';
peakshift=0;    % shift data to center peak at x=10

for i=1:18
    peakshift=peakshift+10;
    data=[data(18); data(1:17)];
    [mx mi]=max(data);
    if mi==10
        break;
    end;
end;


[pks,locs]=findpeaks(data,'minpeakheight',max(data)/2.5,'npeaks',1);
locs=locs*10;

% disp('startpoint for peaks = ');disp([locs(1) locs(2)]);
% disp('peakshift =');disp(peakshift);
                   
testfit=fittype('a1*exp(-((x-b1)^2)/(2*c1^2)) + d');

s=fitoptions('Method','NonlinearLeastSquares',...
             'MaxFunEvals',2000 ,...
             'Lower', [-Inf -Inf 0 -1 ] ,...
             'Upper', [1 1 .7 .25 ]*Inf ,...
             'Startpoint',[pks(1) locs(1) 90 0]);
[f1,f2]=fit(xvalue,data,testfit,s);


if f2.rsquare < 0.9      % if first fit is not good, add bounds
    s=fitoptions('Method','NonlinearLeastSquares',...           
             'MaxFunEvals',2000 ,...
             'Lower', [0 0 0 -1  ] ,...
             'Upper', [1 1 .6 0.2]*360 ,...
             'Startpoint',[pks(1) locs(1) 40 0]);
             
    [f1,f2]=fit(xvalue,data,testfit,s);
end;

%

% plot(xvalue,x,'b.');hold on;
% 
% plot(xvalue,data,'ko');
% 
% plot(f1,'k');hold off;


% shift the fits back to original position
f1.b1=f1.b1-peakshift;
if f1.b1<0
    f1.b1=f1.b1+360;
end;

if f1.b1>180
    f1.b1=f1.b1-180;
end;

% disp('dual Gaussian fit');
% %     Peak1Amp  Peak1Loc  Peak1Width  Offset
% disp('   a1        b1        c1         d');
% disp([f1.a1 f1.b1 f1.c1 f1.d ]);
% disp('R square '); disp([f2.rsquare]);
%

% hold on; plot(f1,'b');
% hold off;

%
% legend('data','shift data','fit shift','fit data');

% Choose the output format you want:
%y=feval(f1,10*([0:.1:35.9]'))';                            % the curve fit
% y=[f1.a1 f1.b1 f1.c1 f1.d f2.rsquare];    % the fit coefficients

y.Peak1Amp = f1.a1;
y.Peak1Loc = f1.b1;
y.Peak1Width = f1.c1;
y.Offset = f1.d;
y.model = f1;
y.rsquare = f2.rsquare;
y.modelTrace = feval(f1,10*([0:.1:17.9]'))';

clear xvalue data pks locs;