function [test] = isBW(im)
%ISBW Return true if im is a binary image, false otherwise.
%   Detailed explanation goes here

test = (ndims(im)==2)&&(islogical(im));

end
