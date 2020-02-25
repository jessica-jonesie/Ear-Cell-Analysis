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

% Komogorov Smirnov - Tests the null hypothesis that two populations are
% drawn from the same distribution aka. tests whether two distributions are
% the same/similar. Note KS is not necessarily appropriate for circular
% statistics.
DistType ={'E','E','E','T'}; % Is the distribution empirical or theoretical.
[KSResults] = KSStruct(x,CDF,DistType);

% Rayleigh Test for Uniformity. Tests the null hypothesis that the input
% distribution is uniform.
RayPValue_Combo = RayleighTest(CellProps.NormOrientation);
RayPValue_Support = RayleighTest(CellProps.NormOrientation(CellProps.Type=='S'));
RayPValue_Hair = RayleighTest(CellProps.NormOrientation(CellProps.Type=='H'));
