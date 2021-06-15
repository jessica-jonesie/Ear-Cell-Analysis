clc;clear;close all;
% Add the directories that this code needs to access.
addpath('Source Images')
addpath('Sourced Functions')
addpath('Data')
addpath('Results')

%% Analysis parameters
doAnnot = false;

%% name the group
% prompt = {'Enter Group Name'};
% dlgtitle = 'Input';
% dims = [1 35];
% definput = {'group'};
% type = cell2mat(inputdlg(prompt,dlgtitle,dims,definput));

%% Read in cell masks (segment or read)
[Rawcell,imfile,impath] = uigetimages('*.png','Select Raw File');
ImDat.RAW = Rawcell{1}; % Raw image
ImDat.CellMask = cell2mat(uigetimages('*.bmp','Select Cell Mask',impath)); % Binary mask marking Cells
ImDat.PolarBodyMask = cell2mat(uigetimages('*.bmp','Select Polar Body Mask',impath)); % Binary mask marking polar bodies

[imx,imy,imz] = size(ImDat.RAW);

%% Select Analysis Region
%%%% PLACEHOLDER %%%%
% This should allow the user to select a region, then mask the RAW image.
% It should then crop the image down to the masked region. This will
% improve computational time. 

%% Isolate Cells, Compute Polarity Map, Assign IDs, and cell type. 
% Isolate and store image channels. 
ImDat.ImR = ImDat.RAW(:,:,1);
ImDat.ImG = ImDat.RAW(:,:,2);
ImDat.ImB = ImDat.RAW(:,:,3);

% Isolate Hair cells and related features
[ImDat,CellProps] = SepImageComps(ImDat,'GroupName','',...
'ExtraIms',{ImDat.PolarBodyMask},...
'ExtraNames',{'PBMask'});

%% Calculate Visual Center, Polarity, Orientation and other morphological features.
[CellProps] = Masks2CtrPolOri(CellProps);

%% Get Reference Line and compute normalized orientation
[BoundPts,UserPts] = GetBoundaryLine(ImDat.RAW,'preview',true);

% Generate reference angles according to an inverse square rule.
[~,CellProps.RefAngle,CellProps.RefX,CellProps.RefY] = pt2ptInfluence(CellProps.Center,BoundPts,'inverse',2);
CellProps.NormOrientation = wrapTo360(CellProps.Orientation-CellProps.RefAngle);

%% Preview annotation, and allow user to remove individual cells
[TypeID,ntypes,types] = GetTypeIDs(CellProps,'Type');

if doAnnot
    if ~any(strcmp('AnnotIm',CellProps.Properties.VariableNames))
    CellProps = AnnotIndIms(CellProps);
    %     save(fullfile(path,file),'CellProps','-append');
    end

    % Preview montage and allow user to remove cells.
    CellID = 1:height(CellProps)';
    RemID = []; % initialize removal ID; 
    mbox = msgbox('Click to select cells to remove. Hit enter when finished.');
    for k=1:ntypes
    %     figure
        curprops = CellProps(TypeID{k},:);
        curID = CellID(TypeID{k});
        [selectedIms] = GetMontageIDs(curprops.AnnotIm);
    %     title(types{k});
        RemID = [RemID curID(selectedIms)];
    %     montage(CellProps.AnnotIm(TypeID{k}))
    end
close(mbox);

    % remove selected cells from analysis. 
    CellProps(RemID',:) = [];
end

% Additional transformations of orientation
CellProps.OrientationR = wrapTo360(CellProps.Orientation)*pi/180; % Orientation in Radians
CellProps.NormOrientationR = wrapTo360(CellProps.NormOrientation)*pi/180; % Norm Orientation in Radians
CellProps.RefAngleR = wrapTo360(CellProps.RefAngle)*pi/180; % Reference Angle in Radians
CellProps.NormOrientation180 = flipTo180(CellProps.NormOrientation); % Normalized Orientation between 0 and 180

%% Rebuild Masks
ImDat.CellMaskR = false(imx,imy);
ImDat.CellMaskR(cell2mat(CellProps.PixIDs))=true;

%% Save Results
curtime = qdt('Full');

% savename = strcat(root,Approach,'_','data','_',curtime,'.mat');
% save(fullfile(impath,savename),'CellProps','ImDat','BoundPts');