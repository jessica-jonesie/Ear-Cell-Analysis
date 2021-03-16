function [datmap,figHandle,axHandle,labels] = DataMap(bwIm,stat,varargin)
%Color labels according to an input statistic
%   Detailed explanation goes here
[labels, n] = bwlabel(bwIm);

if n~=length(stat)
    error('Length of input data vector must be equal to the number of connected objects found in bwIm')
end

datmap = labels;
datmap(datmap==0) = NaN;
for k=1:n
    datmap(labels==k) = stat(k);
end

% Optional blurring
if nargin>2 && length(varargin)==2
    if strcmp(varargin{1},'Gaussian')
        imFilter = fspecial('gaussian',varargin{2},varargin{2});
    elseif strcmp(varargin{1},'Disk')
        imFilter = fspecial('disk',varargin{2});
    else
        error('Invalid filter type')
    end
    datmap = nanconv(datmap,imFilter,'edge');
end

figHandle = figure;
axHandle = pcolor(flipud(datmap));
set(axHandle, 'EdgeColor', 'none')
end