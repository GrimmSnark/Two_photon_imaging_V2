function emptyStruct = createEmptyStruct(fieldNames, primingValue)
% Creates an empty structure with field names specified by fieldNames

cmdString = [];
for i = 1:length(fieldNames)
   cmdString =  [cmdString  '''' fieldNames{i} '''' ',[],'];
end

cmdString = cmdString(1:end-1);

emptyStruct = eval(['struct(' cmdString ')']);

if nargin > 1 || ~isempty(primingValue)
    for x = 1: length(fieldNames)
        emptyStruct.(fieldNames{x}) = primingValue;
    end
end

end