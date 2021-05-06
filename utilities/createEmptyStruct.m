function emptyStruct = createEmptyStruct(fieldNames)
% Creates an empty structure with field names specified by fieldNames

cmdString = [];
for i = 1:length(fieldNames)
   cmdString =  [cmdString  '''' fieldNames{i} '''' ',[],'];
end

cmdString = cmdString(1:end-1);

emptyStruct = eval(['struct(' cmdString ')']);
end