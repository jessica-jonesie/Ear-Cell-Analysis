clc;clear;close all;
% Add the directories that this code needs to access.
addpath('Source Images')
addpath('Sourced Functions')
addpath('Data')
addpath('Results')

%% Analysis parameters
Approach = 'Manual';

%% Select Image
% Select RAW Image
[file,path] = uigetfile('*.png');
root = extractBefore(file,'RAW.png');

% Read in the image to be analyzed
ImDat.RAW = imread(fullfile(path,file));

% Get image size
[imx,imy,imz] = size(ImDat.RAW);

%% Select Analysis Region
% This should allow the user to select a region, then mask the RAW image.
% It should then crop the image down to the masked region. This will
% improve computational time. 

%%%% PLACEHOLDER %%%%

%% Get cell masks (segment or read)
switch Approach
    case 'Manual'
        % For manual segmentation, the binary masks marking hair cells,
        % support cells, cell boundaries, and polar bodies (basal bodies or
        % fonticuli or both) should already be prepared and saved to the
        % same folder as the RAW image selected previously. 
        ImDat.HairCellMask = imread(fullfile(path,[root,'HairCells.bmp']));
        ImDat.SupportCellMask = imread(fullfile(path,[root,'SupportCells.bmp']));
        ImDat.CellBoundMask = imread(fullfile(path,[root,'CellBoundaries.bmp']));
        ImDat.PolarBodyMask = imread(fullfile(path,[root,'PolarBodies.bmp']));
    case 'Auto'
        % For automatic segmentation, provide the segmentation parameters
        % for the Hair Cells, Support Cells, Cell Boundaries, and Polar
        % bodies and the code will automatically generate masks. 
end

%% Refine Cell masks
% Remove all cells touching the image boundary.
% Remove Support cells that are not within 'NeighborThresh' pixels of a
% hair cell. 
ImDat = RefineCellMasks(ImDat,'ClearBoundary',true,'NeighborThresh',7);

%% Isolate Cells, Compute Polarity Map, Assign IDs, and cell type. 
%  And Get some morphological properties of cells

% Isolate and store image channels. 
ImDat.ImR = ImDat.RAW(:,:,1);
ImDat.ImG = ImDat.RAW(:,:,2);
ImDat.ImB = ImDat.RAW(:,:,3);

switch Approach
    case 'Manual'
        % For Manual, isolate the polar bodies from the polar body mask.
        
        % Isolate Hair cells and related features
        [ImDat,HairProps] = SepImageComps(ImDat,'GroupName','Hair',...
        'ExtraIms',{ImDat.PolarBodyMask},...
        'ExtraNames',{'PBMask'});
    
        % Isolate Support cells and related features
        [ImDat,SupportProps] = SepImageComps(ImDat,'GroupName','Support',...
        'ExtraIms',{ImDat.PolarBodyMask},...
        'ExtraNames',{'PBMask'});
    
    case 'Auto'
        % For Auto, the polar bodies are segmented on a cell by cell basis.
        
        % Isolate Hair cells and related features
        [ImDat,HairProps] = SepImageComps(ImDat,'GroupName','Hair');
        
        %%% Placeholder - Consolidate disparate polar bodies %%%
        % Compute overlap between polar bodies.
        % If they do not overlap by a specified threshold, omit them.
        % Use the overlap as the polar body mask.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Isolate Support cells and related features
        [ImDat,SupportProps] = SepImageComps(ImDat,'GroupName','Support');
end

CellProps = [HairProps;SupportProps]; % Combine the two groups;

%%%%%%%%%%% After here manual and automatic should be the same %%%%%%%%%%%

%% Calculate Visual Center, Polarity, Orientation and other morphological features.
[CellProps] = Masks2CtrPolOri(CellProps);

%% Get Reference Line and compute normalized orientation
[BoundPts,UserPts] = GetBoundaryLine(ImDat.RAW,'preview',true);

% Generate reference angles according to an inverse square rule.
[~,CellProps.RefAngle] = pt2ptInfluence(CellProps.Center,BoundPts,'inverse',2);
CellProps.NormOrientation = wrapTo360(CellProps.Orientation-CellProps.RefAngle);

%% Rebuild Masks
ImDat.RHairCellMask = false(imx,imy);
ImDat.RSupportCellMask = ImDat.RHairCellMask;
ImDat.RHairCellMask(cell2mat(CellProps.PixIDs(CellProps.Type=='Hair')))=true;
ImDat.RSupportCellMask(cell2mat(CellProps.PixIDs(CellProps.Type=='Support')))=true;
%% Save Results
curtime = qdt('Full');

savename = strcat(root,Approach,'_','data','_',curtime,'.mat');
save(fullfile(path,savename),'CellProps','ImDat','BoundPts');