function [CellProps,BoundPts] = SelectUtricleBoundary(RAW,CellProps,varargin)

%% parse inputs
p = inputParser;

addRequired(p,'RAW');
addRequired(p,'CellProps');

addParameter(p,'Smooth',0,@isnumeric);

parse(p,RAW,CellProps,varargin{:})

smooth = p.Results.Smooth;
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
imClose = imclose(imThresh,strel('disk',round(numel(RAW)/2e4)));

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
    FracRetain = 1-smooth;
    mpts = floor(npts.*FracRetain); 
end

%% Display Results
[~,CellProps.RefAngle] = pt2ptInfluence(CellProps.Centroid,BoundPts,'inverse',2);

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