function colMap = SvLMlog_colMap()
% 256 colormap going from white (1) yellow (gold) to white to blue 
% Color Index values
% 0> 0.5 = S Scone
% 0.5 > 1 = LM Cone


%% white to gold
r = linspace(1, 1, 129);
g = [1 logspace(log10(1.85), log10(2), 128)-1 ];
b = [1 logspace(log10(1), log10(2), 128)-1 ];

gold2White = [r; g; b];

%% blue to white

% red and g channel 

r = logspace(log10(2), log10(1), 128)-1;
g =  r ; 
b = ones(1, 128);

white2Blue = [r(2:end) ; g(2:end); b(2:end)];


colMap = [gold2White white2Blue]';

% colormap(colMap)
% colorbar
