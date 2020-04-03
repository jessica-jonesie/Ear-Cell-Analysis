%% Following guidelines at
% https://www.mathworks.com/help/vision/ug/semantic-segmentation-with-deep-learning.html#mw_44be2a2e-ec6b-4a03-9470-ea945f74515e
% https://towardsdatascience.com/simple-introduction-to-convolutional-neural-networks-cdf8d3077bac
%% Analyze Training Data for Semantic Segmentation
clc;clear;close all;

imDir = fullfile('Data','Control','Images');
pxDir = fullfile('Data','Control','PixelLabelData');

imds = imageDatastore(imDir);

I = readimage(imds,1);
figure
imshow(I)

classNames = ["Hair" "Support" "Intermediate"];

pixelLabelID = 1:3;

pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);

C = readimage(pxds,1);

B = labeloverlay(I,C);
figure
imshow(B)
legend

%% Create a semantic segmentation network

% create an image input layer. This defines the smallest image size that
% the network can process.
maxDim = 100;
inputSize = [100 100 3]; 
imgLayer = imageInputLayer(inputSize);

%%%% Create a Downsampling Network %%%%
%%% Start with the convolution layer
% Define hyperparameters of convolution layer.
% FilterSize should be on the scale of anything that you think will
% help distinguish the features in your image. Support cells are 22 pixels
% in diameter but it's not uncommon to use a 3x3 filter or a 5x5 filter so
% we will try those first. 
%
% The number of filters sets the number of times that the original image is
% convolved with the filter. 

% Number of filters can be tuned during training. 
filterSize = 3; % Hyperparameter. 
numFilters = 32; % Hyperparameter.

conv = convolution2dLayer(filterSize,numFilters,'Padding',1);