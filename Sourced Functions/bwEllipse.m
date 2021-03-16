function [im,sepmasks] = bwEllipse(Resolution,Centers,MajorAxes,MinorAxes,Angles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
im = zeros(Resolution(1),Resolution(2),3);
nEllipses = length(MajorAxes);

for n=1:nEllipses
    xcoord = Centers(n,1);
    ycoord = Centers(n,2);
    MajorAxis = MajorAxes(n);
    MinorAxis = MinorAxes(n);
    Angle = Angles(n);
    
    im = draw_ellipse(ycoord,xcoord,MajorAxis/2,MinorAxis/2,-1*Angle,im,[255 255 255]);
    if nargout==2
        sepmasks{n} = imbinarize(rgb2gray(uint8(im)));
    end
end

im = imbinarize(rgb2gray(uint8(im)));

end

