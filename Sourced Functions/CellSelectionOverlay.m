function [outputArg1,outputArg2] = CellSelectionOverlay(ImDat,CellProps)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
figure
imshow(ImDat.RAW)
hold on
visboundaries(bwboundaries(ImDat.HairCellMask),'Color','r','Linewidth',0.5);
visboundaries(bwboundaries(ImDat.SupportCellMask),'Color','c','Linewidth',0.5);
end

