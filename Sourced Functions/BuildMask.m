function [mask] = BuildMask(tgtIm,CellProps);
%BUILDMASK build a full mask knowing the pixel ids of features that make up
%the mask.
%   Detailed explanation goes here
pix = cell2mat(CellProps.PixIDs);
[imx,imy,imz] = size(tgtIm);

mask = false(imx,imy);
mask(pix) = true;
end

