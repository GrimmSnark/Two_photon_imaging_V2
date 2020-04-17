function nums = stringEvent2Num(strings, codes)
% converts string events into event number code
%
% Inputs- strings: string or cell string of event codes
%
%         codes: cell array of codes matches to number position
%
% Outputs- nums: number vector of the string codes

%%
if iscell(strings)
    nums = zeros(1,length(strings));
    for i=1:length(strings)
        nums(1,i) = find(strcmp(strings{i}, codes), 1);
    end
    
else
    nums(1) = find(strcmp(strings, codes), 1);
end
end