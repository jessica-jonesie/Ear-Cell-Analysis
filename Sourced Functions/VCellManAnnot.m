function [NeedInputProps] = VCellManAnnot(NeedInputProps)
%VCELLMANANNOT manually annotate polar features in vestibular cells
%   Detailed explanation goes here
for n = 1:height(NeedInputProps)
    curIm = NeedInputProps.CellIm{n};
    curMask = NeedInputProps.CellMaskEllipse{n};
    visimR = curIm(:,:,1);
    visimB = curIm(:,:,3);
    visimR(~curMask) = 255;
    visimB(~curMask) = 255;
    visimG = 255.*~curMask;
    
    visim(:,:,1) = visimR;
    visim(:,:,2) = visimG;
    visim(:,:,3) = visimB;
    
    figure
    imshow(visim,'InitialMagnification','fit');
    hold on
    xlabel({'Click to select Center of Basal Body or Fonticulus',...
        'Press Enter after clicking to continue.'...
        'If Basal Body of Fonticulus cannot be identified, press enter without clicking.'})
    [cx,cy] = getpts;
    if isempty(cx)
        poleLocalCenter(n,:) = [NaN,NaN];
    else
        poleLocalCenter(n,:) = [cx,cy];
    end
    
    close all
    clear visim visimR visimG visimB
end
close all

[~,~,~,objOrientation,~,~,objPolarity] = orientFromPoint(NeedInputProps,poleLocalCenter,NeedInputProps.LocalCentroid);
NeedInputProps.CombinedOrientation = objOrientation;
NeedInputProps.CombinedPolarity = objPolarity;
NeedInputProps.UserInput = true(height(NeedInputProps),1);
end

