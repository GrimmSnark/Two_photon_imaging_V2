function outputValue = extractFieldFromStruct(struct, isNumeric, listEntry, level2Search, field2Extract, varargin)
% Extracts information from structures derived from priaire xml2struct and
% places it into cell array
%
% NB The priaire xml is a complete mess, be careful when trying to extract
% info, this function is optimised for imaging postion per frame but may be
% useful for other information
%
% This function expects only one entry per list
% item...
%
% Inputs- struct: the input structure
%
%         isNumeric: 1/0 flag to convert data into numeric format
%
%         listEntry: the level (in number) that contains the list of 
%                    multiple entries
%
%         level2Search - number of level entry to search for the correct
%                        field name
%
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
        entry2Search = varargin{listEntry+1}; % initalises the specfic fields for the data entry
        
        for i = listEntry+2:level2Search % adds to the specfic fields for the level to search for the specfic field
            entry2Search = [entry2Search '.' varargin{i}];
        end
        
        suffixText = varargin{level2Search+1};
        for cc = 1:length(varargin)-level2Search-1
            suffixText = [suffixText '.' varargin{cc + level2Search+1}];
        end
        
        for i=1:length(eval(structStringList)) % runs through the list
            
            % find the correct field to extract (The index for it changes
            % for each frame)
            for q = 1:length(eval([structStringList '{i}.' entry2Search]))
                fieldNames{q} = eval([structStringList '{i}.' entry2Search '{q}.Attributes.key']);
            end
            
            ind2Use = find(cellfun(@(S) strcmp(field2Extract,S), fieldNames)); % find index of data to use
            
            
            try
                outputValue{i} = eval([structStringList '{i}.' entry2Search '{' num2str(ind2Use) '}.' suffixText ]);
            catch
                outputValue{i} = eval([structStringList '(i).' entry2Search '{' num2str(ind2Use) '}.' suffixText ]);
            end
            
            if isNumeric % converts data to numbers
                outputValue{i} =  str2num(outputValue{i});
            end
        end
        
        if isNumeric
            outputValue = cell2mat(outputValue);
        end
    
else % if there is no list
    outputValue= eval(structString);
    
    if isNumeric % converts data to numbers
        outputValue =  str2num(outputValue);
    end
end

end