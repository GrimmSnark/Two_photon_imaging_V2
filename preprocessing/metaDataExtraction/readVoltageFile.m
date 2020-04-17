function data = readVoltageFile(filepath)
% reads in cvs file for voltage very fast
%
% Input- filepath: fullfile for voltage csv
%
% Output- data: structure with column headers and the voltage data in matrix

%%
% opens file
fileID = fopen(filepath);

% reads in headers
headerLine = fgetl(fileID);
headers = strsplit(headerLine,', ');

columns ='%f';

% changes column number depending on header number
for i=length(headers)-1
    columns = [columns ' %f64'];
end

% reads in number data into cell
numDataCell = textscan(fileID, columns, 'Delimiter',',', 'CollectOutput' ,1);

%close file
fclose(fileID);

%converts to matrix
numData = cell2mat(numDataCell);

% places data in data structure
data.headers = headers;
data.Voltage = numData; 

end