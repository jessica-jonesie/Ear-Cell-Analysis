addpath('Sourced Functions')
%%
RAW = imread('GammaTub_02_merge_cropped.png');
HCells = ~imread('GammaTub_02_merge_cropped_HairCells.bmp');
Bounds = imread('GammaTub_02_merge_cropped_Bounds_Skel.bmp');
NotCells = ~imread('GammaTub_02_merge_cropped_NotCells.bmp');
BasalBodies = ~imread('GammaTub_02_merge_cropped_BB.bmp');

[imx,imy] = size(HCells);

SupportCells = true(imx,imy)-HCells-NotCells;

%% Refine Cell Selections
sdisk = strel('disk',1);
Bounds = imdilate(Bounds,sdisk);
HCells = HCells-Bounds;
SupportCells = SupportCells-Bounds;

Bounds(Bounds<0) = 0;
HCells(HCells<0) = 0;
SupportCells(SupportCells<0) = 0;

Bounds = logical(Bounds);
HCells = imclearborder(logical(HCells));
SupportCells = imclearborder(logical(SupportCells));

%% Extract Cell params
[HairCellProps,ImDat] = GetPropsAndIms(BasalBodies,HCells);
[HairCellProps] = BBOrient(HairCellProps,HairCellProps.Im,'BB');
HairCellProps.Type = repmat('H',[height(HairCellProps) 1]);
[SupportCellProps,ImDat] = GetPropsAndIms(BasalBodies,SupportCells);
[SupportCellProps] = BBOrient(SupportCellProps,SupportCellProps.Im,'BB');
SupportCellProps.Type = repmat('S',[height(SupportCellProps) 1]);
%%Merge
CellProps = [HairCellProps; SupportCellProps];
CellProps.NormOrientation = CellProps.BBOrientation;
CellProps.CombinedPolarity = CellProps.BBPolarity;

CellProps(isnan(CellProps.BBOrientation),:)=[];
CellProps.DblAngOrientation = DblAngTransform(CellProps.NormOrientation,'deg');

%% Plot Some things
PolAndOriHistograms(CellProps,'Full')

RayPValue_Combo = RayleighTest(CellProps.DblAngOrientation);
RayPValue_Support = RayleighTest(CellProps.DblAngOrientation(CellProps.Type=='S'));
RayPValue_Hair = RayleighTest(CellProps.DblAngOrientation(CellProps.Type=='H'));

[W,MWWSigLvl_SupportVHair] = MWWUniformScores(CellProps.DblAngOrientation(CellProps.Type=='H'),CellProps.DblAngOrientation(CellProps.Type=='S'));

%% Gamma Tubulin versus pericentrin.
% GammaTub = 

% imB = raw(:,:,3);
% imBR = raw;
% imBR(:,:,2) = 0 ;
% imBR = rgb2gray(imBR);
% imGray = rgb2gray(raw);

%%
% imshow(labeloverlay(imB,SupportCells))
