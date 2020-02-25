function [CellProps] = OrientHairCell_Fonticulus(CellProps)

SepCells = CellProps.CellImRed;
SepMask = CellProps.CellMask;
SepEllipse = CellProps.CellMaskEllipse;
nHair = length(SepMask); 

for k = 1:nHair
curIm = SepCells{k};
curMask = uint8(SepMask{k});
curEllipse = uint8(SepEllipse{k});
MaskArea = sum(sum(curMask));
[ydim(k) xdim(k)] = size(curIm);

conIm{k} = imadjust(curIm,[0.1 1]).*curEllipse;
blurIm{k} = imadjust(medfilt2(conIm{k})).*curEllipse;
flatIm{k} = imadjust(medfilt2(imflatfield(blurIm{k},2))).*curEllipse;
erodeIm1{k} = imadjust(imerode(flatIm{k},strel('disk',2)));
invertIm{k} = imadjust(imcomplement(erodeIm1{k}).*curEllipse);
erodeIm2{k} = imadjust(invertIm{k}.*imerode(curEllipse,strel('disk',4)));
bwIm{k} = imbinarize(localcontrast(erodeIm2{k}),0.80);

% Filter by region properties
% Filtering by eccentricity will reduce the options to only the most
% circular regions.
morFilt1{k} = bwpropfilt(bwIm{k},'Area',[5 1000]); % Remove single pixel noise.
% Size-based area filtration.
morFilt2{k} = bwpropfilt(morFilt1{k},'Area',[0.01 0.15].*MaskArea);
morFilt3{k} = bwpropfilt(morFilt2{k},'Solidity',[0.7 1]);
morFilt4{k} = bwpropfilt(morFilt3{k},'Area',1,'Largest');

overlay{k} = imoverlay(curIm,morFilt4{k},'r');

end

CellProps = BBOrient(CellProps,morFilt4,'F');

end
