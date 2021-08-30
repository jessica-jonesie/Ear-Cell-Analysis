function [test] = isRGB(im)
%ISGRAY Return true if im is a gray scale image, false otherwise.
%   Detailed explanation goes here

test = (ndims(im)==3)&&(isa(im,'uint8'));

end