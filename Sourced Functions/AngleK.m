function [AngleK] = AngleK(scales,vec)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%% Compute unit vector components
[xcomp,ycomp] = ComputeComponents(vec.magnitude,vec.angle,'unit');

%% Compute the pairwise distance matrix between the vector origins
Distances = pairdist(vec.origin,vec.origin);


%% Local Alignment
for r=1:length(scales)
scale = scales(r);

% This function can be used to compute the alignment of each feature with
% respect to neighbors at a given scale. 
alignment= LocalAlignment(scale,Distances,[xcomp ycomp]);

%% Average Alignment
% This gives the alignment of the full population at a given scale r. This
% is the Angle K measurement for a given scale.

AngleK(r) = mean(alignment,'omitnan');
%% Angle K(r) (univariate)
% If we loop the previous two functions over r we get the full angle K
% description. 
end

end

