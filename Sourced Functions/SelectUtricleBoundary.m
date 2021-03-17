function [CellProps,BoundPts,imClose] = SelectUtricleBoundary(RAW,CellProps,varargin)
%SELECTUTRICLEBOUNDARY finds the boundary of the Utricle. 
%   [CellProps,BoundPts] = SELECTUTRICLEBOUNDARY(RAW,CellProps) compute the
%   utricular boundary given a RAW full color image and a table of Cell
%   properties. Compute the boundary points and reference angle for the
%   cells who's centroids are stored in cell points and append them to the 
%   CellProps Table.
%
%   [CellProps,BoundPts] =
%   SELECTUTRICLEBOUNDARY(RAW,CELLPROPS,'Smooth',fraction) sample a
%   fraction of the boundary points computed by SELECTUTRICLEBOUNDARY and
%   use these to compute the reference angles.
%
%   SELECTUTRICLEBOUNDARY(RAW,CellProps,'CloseFactor',factor) multiply the
%   size of the closing kernel by factor. The greater this factor the
%   smoother the utricular boundary will be. 

%% parse inputs
p = inputParser;

addRequired(p,'RAW');
addRequired(p,'CellProps');

addParameter(p,'Smooth',0,@isnumeric);
addParameter(p,'CloseFactor',1,@isnumeric);

parse(p,RAW,CellProps,varargin{:})

smooth = p.Results.Smooth;
CloseFactor = p.Results.CloseFactor;
%%
% contrast
Contrasted = localcontrast(RAW);

% Convert to grayscale
Gray = rgb2gray(Contrasted);

% Even illumination;
imFlat = imadjust(imflatfield(Gray,1));

% Blur
imMedian = imadjust(medfilt2(imFlat,100.*[1 1],'symmetric'));

% Blur Again to smooth boundary
imGauss = imadjust(imgaussfilt(imFlat,60));

% Threshold
imThresh = imGauss>=200;

% Fill small holes
imClose = imclose(imThresh,strel('disk',CloseFactor*round(numel(RAW)/2e4)));

% Convert to single pixel boundary;
imBound = bwmorph(imClose,'remove');

% Delete boundary pixels
imBound(:,1) = 0;
imBound(1,:) = 0;
imBound(:,end) = 0;
imBound(end,:) = 0;

% convert pixel boundary to points
BoundPts = pix2pts(imBound);

npts = length(BoundPts);
if smooth>0
    mpts = floor(npts.*smooth); 
    sampInd = datasample(1:npts,mpts,'Replace',false);
   end

%% Display Results
[~,CellProps.RefAngle] = pt2ptInfluence(CellProps.Centroid,BoundPts,'inverse',2);


CellProps.PixID = pts2pix(fliplr(CellProps.Centroid),size(imClose));
CellProps.InBound = imClose(CellProps.PixID);

CellProps.RefAngle(~CellProps.InBound)= CellProps.RefAngle(~CellProps.InBound)+180;
% unitX = cosd(refAngle);
% unitY = sind(refAngle);
% 
% quiver(CellProps.Centroid(:,1),CellProps.Centroid(:,2),unitX,unitY,0.3,'Color','w')
% 
% % Define a vector field for orientation
% cellX = cosd(CellProps.GlobalOrientation);
% cellY = sind(CellProps.GlobalOrientation);
% 
% quiver(CellProps.Centroid(:,1),CellProps.Centroid(:,2),cellX,cellY,0.3,'Color','m')
end