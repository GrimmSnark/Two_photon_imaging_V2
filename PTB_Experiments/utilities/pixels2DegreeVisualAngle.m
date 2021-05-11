function [sizeInDegree, degreePerPix] = pixels2DegreeVisualAngle(setup, sizeInPixs)
%converts sizeInPixs (pixel size of object) into degrees of visual angle
%based on setup information (add to switch case for more setups)

switch setup
    case 1 % Shel 1170 monitor
        hM = 20; % hight of monitor in cm
        d = 57; % distance from monitor in cm
        res = 1024; % vertical resolution of monitor in cm
        
    case 2 % RSB LCD Monitor Monkey
        hM = 30; % hight of monitor in cm, width is 53 cm
        d = 57; % distance from monitor in cm
        res = 1440; % vertical resolution of monitor in cm
        
    case 3 % RSB LCD Monitor Mouse
        hM = 30; % hight of monitor in cm, width is 53cm
        d = 20; % distance from monitor in cm
        res = 1440; % vertical resolution of monitor in cm
        
    case 4 
        hM = 38; % hight of monitor in cm, width is 53cm
        d = 50; % distance from monitor in cm
        res = 2880; % vertical resolution of monitor in cm
end

degreePerPix = rad2deg(atan2((0.5*hM),d)) / (0.5*res);

sizeInDegree = sizeInPixs * degreePerPix;
end