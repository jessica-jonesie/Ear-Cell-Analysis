% Generate a set of vectors with random angles, magnitudes, and
% origins.
clc; clear; close all;
addpath('Sourced Functions')
%% Test Set
numvecs = 10;


% origin = rand(numvecs,2); % Random
origin = [linspace(0,1,numvecs)' linspace(0,1,numvecs)'];
% angle = 2*pi*rand(numvecs,1); % Randomly oriented [=] in radians
angle = 2*pi*ones(numvecs,1); % Uniformly oriented [=] in radians
magnitude = rand(numvecs,1);

vec = table(origin,angle,magnitude);

%% Compute unit vector components
[xcomp,ycomp] = ComputeComponents(vec.magnitude,vec.angle,'unit');

%% Compute the pairwise distance matrix between the vector origins
Distances = pairdist(vec.origin,vec.origin);


%% Local Alignment
scale = 0.4;

% This function can be used to compute the alignment of each feature with
% respect to neighbors at a given scale. 
alignment= LocalAlignment(scale,Distances,[xcomp ycomp]);

%% Average Alignment
% This gives the alignment of the full population at a given scale r. This
% is the Angle K measurement for a given scale. 
AveAlignment = mean(alignment);

%% Angle K(r) (univariate)
% If we loop the previous two functions over r we get the full angle K
% description.
scales = linspace(0.1,1,10);
Kuu = AngleK(scales,vec);