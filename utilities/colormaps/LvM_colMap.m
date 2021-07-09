function colMap = LvM_colMap()
% 255 colormap going from white (1) red to white to green
% 0 > 0.5 = green
% 0.5 > 1 = red

%% green to white
r =[ 1 linspace(0, 1, 128)];
g = ones(1,129);
b = r;

green2White = [r; g; b];


%% red to white

% red and g channel 

r = ones(1, 128);
g =  linspace(1, 0, 128);
b = g;

white2Red = [r(2:end); g(2:end) ; b(2:end)];

colMap = [green2White white2Red]';
% 
% colormap(colMap)
% colorbar

end