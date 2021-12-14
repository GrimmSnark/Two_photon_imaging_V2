function [dots] =  createDotColorStructure(dots, colorsMat)

dotDensity = dots.dotDensity/size(colorsMat, 1);

for c = 1:size(colorsMat, 1)
    dots(c).dotDensity = dotDensity;
    dots(c).speed = dots(1).speed; 
    dots(c).direction = dots(1).direction;
    dots(c).lifetime = dots(1).lifetime;
    dots(c).apertureSize = dots(1).apertureSize;
    dots(c).center = dots(1).center;
    dots(c).color = colorsMat(c,:);
    dots(c).size = dots(1).size;
    dots(c).coherence = dots(1).coherence; 
end

end