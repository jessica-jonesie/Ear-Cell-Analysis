%% Following guidelines at
% https://www.mathworks.com/help/vision/ug/semantic-segmentation-with-deep-learning.html#mw_44be2a2e-ec6b-4a03-9470-ea945f74515e
% https://towardsdatascience.com/simple-introduction-to-convolutional-neural-networks-cdf8d3077bac
%% Analyze Training Data for Semantic Segmentation
clc;clear;close all;

imDir = fullfile('Data','Control','Split','Train','Images');
pxDir = fullfile('Data','Control','Split','Train','PixelLabelData');

imdsTrain = imageDatastore(imDir,'ReadFcn',@imResizeOpen);

ind = 12;
I = readimage(imdsTrain,ind);
% figure
% imshow(I)

classNames = ["Hair" "Support" "Intermediate"];

pixelLabelID = 1:3;
pxdsTrain = pixelLabelDatastore(pxDir,classNames,pixelLabelID);
pxdsTrain.ReadFcn = @pixResizeOpen;

C = readimage(pxdsTrain,ind);

B = labeloverlay(I,C);
figure
imshow(B)
legend

%% Create a semantic segmentation network

% create an image input layer. This defines the smallest image size that
% the network can process.
inputSize = [300 300 3]; 
numClasses = length(pixelLabelID);
imgLayer = imageInputLayer(inputSize);

%% Create a Downsampling Network %%%%
%%% Start with the convolution layer %%%
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
numFilters = 64; % Hyperparameter.

conv = convolution2dLayer(filterSize,numFilters,'Padding',1);
% Padding ensures that the size of the output matches the size of the
% input.
% By default the stride of this convolution is 1, meaning that during
% convolution the filter slides 1 step at a time. Setting a higher stride
% sets the number of steps that occur during convolution e.g. stride = 2
% makes the filter slide 2 steps at a time during convolution.

%%% Define the ReLU Layer %%%
% The ReLU layer decides whether a certain feature is present in the input
% image or not. It outputs the input directly if positive(feature present)
% or 0 otherwise. 
% https://machinelearningmastery.com/rectified-linear-activation-function-for-deep-learning-neural-networks/
relu = reluLayer();

%%% Create a max pooling layer to downsample the input %%%
% This layer takes the maximum value in a certain filter region and is used
% to reduce the dimensionality of the network making computation quicker!

poolSize = 2; % This is functionally equivalent to the filter size.
% It defines the size of the area from which data is pooled. 

maxPoolDownsample2x = maxPooling2dLayer(poolSize,'Stride',2); 
% Setting the stride to 2 downsamples the input by a factor of 2. 

%%% Stack the previous layers to create downsampling Layers %%%
downsamplingLayers = [
    conv
    relu
    maxPoolDownsample2x
    conv
    relu
    maxPoolDownsample2x];

% overall this will perform 32 convolutions, relu, then max pool
% downsample by a factor of 2, then 32 more convolutions, relu, and a final
% downsample by a factor of 2 for a total downsampling factor of 4X. 

downsamplingLayers;
% Show the 6 layers and what they are doing.


%% Create upsampling network
filterSize = 4;
% Create a transposed convolution layer to upsample by 2. 
transposedConvUpsample2x = transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
% The cropping parameter is set to 1 to make the output size equal twice
% the input size.

% Stack the transposed convolution and relu layers. 
upsamplingLayers = [
    transposedConvUpsample2x
    relu
    transposedConvUpsample2x
    relu
    ];

%% Create A Pixel Classification Layer
% These final layers process an input that has the same spatial dimensions
% (height and width) as the input image. However, the number of channels
% (third dimension) is larger and is equal to number of filters in the last
% transposed convolution layer. This third dimension needs to be squeezed
% down to the number of classes we wish to segment. This can be done using
% a 1by1 conbolution layer whose number of filters equal the number of
% classes, e.g. three. 

% Combine the 3rd dimension of the input feature maps down to the number of
% classes
conv1x1 = convolution2dLayer(1,numClasses);

% Following this 1-by-1 convolution layer are the softmax and pixel
% classification layers. These two layers combine to predict the
% categorical label for each image pixel. 
finalLayers = [
    conv1x1
    softmaxLayer()
    pixelClassificationLayer()
    ];

%% Stack All Layers
% Stack all layers to complete the semantic segmentation network
layers = [
    imgLayer
    downsamplingLayers
    upsamplingLayers
    finalLayers
    ];

%% Set training options
opts = trainingOptions('sgdm','InitialLearnRate',1e-3,'MaxEpochs',100,'MiniBatchSize',64);

%% Create pixel label image datastore
% Augment and preprocess training data images
trainingData = pixelLabelImageDatastore(imdsTrain,pxdsTrain);
trainingData = augmentedImageDatastore(inputSize,trainingData);
%% Train the Network
net = trainNetwork(trainingData,layers,opts);