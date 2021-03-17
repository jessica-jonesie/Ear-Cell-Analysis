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

%%
nbins = ceil(pi*FDBins(CellProps.NormOrientation));

figure
subplot(1,3,1)
ph=polarhistogram(CellProps.NormOrientation*2*pi/360,nbins);
ph.Normalization = 'probability';
ph.FaceColor = 'm';
title('Combined');

subplot(1,3,2)
ph=polarhistogram(CellProps.NormOrientation(CellProps.Type=='H')*2*pi/360,nbins);
ph.Normalization = 'probability';
ph.FaceColor = 'r';
title('Hair Cells');

subplot(1,3,3)
ph=polarhistogram(CellProps.NormOrientation(CellProps.Type=='S')*2*pi/360,nbins);
ph.Normalization = 'probability';
ph.FaceColor = 'c';
title('Support Cells');


sgtitle('Orientation Distribution')
%%
% nbins = 20;
nbins = ceil(FDBins(CellProps.CombinedPolarity));

comboCounts = histcounts(CellProps.CombinedPolarity,nbins);...
hairCounts = histcounts(CellProps.CombinedPolarity(CellProps.Type=='H'),nbins);
supportCounts = histcounts(CellProps.CombinedPolarity(CellProps.Type=='S'),nbins);

comboFreq = comboCounts./sum(comboCounts);
hairFreq = hairCounts./sum(hairCounts);
supportFreq = supportCounts./sum(supportCounts);

maxFreq = max([comboFreq hairFreq supportFreq]);

figure
s1=subplot(1,3,1);
h1=histogram(CellProps.CombinedPolarity,nbins);
h1.Normalization = 'probability';
title('Combined');
h1.FaceColor = 'm';
xlabel('Magnitude of Polarity')
ylim([0 maxFreq*1.1]);


s2=subplot(1,3,2);
h2=histogram(CellProps.CombinedPolarity(CellProps.Type=='H'),nbins);
h2.Normalization = 'probability';
h2.FaceColor = 'r';
title('Hair Cells');
xlabel('Magnitude of Polarity')
ylim([0 maxFreq*1.1]);

s3=subplot(1,3,3);
h3=histogram(CellProps.CombinedPolarity(CellProps.Type=='S'),nbins);
h3.Normalization = 'probability';
h3.FaceColor = 'c';
title('Support Cells');
xlabel('Magnitude of Polarity')
ylim([0 maxFreq*1.1]);

maxFreq = max([h1.Values h2.Values h3.Values])*1.1;
s1.YLim = [0 maxFreq];
s2.YLim = [0 maxFreq];
s3.YLim = [0 maxFreq];


sgtitle('Magnitude of Polarity Distribution')

end

