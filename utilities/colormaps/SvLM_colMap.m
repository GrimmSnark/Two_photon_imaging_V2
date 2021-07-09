function colMap = SvLM_colMap()
% 256 colormap going from white (1) yellow (gold) to white to blue 
% Color Index values
% 0> 0.5 = S Scone
% 0.5 > 1 = LM Cone


%% white to gold
r = linspace(1, 1, 129);
g = [1 linspace(0.85, 1, 128) ];
b = [1 linspace(0, 1, 128) ];

gold2White = [r; g; b];

%% blue to white

% red and g channel 

r = linspace(1, 0, 128);
g =  r ; 
b = ones(1, 128);

white2Blue = [r(2:end) ; g(2:end); b(2:end)];


colMap = [gold2White white2Blue]';

% colormap(colMap)
% colorbar


end