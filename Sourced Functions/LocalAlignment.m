function [alignment] = LocalAlignment(radius,distMat,vectorcomps,varargin)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% Find distances in the distMat less than or equal to radius and not 0 (aka
% the same feature). 
isNeighbor = (distMat<=radius)&(distMat~=0);

% Determine univariate or bivariate input
if nargin == 3
    type = 'univariate';
elseif nargin == 4
    type = 'bivariate';
else
    error('Improper number of inputs')
end

%% Compute Alignment
switch type
    case 'univariate'
        numFeatures = length(vectorcomps);
            for i=1:numFeatures
                u = vectorcomps(i,:); % Set target vector
                Neighbors = isNeighbor(:,i); % find index of u's neighbors.
                numNeighbors = sum(Neighbors);
                
                v = vectorcomps.*Neighbors; % Set Neighbor vectors
                eachAlignment = sum(u.*v,2); % Alignment with each neighbor.
                alignment(i) = sum(eachAlignment)/numNeighbors; % Average alignment overall.
                
            end
    case 'bivariate'
        vectorcompsA = vectorcomps;
        vectorcompsB = varargin{4};
        numAFeatures = length(vectorcompsA);
        numBFeatures = length(vectorcompsB);
end

% Catch case where there are no neighbors. By default
% assume the current feature is neutrally aligned at this
% scale. Alignment = 0
alignment(isnan(alignment))=0;

alignment = alignment';

end

