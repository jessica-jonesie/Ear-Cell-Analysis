function [ImArray] = uigetimages(varargin)
%UIGETIMAGES Select and load multiple images. Store as separate elements in
%cell array.
%   Detailed explanation goes here
% Default
if isempty(varargin)
    [imfile,impath] = uigetfile({'*.png;*.jpg;*.bmp'},'Multiselect','on');
else
    [imfile,impath] = uigetfile(varargin{:});
end

nIms = length(imfile);

ImArray = cell(nIms,1);
for k = 1:length(imfile)
    ImArray{k} = imread(fullfile(impath,imfile{k}));
end
end

