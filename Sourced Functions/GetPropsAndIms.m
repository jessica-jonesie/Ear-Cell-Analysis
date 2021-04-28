function [Props,ImDat] = GetPropsAndIms(Image,Mask,varargin)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%% parse
p = inputParser;
addRequired(p,'Image');
addRequired(p,'Mask');
checkCtrType = @(x) any(validatestring(x,{'Centroid','Visual'}));
addParameter(p,'CenterType','Centroid',checkCtrType);

parse(p,Image,Mask,varargin{:});
CenterType = p.Results.CenterType;
%%
if length(size(Image))==3
    imR = Image(:,:,1);
    imG = Image(:,:,2);
    imB = Image(:,:,3);
elseif length(size(Image))==2
    imR = Image;
    imG = Image;
    imB = Image;
end

Props = bwcompprops(Mask);

if strcmp(CenterType,'Visual')
    Props.Centroid = BWVisualCenter(Mask);
end


Props.Circularity = (4*pi*Props.Area)./(Props.Perimeter.^2);
nImages = length(Props.Area);
Props.ID = (1:nImages)';
Props.PixIDs = struct2cell(regionprops(Mask,'PixelIdxList'))';


[imEllipse,EllipseMasks] = bwEllipse(size(Mask),Props.Centroid,Props.MajorAxisLength,Props.MinorAxisLength,Props.Orientation);


% Isolate the cells
[LabMask,~] = bwlabel(Mask);
[LabEllipse,~] = bwlabel(imEllipse);

% Store Data
ImDat.RAW = Image;
ImDat.Red = imR;
ImDat.Blue = imB;
ImDat.Green = imG;
ImDat.Mask = Mask;
ImDat.EllipseMask = imEllipse;
ImDat.Labels = LabMask;
ImDat.EllipseLabels = LabEllipse;

Props.Properties.VariableNames{6} = 'EllipseOrientation';

% Props.Type = repmat('H',[nImages 1]);

[CroppedIms,CroppedMasks] = Crop2Mask(Image,EllipseMasks);
Props.Im = CroppedIms';
Props.MaskEllipse = CroppedMasks';
Props.ImRed = Crop2Mask(imR,EllipseMasks)';
Props.ImGreen = Crop2Mask(imG,EllipseMasks)';
Props.ImBlue = Crop2Mask(imB,EllipseMasks)';
end

