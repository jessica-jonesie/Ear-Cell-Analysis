clc; clear; close all;

addpath('Source Images')
addpath('Sourced Functions')
addpath('Data')
addpath('Results')

clrMap = 'RdYlBu';

[file,path] = uigetfile('*.mat');
load(fullfile(path,file));

%% Display Results
PolAndOriHistograms(CellProps,'Full')
PolarityWeightedOrientationHist(CellProps);
CellSelectionOverlay(ImDat)

OrientationVectorOverlay(CellProps,BoundPts,ImDat,'Unit')

[CDF,x] = CDFPlot(CellProps,'Orientation','xy','none');

OrientationMaps(CellProps,ImDat,clrMap);
PolarityMaps(CellProps,ImDat,clrMap);

%% Statistics
[combinedX,intCDFs] = InterpCDFs(x,CDF);
interpCDFPlot(combinedX,intCDFs,'polar');

% Kolmogorov Smirnov - Tests the null hypothesis that two populations are
% drawn from the same distribution aka. tests whether two distributions are
% the same/similar. Note KS is not necessarily appropriate for circular
% statistics.
DistType ={'E','E','E','T'}; % Is the distribution empirical or theoretical.
[KSResults] = KSStruct(x,CDF,DistType);

% For circular statistics note that the diametrically bimodal orientation
% measurements must be first transformed using the double angle
% transformation.
CellProps.DblAngOrientation = DblAngTransform(CellProps.NormOrientation,'deg');

figure
DblAngPlot(CellProps.NormOrientation,'deg',36)

AngsCombo = CellProps.DblAngOrientation;
AngsHair = CellProps.DblAngOrientation(CellProps.Type=='Hair');
AngsSupport = CellProps.DblAngOrientation(CellProps.Type=='Support');
% Rayleigh Test for Uniformity. Tests the null hypothesis that the input
% distribution is uniform.
RayPValue_Combo = RayleighTest(AngsCombo);
RayPValue_Support = RayleighTest(AngsSupport);
RayPValue_Hair = RayleighTest(AngsHair);


% Mardia-Watson-Wheel Uniform-Scores Test
% This procedure tests whether two distributions (including circular
% distributions) are equal. 
[W,MWWSigLvl_SupportVHair] = MWWUniformScores(AngsHair,AngsSupport);

%% Overlay reference angles
figure
imshow(ImDat.RAW)
hold on
quiver(CellProps.Centroid(:,1),CellProps.Centroid(:,2),cosd(CellProps.RefAngle),sind(CellProps.RefAngle),0.5,'Color','w')
