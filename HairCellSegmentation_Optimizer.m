RAW = imread('Data\RAW.png');
Manual = ~imread('Data\RAW_HairCells.bmp');
Manual = imclearborder(Manual);

[~,ImDat] = SelectHairCell(RAW);
Auto = ImDat.HairCellMask;