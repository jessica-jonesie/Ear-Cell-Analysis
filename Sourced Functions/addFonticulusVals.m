function [CellProps] = addFonticulusVals(CellProps)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

nCells = length(CellProps.Area);
CellProps.FDetected = zeros(nCells,1);
CellProps.FArea = NaN(nCells,1);
CellProps.FLocalCentroid = NaN(nCells,2);
CellProps.FX = NaN(nCells,1);
CellProps.FY = NaN(nCells,1);
CellProps.FCentroid = NaN(nCells,2);
CellProps.FOrientation = NaN(nCells,1);
CellProps.FDistance = NaN(nCells,1);
CellProps.FEdgeDist = NaN(nCells,1);
CellProps.FPolarity = NaN(nCells,1);

end

