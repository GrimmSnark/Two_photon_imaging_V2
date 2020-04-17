function experimentStructure = readScanXMLSettings(experimentStructure, imagingStructRAW)
% Function to read in galvo scan settings from the raw XML struture
%
% Inputs- experimentStructure: experimentStructure with meta data so far
%
%         imagingStructRAW: raw imaging structure taken from 
%                           prepImagingMetaData
%
% Outputs- experimentStructure: updated experimentStructure

experimentStructure.scanMode = imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, 1}.Attributes.value;

switch experimentStructure.scanMode
    %%
    case 'Galvo'
        for i=2:length(imagingStructRAW.PVScan.PVStateShard.PVStateValue)
            
            switch i
                case 5
                    experimentStructure.dwellTime = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 6
                    experimentStructure.framePeriod = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 8
                    experimentStructure.laserPower = [str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 1}.Attributes.value) ...
                        str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 2}.Attributes.value)];
                case 9
                    experimentStructure.waveLengthExcitation = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue.Attributes.value);
                case 10
                    experimentStructure.linesPerFrame = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 12
                    experimentStructure.micronsPerPixel = [str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 1}.Attributes.value)  ...
                        str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 2}.Attributes.value)  ...
                        str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 3}.Attributes.value)] ;
                case 14
                    experimentStructure.lensName = imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value;
                case 15
                    experimentStructure.lensMag = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 16
                    experimentStructure.lensNA = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 17
                    experimentStructure.opticalZoom = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 18
                    experimentStructure.pixelsPerLine = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 19
                    experimentStructure.PMTGain = [str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 1}.Attributes.value)  ...
                        str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 2}.Attributes.value)];
                    
                case 20
                    experimentStructure.currentPostion = [str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.SubindexedValues{1, 1}.SubindexedValue.Attributes.value)  ...
                        str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.SubindexedValues{1, 2}.SubindexedValue.Attributes.value)  ...
                        str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.SubindexedValues{1, 3}.SubindexedValue.Attributes.value)] ;
                case 23
                    experimentStructure.rastersPerFrame = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 26
                    experimentStructure.twoPhotonLaserPower = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue.Attributes.value);
            end
            
        end
        
    case 'ResonantGalvo'
        %%
        for i=2:length(imagingStructRAW.PVScan.PVStateShard.PVStateValue)
            
            switch i
                case 5
                    experimentStructure.dwellTime = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 6
                    experimentStructure.framePeriod = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 8
                    experimentStructure.laserPower = [str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 1}.Attributes.value) ...
                        str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 2}.Attributes.value)];
                case 9
                    experimentStructure.waveLengthExcitation = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue.Attributes.value);
                case 10
                    experimentStructure.linesPerFrame = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 12
                    experimentStructure.micronsPerPixel = [str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 1}.Attributes.value)  ...
                        str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 2}.Attributes.value)  ...
                        str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 3}.Attributes.value)] ;
                case 14
                    experimentStructure.lensName = imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value;
                case 15
                    experimentStructure.lensMag = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 16
                    experimentStructure.lensNA = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 17
                    experimentStructure.opticalZoom = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 18
                    experimentStructure.pixelsPerLine = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 19
                    experimentStructure.PMTGain = [str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 1}.Attributes.value)  ...
                        str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 2}.Attributes.value)];
                case 20
                    experimentStructure.currentPostion = [str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.SubindexedValues{1, 1}.SubindexedValue.Attributes.value)  ...
                        str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.SubindexedValues{1, 2}.SubindexedValue.Attributes.value)  ...
                        str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.SubindexedValues{1, 3}.SubindexedValue.Attributes.value)] ;
                case 23
                    experimentStructure.rastersPerFrame = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 24
                    experimentStructure.resonantSamplesPerPixel = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
                case 27
                    experimentStructure.twoPhotonLaserPower = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue.Attributes.value);
            end
            
        end
        
    case 'Spiral'
        %%
        disp('What were you using Spiral Scan for? You need to add to this section of code, good luck');
        return
        
    otherwise
        %%
        
        disp('What scan were you using? Please check data and code');
        return
        
end

end