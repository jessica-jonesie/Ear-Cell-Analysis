function [] = PolarityMaps(CellProps,ImDat,clrMap)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%% Hair Cell Polarity
data = CellProps.CombinedPolarity(CellProps.Type=='H');
bwIm = ImDat.HairCellMask;

[datmap,fH,axH] = DataMap(bwIm,data);
colormap(flipud(brewermap([],clrMap)))
cbar= colorbar;

ylabel(cbar,'Magnitude of Intracellular Polarity');
title('Hair Cell MIP')

%% Hair Cell Polarity Blurred
data = CellProps.CombinedPolarity(CellProps.Type=='H');
bwIm = ImDat.HairCellMask;

[datmap,fH,axH] = DataMap(bwIm,data,'Disk',70); 
colormap(flipud(brewermap([],clrMap)))
cbar= colorbar;

ylabel(cbar,'Magnitude of Intracellular Polarity (Blurred)');
title('Hair Cell MIP Blurred')
%% Support Cell Polarity
data = CellProps.CombinedPolarity(CellProps.Type=='S');
bwIm = ImDat.SupportCellMask;

[datmap,fH,axH] = DataMap(bwIm,data);
colormap(flipud(brewermap([],clrMap)))
cbar= colorbar;

ylabel(cbar,'Magnitude of Intracellular Polarity');
title('Support Cell MIP')
%% Support Cell Polarity
data = CellProps.CombinedPolarity(CellProps.Type=='S');
bwIm = ImDat.SupportCellMask;

[datmap,fH,axH] = DataMap(bwIm,data,'Disk',70);
colormap(flipud(brewermap([],clrMap)))
cbar= colorbar;

ylabel(cbar,'Magnitude of Intracellular Polarity');
title('Support Cell MIP Blurred')
end

