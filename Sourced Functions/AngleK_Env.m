function [meanAngK,maxAngK,minAngK,AngKSims] = AngleK_Env(scales,vecA,alpha,varargin)
%ANGLEK_Env Compute significance envelopes for AngleK statistic
%   Detailed explanation goes here
nsims = round((2/alpha))-1;

if nargin == 3
    for k=1:nsims
        % randomize angle
        vecA.angle = rand(length(vecA.angle),1)*2*pi-pi;
        % compute angle K with randomized angle
        AngK(k,:) = AngleK(scales,vecA);
    end
elseif nargin ==4
    vecB = varargin{1};
    for k = 1:nsims
        % randomize angles
        vecA.angle = rand(length(vecA.angle),1)*2*pi-pi;
        vecB.angle = rand(length(vecB.angle),1)*2*pi-pi;
        
        AngK(k,:) = AngleK(scales,vecA,vecB);
    end
end

meanAngK = mean(AngK);
maxAngK = max(AngK);
minAngK = min(AngK);
end

