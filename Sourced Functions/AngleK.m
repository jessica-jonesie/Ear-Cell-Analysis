function [AngleK] = AngleK(scales,vecA,varargin)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%% Compute unit vector components
    [xcompA,ycompA] = ComputeComponents(vecA.magnitude,vecA.angle,'unit');

%% Compute the pairwise distance matrix between the vector origins
if nargin==2
    Distances = pairdist(vecA.origin,vecA.origin);
elseif nargin==3
    vecB = varargin{1};
    Distances = pairdist(vecA.origin,vecB.origin);
    [xcompB,ycompB] = ComputeComponents(vecB.magnitude,vecB.angle,'unit');
else
    error('Incorrect number of arguments')
end

%% Local Alignment
for r=1:length(scales)
scale = scales(r); 

% This function can be used to compute the alignment of each feature with
% respect to neighbors at a given scale. 
if nargin == 2
    alignment = LocalAlignment(scale,Distances,[xcompA ycompA]);
elseif nargin ==3
    alignment = LocalAlignment(scale,Distances,[xcompA ycompA],[xcompB ycompB]);
end

%% Average Alignment

AngleK(r) = mean(alignment,'omitnan');
end

end

