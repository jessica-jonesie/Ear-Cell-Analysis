function [test] = isBW(im)
%ISBW Return true if im is a binary image, false otherwise.
%   Detailed explanation goes here

test = (ndims(im)==2)&&(islogical(im));

% binary image may just be ones and zeros
if ~test
    test=(sum(im==0,'all')+sum(im==1,'all'))==numel(im);
    warning('Recommend converting binary images to logical matrices');
end

% if neither of these is true then the image isn't BW

end
