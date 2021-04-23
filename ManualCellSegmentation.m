addpath('Sourced Functions')
%%

% Gamma Tubulin
% RAW = imread('GammaTub_02_merge_cropped.png');
% HairCells = ~imread('GammaTub_02_merge_cropped_HairCells.bmp');
% CellBounds = imread('GammaTub_02_merge_cropped_Bounds_Skel.bmp');
% NotCells = ~imread('GammaTub_02_merge_cropped_NotCells.bmp');
% BasalBodies = ~imread('GammaTub_02_merge_cropped_BB.bmp');

% Pericentrin Labeled
% RAW = imread('GammaTub_02_merge_cropped.png');
% HCells = ~imread('GammaTub_02_merge_cropped_HairCells.bmp');
% Bounds = imread('GammaTub_02_merge_cropped_Bounds_Skel.bmp');
% NotCells = ~imread('GammaTub_02_merge_cropped_NotCells.bmp');
% BasalBodies = ~imread('GammaTub_02_merge_cropped_BB.bmp');



% SupportCells = true(imx,imy)-HairCells-NotCells;

%% New section
root = 'GammaTub_02';
HairCells = imread(strcat(root,'_HairCells.bmp'));
SupportCells = imread(strcat(root,'_SupportCells.bmp'));
CellBounds = imread(strcat(root,'_CellBoundaries.bmp'));
PolarBodies = imread(strcat(root,'_PolarBodies.bmp'));
[imx,imy] = size(HairCells);
%% Refine Cell Selections
sdisk = strel('disk',1);
CellBounds = imdilate(CellBounds,sdisk);
HairCells = HairCells-CellBounds;
SupportCells = SupportCells-CellBounds;

CellBounds(CellBounds<0) = 0;
HairCells(HairCells<0) = 0;
SupportCells(SupportCells<0) = 0;

CellBounds = logical(CellBounds);
HairCells = imclearborder(logical(HairCells));
SupportCells = imclearborder(logical(SupportCells));

%% Extract Cell params
[HairCellProps,ImDat] = GetPropsAndIms(PolarBodies,HairCells);
[HairCellProps] = BBOrient(HairCellProps,HairCellProps.Im,'BB');
HairCellProps.Type = repmat('H',[height(HairCellProps) 1]);
[SupportCellProps,ImDat] = GetPropsAndIms(PolarBodies,SupportCells);
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
