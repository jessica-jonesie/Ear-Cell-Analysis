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

%% Histograms
% Normalized Orientation Histograms
figure
[ha] = HistArray(CellProps,'NormOrientationR','Type',...
    'histtype','polar','splitcolors',TypeMap);

% Polarity Histograms
figure
[hb] = HistArray(CellProps,'Polarity','Type','splitcolors',TypeMap,...
    'fixmax',true);

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

%% Montage Preview
% This takes awhile so save it the first time and never do it again.
if ~any(strcmp('AnnotIm',CellProps.Properties.VariableNames))
    CellProps = AnnotIndIms(CellProps);
    save(fullfile(path,file),'CellProps');
end

for k=1:ntypes
    figure
    montage(CellProps.AnnotIm(TypeID{k}))
    title(types{k})
end

%% Angle K
mindim = min(size(ImDat.HairCellMask));
scales = linspace(0,mindim/2,21)';
scales(1) = [];
[K,Ori,KsimMax,KsimMin,name] = AngleKTypeComp(scales,CellProps,'Type');

figure
angkmap = MyBrewerMap('qual','Set1',ntypes.^2);
hd = tight_subplot(ntypes,ntypes,0.1,0.1,0.1);
for k=1:(ntypes^2)
    axes(hd(k));
    plot(scales,K{k},'Color',angkmap(k,:));
    hold on 
    plot(scales,KsimMax{k},'Color',angkmap(k,:));
    plot(scales,KsimMin{k},'Color',angkmap(k,:));
    xlabel('Scale')
    ylabel('Population Alignment')
    ylim([-1 1])
end

% AngleKTypeComp(scales,CellProps,'Type');
% 
% 
% 
% 
% hvec.origin = CellProps.Center(HID,:);
% hvec.angle = CellProps.NormOrientationR(HID);
% hvec.magnitude = ones(sum(HID),1);
% 
% % Compute AngleK stats 
% alpha = 0.01;
% [Khh,Orihh] = AngleK(scales,hvec); % hair to hair
% [~,KhhMax,KhhMin] = AngleK_Env(scales,hvec,alpha);