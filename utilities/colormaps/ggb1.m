function h=ggb1(m);
%GGB1 is a linear colormap with four axes at red,

%blue, green, and yellow.

% temp=zeros(256,3);
% % red to yellow
% aa=floor(linspace(187,210,64));
% temp(1:64,1)=aa';
% aa=floor(linspace(30,210,64));
% temp(1:64,2)=aa';
% % yellow to green
% aa=floor(linspace(210,30,65));
% temp(64:128,1)=aa';
% aa=floor(linspace(210,140,65));
% temp(64:128,2)=aa';
% % green to blue
% aa=floor(linspace(140,30,65));
% temp(128:192,2)=aa';
% aa=floor(linspace(30,165,64));
% temp(129:192,3)=aa';
% % blue to red
% aa=floor(linspace(30,184,64));
% temp(193:256,1)=aa';
% aa=floor(linspace(162,30,64));
% temp(193:256,3)=aa';
% h=temp/255;
% clear aa temp;


% more saturated version

temp=zeros(256,3);
% red to yellow
aa=floor(linspace(210,240,64));
temp(1:64,1)=aa';
aa=floor(linspace(0,210,64));
temp(1:64,2)=aa';
% yellow to green
aa=floor(linspace(240,0,65));
temp(64:128,1)=aa';
aa=floor(linspace(210,140,65));
temp(64:128,2)=aa';
% green to blue
aa=floor(linspace(140,0,65));
temp(128:192,2)=aa';
aa=floor(linspace(0,195,64));
temp(129:192,3)=aa';
% blue to red
aa=floor(linspace(0,210,64));
temp(193:256,1)=aa';
aa=floor(linspace(192,0,64));
temp(193:256,3)=aa';
h=temp/255;