function [R,T,C,S] = ResLength(a,p)
%RESLENGTH compute the pth resultant length of the set of angles in a in degrees. 
%   Detailed explanation goes here
a(isnan(a))=[];

n=length(a);

Cp = sum(cosd(p.*a));
Sp = sum(sind(p.*a));
Rp = sqrt(Cp.^2+Sp.^2);

% Compute average
C = Cp/n;
S = Sp/n;
R = Rp/n;


T = atan2d(S,C);

T = wrapTo180(T);

if T<0
    T = T+360;
end

end

