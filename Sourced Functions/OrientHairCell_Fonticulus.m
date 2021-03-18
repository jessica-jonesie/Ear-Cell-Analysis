function [CellProps] = OrientHairCell_Fonticulus(CellProps)

SepCells = CellProps.CellImRed;
SepMask = CellProps.CellMask;
SepEllipse = CellProps.CellMaskEllipse;
nHair = length(SepMask); 

morFilt4 = cell(1,nHair);

for k = 1:nHair
curIm = SepCells{k};
curMask = uint8(SepMask{k});
curEllipse = uint8(SepEllipse{k});
MaskArea = sum(sum(curMask));
% [ydim(k) xdim(k)] = size(curIm);

imK{1}=curIm;

conIm = imadjust(curIm,[0.1 1]).*curEllipse;
blurIm = imadjust(medfilt2(conIm)).*curEllipse;
flatIm = imadjust(medfilt2(imflatfield(blurIm,2))).*curEllipse;
erodeIm1 = imadjust(imerode(flatIm,strel('disk',2)));
invertIm = imadjust(imcomplement(erodeIm1).*curEllipse);
erodeIm2 = imadjust(invertIm.*imerode(curEllipse,strel('disk',4)));
bwIm = imbinarize(localcontrast(erodeIm2),0.80);

imK{2}=conIm;
imK{3}=blurIm;
imK{4}=flatIm;
imK{5}=erodeIm1;
imK{6}=invertIm;
imK{7}=erodeIm2;
imK{8} = bwIm;

% Filter by region properties
% Filtering by eccentricity will reduce the options to only the most
% circular regions.
morFilt1 = bwpropfilt(bwIm,'Area',[5 1000]); % Remove single pixel noise.
% Size-based area filtration.
morFilt2 = bwpropfilt(morFilt1,'Area',[0.01 0.15].*MaskArea);
morFilt3 = bwpropfilt(morFilt2,'Solidity',[0.7 1]);
morFilt4{k} = bwpropfilt(morFilt3,'Area',1,'Largest');

imK{9} = morFilt1;
imK{10}=morFilt2;
imK{11}=morFilt3;
imK{12}=morFilt4{k};

% montage(imK)

% overlay{k} = imoverlay(curIm,morFilt4{k},'r');

end

CellProps = BBOrient(CellProps,morFilt4,'F');

end
