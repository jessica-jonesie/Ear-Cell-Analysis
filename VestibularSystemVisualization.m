clc; clear; close all;

addpath('Source Images')
addpath('Sourced Functions')
addpath('Data')
addpath('Results')

clrMap = 'RdYlBu';

[file,path] = uigetfile('*.mat');
load(fullfile(path,file));

nanrows = isnan(CellProps.CombinedOrientation);
CellProps(nanrows,:)=[];
%% Display Results
PolAndOriHistograms(CellProps,'Full')
PolarityWeightedOrientationHist(CellProps);
CellSelectionOverlay(ImDat)

OrientationVectorOverlay(CellProps,BoundPts,ImDat,'Scaling','BB','ScaleValue',0);

[CDF,x] = CDFPlot(CellProps,'Orientation','xy','none');

% OrientationMaps(CellProps,ImDat,clrMap);
% PolarityMaps(CellProps,ImDat,clrMap);

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
hold on 
plot(BoundPts(:,1),BoundPts(:,2),'.r');



%% Angle K
HID = CellProps.Type=='H';
SID = CellProps.Type=='S';

% Vector fields with normalized Orientation
figure
imshow(ImDat.RAW)
hold on
quiver(CellProps.Centroid(HID,1),CellProps.Centroid(HID,2),cosd(CellProps.NormOrientation(HID)),sind(CellProps.NormOrientation(HID)),0.5,'Color','r')
quiver(CellProps.Centroid(SID,1),CellProps.Centroid(SID,2),cosd(CellProps.NormOrientation(SID)),sind(CellProps.NormOrientation(SID)),0.5,'Color','c')
hold off
axis ij
axis tight

mindim = min(size(ImDat.Red));
scales = linspace(0,mindim/2,21);
scales(1) = [];

hvec.origin = CellProps.Centroid(HID,:);
hvec.angle = CellProps.NormOrientation(HID)*pi/180;
hvec.magnitude = ones(sum(HID),1);

svec.origin = CellProps.Centroid(SID,:);
svec.angle = CellProps.NormOrientation(SID)*pi/180;
svec.magnitude = ones(sum(SID),1);

% Compute AngleK stats 
Khh = AngleK(scales,hvec); % hair to hair
Kss = AngleK(scales,svec); % support to support
Khs = AngleK(scales,hvec,svec); % Hair to support
Ksh = AngleK(scales,svec,hvec); % support to hair.


figure
subplot(2,2,1)
plot(scales,Khh)
xlabel('Scale (pixels)');
ylabel('Population Alignment')
title('Hair Cell to Hair Cell')
ylim([-1,1])

subplot(2,2,2)
plot(scales,Kss)
xlabel('Scale (pixels)');
ylabel('Population Alignment')
title('Support Cell to Support Cell')
ylim([-1,1])

subplot(2,2,3)
plot(scales,Khs)
xlabel('Scale (pixels)');
ylabel('Population Alignment')
title('Hair Cell to Support Cell')
ylim([-1,1])

subplot(2,2,4)
plot(scales,Khs)
xlabel('Scale (pixels)');
ylabel('Population Alignment')
title('Support Cell to Hair Cell')
ylim([-1,1])

