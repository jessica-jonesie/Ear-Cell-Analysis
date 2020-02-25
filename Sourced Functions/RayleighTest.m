function [pvalue,Ray,z] = RayleighTest(angs)
%RAYLEIGHTEST Test null hypothesis that circular distribution is uniform
%   Detailed explanation goes here
angs(isnan(angs))= [];

R = ResLength(angs,1);
n = length(angs);

Ray = n*R;
z = n*(R^2);

pvalue = exp(sqrt(1+4*n+4*(n^2-Ray^2))-(1+2*n));
end

