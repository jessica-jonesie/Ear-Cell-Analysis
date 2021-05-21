function [imgOut] = getImChannel(imgIn,chann)
%GETIMCHANNEL get a specific channel of an RGB image. 
%   Detailed explanation goes here
if strcmpi(chann,'r')||strcmpi(chann,'red')||chann(1)==1
    imgOut = imgIn(:,:,1);
elseif strcmpi(chann,'g')||strcmpi(chann,'green')||chann(1)==2
    imgOut = imgIn(:,:,2);
elseif strcmpi(chann,'b')||strcmpi(chann,'blue')||chann(1)==3
    imgOut = imgIn(:,:,3);
else
    error('Invalid channel type. Must be R, G, or B.')
end
end

