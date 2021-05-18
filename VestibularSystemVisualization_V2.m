clc; clear; close all;

addpath('Source Images')
addpath('Sourced Functions')
addpath('Data')
addpath('Results')

[file,path] = uigetfile('*.mat');
load(fullfile(path,file));

HID = CellProps.Type=='Hair';
SID = CellProps.Type=='Support';

[TypeID,ntypes,types] = GetTypeIDs(CellProps,'Type');

% Add Orientations in Radians
CellProps.OrientationR = wrapTo360(CellProps.Orientation)*pi/180;
CellProps.NormOrientationR = wrapTo360(CellProps.NormOrientation)*pi/180;
%% Define various colormaps and other display parameters
OrientColMap = flipud(cbrewer('div','RdYlBu',64));
PolarMap = cbrewer('seq','YlOrRd',64);
haircolor = hex2rgb('#e66101');
supportcolor = hex2rgb('#5e3c99');

TypeMap = MyBrewerMap('div','Spectral',ntypes);
%% Preview Segmentation and orientation analysis. 
figure
CellSelectionOverlay(ImDat,TypeMap);

figure
VectorOverlayMap(ImDat,CellProps,'Type','splitcolors',TypeMap)

%% Montage Preview
% This takes awhile so save it the first time and never do it again.
% Usually this is taken care of in the Vestibular System Analysis.
figure
if ~any(strcmp('AnnotIm',CellProps.Properties.VariableNames))
    CellProps = AnnotIndIms(CellProps);
    save(fullfile(path,file),'CellProps','-append');
end

for k=1:ntypes
    figure
    montage(CellProps.AnnotIm(TypeID{k}))
    title(types{k})
end

%% Histograms
% Normalized Orientation Histograms
figure
[ha] = HistArray(CellProps,'NormOrientationR','Type',...
    'histtype','polar','splitcolors',TypeMap);

% Polarity Histograms
figure
[hb] = HistArray(CellProps,'Polarity','Type','splitcolors',TypeMap,...
    'fixmax',true,'xlabel','Polarity');

%% Model Cell Visualization
figure
[hc] = ModelCellArray(CellProps,'Type');
% [ha] = ModelCellArray(CellProps,'Type','fixmax',true);

%% Orientation Map and Polarity Map
% Orientation Map
CellProps.NormOrientation180 = flipTo180(CellProps.NormOrientation);
DataMapArray(ImDat,CellProps,'NormOrientation180','Type','cmap',OrientColMap,'varlims',[0 180])

% Polarity Map
DataMapArray(ImDat,CellProps,'Polarity','Type','cmap',PolarMap,'varlims',[0 1])

%% Angle K
mindim = min(size(ImDat.HairCellMask));
scales = linspace(0,mindim/2,21)';
scales(1) = [];
if ~exist('AngK','var')
    [AngK.Obs,AngK.Ori,AngK.simMax,AngK.simMin,AngK.name] = AngleKTypeComp(scales,CellProps,'Type');
    AngK.scales = scales;
    save(fullfile(path,file),'AngK','-append');
end

figure
angkmap = MyBrewerMap('qual','Set1',ntypes.^2);
hd = tight_subplot(ntypes,ntypes,0.1,0.1,0.1);
for k=1:(ntypes^2)
    axes(hd(k));
    plot(AngK.scales,AngK.Obs{k},'Color',angkmap(k,:));
    hold on 
    plot(AngK.scales,AngK.simMax{k},'Color',angkmap(k,:),'LineStyle','--');
    plot(AngK.scales,AngK.simMin{k},'Color',angkmap(k,:),'LineStyle','--');
    xlabel('Scale')
    ylabel('Population Alignment')
    title(AngK.name{k})
    ylim([-1 1])
end

