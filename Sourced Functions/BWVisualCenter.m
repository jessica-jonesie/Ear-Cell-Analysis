function [centers,centersmask,centerptim] = BWVisualCenter(bwimage)
%BWVISUALCENTER find the visual center of connected components in a binary
%image.
%   Detailed explanation goes here
if (sum(bwimage(:))==0)
    centers = [];
    centersmask = false(size(bwimage));
    centerptim = centersmask;
else
filledIm = imfill(bwimage,'holes');
centersmask = bwmorph(bwimage,'shrink',inf);
parms = regionprops(centersmask,'Centroid');
centers = cat(1,parms.Centroid);

centerptim = false(size(bwimage));

ctrpix = pts2pix(fliplr(centers),size(bwimage));
centerptim(ctrpix) = true;
end

end