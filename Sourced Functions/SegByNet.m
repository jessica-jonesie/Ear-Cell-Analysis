%% Split the image and labels into tiles
[imfile,rootdir] = uigetfile({'*.png;*.jpg;*.bmp*;*.mat'});
im = imread([rootdir imfile]);
[~,imname,imtype]=fileparts(imfile);


%% Preprocess images
% [bestScale,bestSNRatio,bestIm] = PreProcessLearn(im,labels);
% im = bestIm;
if strcmp(imtype,{'.bmp'})||length(size(im))==2
    im(:,:,2) = im;
    im(:,:,3) = im(:,:,1);
end

%% Tile images
tilewidth = 224;
imageDir = [rootdir 'TileIms'];
[tiledims,tx,ty] = Split2Tile(im,tilewidth,'SaveDir',imageDir);

%% Create datastores
imds = imageDatastore(imageDir);

%% Load network
[netfile,netdir] = uigetfile({'*.mat'});
load([netdir netfile]);
%% Segment and rebuild full image;
segdir = fullfile(rootdir,'SegLabels');
mkdir(segdir);
segResults = semanticseg(imds,net, ...
    'MiniBatchSize',4, ...
    'WriteLocation',segdir, ...
    'Verbose',false);
%% Rebuild
segims = imageDatastore(segdir);
for k=1:length(segims.Files)
    impart{k} = readimage(segims,k)>1;
%     imtemp = imr;
%     imtemp(xxx(k):xxx(k)+tilewidth-1,yyy(k):yyy(k)+tilewidth-1)=impart;
%     imrpart{k}= imtemp;
end

rtile = reshape(impart,[length(tx),length(ty)])';
figure;montage(rtile,'Size',[length(tx),length(ty)]);
fullim = RebuildFromTile(rtile',tx,ty);
fullim = logical(fullim);
%% Final Processing
AreaFilt = bwpropfilt(fullim,'area',[250 20000]);
OpenIm = imopen(AreaFilt,strel('disk',12));
ShedIm = imWatershed(OpenIm);
AreaFilt2 = bwpropfilt(fullim,'area',[250 2000]);
ShedIm2 = imWatershed(AreaFilt2);

figure
imshow(labeloverlay(im,ShedIm2,'Colormap','autumn'));