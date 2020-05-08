% This script pre processes segmented image data before semantic
% segmentation.
clc; clear; close all;
addpath('Sourced Functions')

%% Import the image data set/write to datastore.
% Directory for images. 
imageDir = uigetdir('Data');
% Directory for pixel labels. 
parentDir = regexprep(imageDir,'(\w+)$','');
pixDir = uigetdir(parentDir);

imageDS = imageDatastore(imageDir);
pixDS = imageDatastore(pixDir);

nims = length(imageDS.Files);
npix = length(pixDS.Files);

if nims~=npix
    error('Number of images must equal number of labeled pixel arrays')
end

%% Read in data from image set
for n = 1:nims
    im{n} = readimage(imageDS,n);
    pix{n} = readimage(pixDS,n);
    
    imsize(n,:) = size(im{n});
    pixsize(n,:) = size(pix{n});
end

outputimsize = min(imsize);
outputpixsize = min(pixsize);

%% Process data
for n=1:nims
    % Impose fixed size on images. In this case the minimum dimensions in
    % the data set.
    im{n} = CenterCrop(im{n},outputimsize);
    pix{n} = CenterCrop(pix{n},outputpixsize);
end

imsavefolder = fullfile(imageDir,'preprocessed');
pixsavefolder = fullfile(pixDir,'preprocessed'); 

mkdir(imsavefolder);
mkdir(pixsavefolder);

% Write data
for n=1:nims
    [~,imfilename,imtype] = fileparts(imageDS.Files{n});
    imsavedir = fullfile(imsavefolder,strcat(imfilename,imtype));
    imwrite(im{n},imsavedir);
    
    [~,pixfilename,pixtype] = fileparts(pixDS.Files{n});
    pixsavedir = fullfile(pixsavefolder,strcat(pixfilename,pixtype));
    imwrite(pix{n},pixsavedir);
end
