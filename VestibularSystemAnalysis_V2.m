clc;clear;close all;
% Add the directories that this code needs to access.
addpath('Source Images')
addpath('Sourced Functions')
addpath('Data')
addpath('Results')

%% Analysis parameters
EllipticalApproximation = false;
Approach = 'Manual';

%% Analyze Image
% Select RAW Image
[file,path] = uigetfile('*.png');
root = extractBefore(file,'RAW.png');

% Read in the image to be analyzed
ImDat.RAW = imread(fullfile(path,file));

% Get image size
[imx,imy,imz] = size(ImDat.RAW);

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
% Isolate and store image channels. 
ImDat.ImR = ImDat.RAW(:,:,1);
ImDat.ImG = ImDat.RAW(:,:,2);
ImDat.ImB = ImDat.RAW(:,:,3);

switch Approach
    case 'Manual'
        % For Manual, isolate the polar bodies from the polar body mask.
        [ImDat,HairProps] = SepImageComps(ImDat,'GroupName','Hair',...
        'ExtraIms',{ImDat.PolarBodyMask},...
        'ExtraNames',{'PBMask'});
    
        [ImDat,SupportProps] = SepImageComps(ImDat,'GroupName','Support',...
        'ExtraIms',{ImDat.PolarBodyMask},...
        'ExtraNames',{'PBMask'});
    case 'Auto'
        % For Auto, the polar bodies are segmented on a cell by cell basis.
        [ImDat,HairProps] = SepImageComps(ImDat,'GroupName','Hair');
        [ImDat,SupportProps] = SepImageComps(ImDat,'GroupName','Support');
end

CellProps = [HairProps;SupportProps]; % Combine the two groups;