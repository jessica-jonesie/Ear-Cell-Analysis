function [] = OrientationVectorOverlay(CellProps,BoundPts,ImDat,Scaling)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
figure
imshow(ImDat.RAW);
hold on
plot(BoundPts(:,1),BoundPts(:,2),'.w')

% Define a vector field for orientation
cellX = cosd(CellProps.CombinedOrientation);
cellY = sind(CellProps.CombinedOrientation);
if strcmp(Scaling,'Unit')
    scale = 0.4;
elseif strcmp(Scaling,'Polarity')
    cellX = CellProps.CombinedPolarity.*cellX;
    cellY = CellProps.CombinedPolarity.*cellY;
    scale = 0.7;
else
    error('Invalid Scaling type selected')
end

HairCellCentroids = CellProps.Centroid(CellProps.Type=='H',:);
SupportCellCentroids = CellProps.Centroid(CellProps.Type=='S',:);

quiver(HairCellCentroids(:,1),HairCellCentroids(:,2),cellX(CellProps.Type=='H'),cellY(CellProps.Type=='H'),scale,'Color','r','LineWidth',1.5)
quiver(SupportCellCentroids(:,1),SupportCellCentroids(:,2),cellX(CellProps.Type=='S'),cellY(CellProps.Type=='S'),scale,'Color','c','LineWidth',1.5)
end

