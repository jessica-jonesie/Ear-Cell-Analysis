function [] = PolAndOriHistograms(CellProps,sidedness)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if strcmp(sidedness,'Full')
    CellProps.NormOrientation = CellProps.NormOrientation;
elseif strcmp(sidedness,'Half')
    CellProps.NormOrientation = abs(CellProps.NormOrientation);
elseif strcmp(sidedness,'Quarter')
    CellProps.NormOrientation = wrapTo90(CellProps.NormOrientation);
else
    error('Invalid Sideness')
end

figure
subplot(1,3,1)
ph=polarhistogram(CellProps.NormOrientation*2*pi/360,36);
ph.Normalization = 'probability';
ph.FaceColor = 'm';
title('Combined');

subplot(1,3,2)
ph=polarhistogram(CellProps.NormOrientation(CellProps.Type=='H')*2*pi/360,36);
ph.Normalization = 'probability';
ph.FaceColor = 'r';
title('Hair Cells');

subplot(1,3,3)
ph=polarhistogram(CellProps.NormOrientation(CellProps.Type=='S')*2*pi/360,36);
ph.Normalization = 'probability';
ph.FaceColor = 'c';
title('Support Cells');


sgtitle('Orientation Distribution')
%%

figure
subplot(1,3,1)
h=histogram(CellProps.CombinedPolarity,20);
h.Normalization = 'probability';
title('Combined');
h.FaceColor = 'm';
xlabel('Magnitude of Polarity')

subplot(1,3,2)
h=histogram(CellProps.CombinedPolarity(CellProps.Type=='H'),20);
h.Normalization = 'probability';
h.FaceColor = 'r';
title('Hair Cells');
xlabel('Magnitude of Polarity')

subplot(1,3,3)
h=histogram(CellProps.CombinedPolarity(CellProps.Type=='S'),20);
h.Normalization = 'probability';
h.FaceColor = 'c';
title('Support Cells');
xlabel('Magnitude of Polarity')

sgtitle('Magnitude of Polarity Distribution')

end

