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

DistType ={'E','E','E','T'}; % Is the distribution empirical or theoretical.
[KSResults] = KSStruct(x,CDF,DistType);
