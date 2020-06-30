function [CellProps] = OrientHairCell_BB(CellProps)
nCells = length(CellProps.Area);
imBB = cell(1,nCells);
for n = 1:nCells
    CellIm = CellProps.CellIm{n};
    bChann = imadjust(CellIm(:,:,3));
    
    bIsolate = imadjust(ChannelIsolate(CellIm,'blue'));
    % Median filter to reduce noise
    medFilt = imadjust(medfilt2(bIsolate,2.*[1 1]));
    
    % Threshold and Binarize
    imBW = imbinarize(medFilt,0.8);
    
    % Solidify
    imSolid = imdilate(imclose(imBW,strel('disk',5)),strel('disk',1));
    
    % Select largest 
    imBB{n} = bwpropfilt(imSolid,bChann,'MeanIntensity',1);
end

CellProps = BBOrient(CellProps,imBB,'BB');
end
