function outputValue = extractFromStruct(struct, isNumeric, listEntry, varargin)
% Extracts information from structures derived from xml2struct and places 
% it into cell array
% This function expects only one entry per list item...
%
% Inputs- struct: the input structure
%
%         isNumeric: 1/0 flag to convert data into numeric format
%
%         listEntry: the level (in number) that contains the list of 
%                    multiple entries
%
%         varargin: a list of strings for all the fields required to get
%         down to the data wanted
%
% Outputs- outputValue: output value/string in the structure


structString ='struct';
structStringList = structString;

% builds the entry and list strings
for i=1:length(varargin)
    structString = [structString '.' varargin{i}];
    
    if i <= listEntry
        structStringList = [structStringList '.' varargin{i}];
    end
end

if ~isempty(listEntry) % if you want to get data from a list
    if length(listEntry)<2 % if data is in only one level of list
        suffixString = varargin{listEntry+1}; % initalises the specfic fields for the data entry
        
        for i = listEntry+2:length(varargin) % adds to the specfic fields for the data entry
            suffixString = [suffixString '.' varargin{i}];
        end
        
        for i=1:length(eval(structStringList)) % runs through the list
            
            try
                outputValue{i} = eval([structStringList '{1,i}.' suffixString]);
            catch
                outputValue{i} = eval([structStringList '(1,i).' suffixString]);
            end
            
            if isNumeric % converts data to numbers
                outputValue{i} =  str2num(outputValue{i});
            end
        end
        
        if isNumeric
            outputValue = cell2mat(outputValue);
        end
        
    else % if data is in multiple levels of lists (ONLY SUPPORTS TWO LEVELS ATM
        for  b = 1:length(listEntry)
            chunkSuffix{b} = varargin{listEntry(b)+1}; % initalises the specfic fields for the data entry
            
            for i = listEntry(b)+2:listEntry((b+1)-1) % adds to the specfic fields for the data entry
                chunkSuffix{b} = [chunkSuffix{b} '.' varargin{i}];
            end
        end
        
        for i = listEntry(b)+2:length(varargin) % adds to the specfic fields for the data entry
            chunkSuffix{b} = [ chunkSuffix{b} '.' varargin{i}];
        end
        
            counter =0;
            for i=1:length(eval(structStringList)) % runs through the list
                
                for x =1:length(listEntry)
                    counter = counter +1;
                    outputValue{counter} = eval([structStringList '{1,i}.' chunkSuffix{1} '{1,x}.' chunkSuffix{2}]);
                    
                    if isNumeric % converts data to numbers
                        outputValue{counter} =  str2num(outputValue{counter});
                    end
                end
            end
            
            if isNumeric
                outputValue = cell2mat(outputValue);
            end   
    end
    
else % if there is no list
    outputValue= eval(structString);
    
    if isNumeric % converts data to numbers
        outputValue =  str2num(outputValue);
    end
end

end