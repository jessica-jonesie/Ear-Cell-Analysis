function [CellProps,ImDat] = SelectHairCellAlt(RAW,EllipticalApproximation)
%SELECTHAIRCELL Summary of this function goes here
%   Detailed explanation goes here
Contrasted = localcontrast(RAW);

% Next separate the channels
imR = Contrasted(:,:,1);
imG = Contrasted(:,:,2);
imB = Contrasted(:,:,3);

%% 
% To segment the hair cells we will use the blue channel. The next step is 
% to apply a filter to reduce noise. We will compare a gaussian filter and a median 
% filter.
imMedian = medfilt2(imB,5.*[1 1]);

%% 
% Notice how the illumination of each hair cell is different. To correct 
% this the median filtered image was flat fielded. This requires blurring the 
% image then subtracting the blurred image from the original. 
imFlat = imflatfield(imMedian,30);

%% 
% Of these flat-fielded images, the one that used sigma=100 gave the best 
% balance between leveling the illumination and preserving shape. If we apply 
% local contrasting again, the 
imFlatCon = localcontrast(imFlat,0.9,0.9);

%% 
% Finally the image can be adaptively thresholded to obtain a binary mask 
% indicating the position of hair cells. 
imBW = imbinarize(imFlatCon,0.4);


%% Watershed? (Connect the edges)
[imShed] = imWatershed(~imBW); % Connect the lines
imShedinv = ~imShed; % invert
NoHoles = imfill(imShedinv,'holes'); % fill holes
imSkel = bwmorph(~NoHoles,'thin',inf); % skeltonize

%% 
% Next we will apply a small binary close to solidify the cells followed 
% by a larger binary open to remove small pixel noise. Finally, a small dilation 
% will be applied to make sure that the selection includes the entire hair cells. 

% Close and invert
imClose = ~imclose(imSkel,strel('disk',3));
imErode = imerode(imClose,strel('disk',1));
% imOpen = imopen(imClose,strel('disk',8));
% imDil = imdilate(imOpen,strel('disk',2));

% Omit Boundary Features from further analysis
imBndOut= imclearborder(imErode);
%% Get Morphologys
CellProps = bwcompprops(imBndOut);

% CellProps.ConvexArea = cell2mat(struct2cell(regionprops(imBndOut,'ConvexArea')))';
CellProps.Circularity = (4*pi*CellProps.Area)./(CellProps.Perimeter.^2);
%% Add a few additional descriptors to the CellProps table
imDil = imBndOut;

nHair = length(CellProps.Area);
CellProps.ID = (1:nHair)';
CellProps.AvgIntensityR = cell2mat(struct2cell(regionprops(imDil,imR,'MeanIntensity')))';
CellProps.AvgIntensityG = cell2mat(struct2cell(regionprops(imDil,imG,'MeanIntensity')))';
CellProps.AvgIntensityB = cell2mat(struct2cell(regionprops(imDil,imB,'MeanIntensity')))';

%% Refine the set based on circularity
% Remove cells that have an average intensity less than some predefined
% threshold.

pixIDs = CellProps.PixelIdxList;
% omittedCells = CellProps.ID(CellProps.AvgIntensityR<20);
NotCircular = CellProps.ID(CellProps.Circularity<0.85 | CellProps.Circularity>1.05);
NotSolid = CellProps.ID(CellProps.Solidity<0.95);
TooSmall = CellProps.ID(CellProps.Area<400);
omittedCells = unique([NotCircular; NotSolid;TooSmall]);
% omittedCells = NotCircular
omittedPixels = cell2mat(pixIDs(omittedCells));
imDil(omittedPixels(:)) = 0;
CellProps(omittedCells,:) = [];
nHair = length(CellProps.Area);
CellProps.ID = (1:nHair)';

if EllipticalApproximation==true
    [imEllipse,EllipseMasks] = bwEllipse(size(imDil),CellProps.Centroid,CellProps.MajorAxisLength,CellProps.MinorAxisLength,CellProps.Orientation);
else
    imEllipse = imDil;
end

% Isolate the cells
[LabMask,~] = bwlabel(imDil);
[LabEllipse,~] = bwlabel(imEllipse);

% Store Data
ImDat.RAW = RAW;
ImDat.Red = imR;
ImDat.Blue = imB;
ImDat.Green = imG;
ImDat.HairCellMask = imDil;
ImDat.HairCellEllipseMask = imEllipse;
ImDat.HairCellLabels = LabMask;
ImDat.HairCellEllipseLabels = LabEllipse;

CellProps.Properties.VariableNames{6} = 'EllipseOrientation';

CellProps.Type = repmat('H',[nHair 1]);

[CroppedIms,CellMasks] = Crop2Mask(RAW,EllipseMasks);
CellProps.CellIm = CroppedIms';
CellProps.CellMaskEllipse = CellMasks';
CellProps.CellImRed = Crop2Mask(imR,EllipseMasks)';
CellProps.CellImGreen = Crop2Mask(imG,EllipseMasks)';
CellProps.CellImBlue = Crop2Mask(imB,EllipseMasks)';



% CellProps.CellIm = labelSeparate(RAW,LabEllipse,'mask')';
% CellProps.CellImRed = labelSeparate(imR,LabEllipse,'mask')';
% CellProps.CellImGreen = labelSeparate(imG,LabEllipse,'mask')';
% CellProps.CellImBlue = labelSeparate(imB,LabEllipse,'mask')';
% CellProps.CellMaskEllipse = labelSeparate(imEllipse,LabEllipse,'mask')';


if EllipticalApproximation==true
    CellProps.CellMask = CellProps.CellMaskEllipse;
else
    CellProps.CellMask = labelSeparate(imDil,LabMask,'mask')';
end

end

