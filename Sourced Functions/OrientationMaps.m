function [] = OrientationMaps(CellProps,ImDat,clrMap)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%% Hair Cell Orientation
data = CellProps.NormOrientation(CellProps.Type=='H');
bwIm = ImDat.HairCellMask;

[datmap,fH,axH] = DataMap(bwIm,abs(data));
colormap(flipud(brewermap([],clrMap)))
cbar= colorbar;
caxis([0 180])

ylabel(cbar,'Orientation with Respect to Utricular Boundary');
title('Hair Cell Orientation')

%% Hair Cell Orientation Blurred
data = CellProps.NormOrientation(CellProps.Type=='H');
bwIm = ImDat.HairCellMask;

[datmap,fH,axH] = DataMap(bwIm,abs(data),'Disk',70);
colormap(flipud(brewermap([],clrMap)))
cbar= colorbar;
caxis([0 180])

ylabel(cbar,'Orientation with Respect to Utricular Boundary');
title('Hair Cell Orientation Blurred')

%% Support Cell Orientation
data = CellProps.NormOrientation(CellProps.Type=='S');
bwIm = ImDat.SupportCellMask;

[datmap,fH,axH] = DataMap(bwIm,abs(data));
colormap(flipud(brewermap([],clrMap)))
cbar= colorbar;
caxis([0 180])

ylabel(cbar,'Orientation with Respect to Utricular Boundary');
title('Support Cell Orientation')

%% Support Cell Orientation
data = CellProps.NormOrientation(CellProps.Type=='S');
bwIm = ImDat.SupportCellMask;

[datmap,fH,axH] = DataMap(bwIm,abs(data),'Disk',70);
colormap(flipud(brewermap([],clrMap)))
cbar= colorbar;
caxis([0 180])

ylabel(cbar,'Orientation with Respect to Utricular Boundary');
title('Support Cell Orientation Blurred')
end

