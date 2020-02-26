function [CellProps,ImDat] = SelectSupportCell(RAW,ImDat)
imB = localcontrast(RAW(:,:,3)); % Blue Channel contrasted;
imG = localcontrast(RAW(:,:,2)); % Green Channel contrasted;
imR = localcontrast(RAW(:,:,1)); % Red Channel contrasted;


[width,height,depth] = size(RAW);
HairCellMask = ImDat.HairCellMask;
% Subtract Hair Cells
subHCells = uint8(double(imG).*double(~HairCellMask));

% Remove Stereociliary bundles. These bundles are brighter than anything 
% else in the image. 
imThresh = subHCells;
imThresh(imThresh>50) = 0;
imThresh = imadjust(imThresh);

% Correct Background
imMedian = medfilt2(imThresh,5.*[1 1]);
imFlat = localcontrast(imflatfield(imMedian,20),1.0,0.5);

% Refine edges
imBW = imbinarize(imFlat,0.3);
imOpen = imerode(imBW,strel('disk',1));

% Invert
imInvert = ~imOpen;

%% Watershedding
D = -bwdist(~imInvert);
mask = imextendedmin(D,2);
D2 = imimposemin(D,mask);
Ld2 = watershed(D2);

imShed = imInvert;
imShed(Ld2==0) = 0;
imShed = ~imShed;

% Erode and make uniform boundaries;
imSkel = bwmorph(imShed,'thin',inf);
imBounds = bwareaopen(imdilate(imSkel,strel('disk',1)),200);

%% Refine with morphological thresholding
imReg = ~imBounds;
sizeRef = bwpropfilt(imReg,'Area',[100 1000]);

% Reapply hair cell removal
imRegHRem = imdilate(bwmorph(HairCellMask,'thin',inf),strel('disk',1));
addHoles2Hair = logical(sizeRef.*~imRegHRem);
typeRef = bwpropfilt(addHoles2Hair,'EulerNumber',[1 1]);


%% Compute properties of Cells
CellProps = bwcompprops(typeRef);

% Expand Ellipses slightly.
expansionFactor = 1.0;
CellProps.MajorAxisLength = CellProps.MajorAxisLength.*expansionFactor;
CellProps.MinorAxisLength = CellProps.MinorAxisLength.*expansionFactor;



%% Save
[CellIms,MaskIms] = EllipseCrop(RAW,CellProps);
nCells = length(CellProps.Area);
CellProps.ID = (1:nCells)';
CellProps.AvgIntensityR = cell2mat(struct2cell(regionprops(typeRef,imR,'MeanIntensity')))';
CellProps.AvgIntensityG = cell2mat(struct2cell(regionprops(typeRef,imG,'MeanIntensity')))';
CellProps.AvgIntensityB = cell2mat(struct2cell(regionprops(typeRef,imB,'MeanIntensity')))';

CellProps.Properties.VariableNames{6} = 'EllipseOrientation';

CellProps.Type = repmat('S',[nCells 1]);
CellProps.CellIm = CellIms';

for n = 1:nCells
    CellImRed{n} = CellProps.CellIm{n}(:,:,1);
    CellImGreen{n} = CellProps.CellIm{n}(:,:,2);
    CellImBlue{n} = CellProps.CellIm{n}(:,:,3);
end

CellProps.CellImRed = CellImRed';
CellProps.CellImGreen = CellImGreen';
CellProps.CellImBlue = CellImBlue';

CellProps.CellMaskEllipse = MaskIms';

CellProps.CellMask = labelSeparate(true(width,height),bwlabel(typeRef),'mask')';
ImDat.SupportCellMask = typeRef;
end
