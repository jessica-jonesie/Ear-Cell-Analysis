function [CellProps] = OrientHairCell_BB(CellProps)
nCells = length(CellProps.Area);

for n = 1:nCells
    CellIm = CellProps.CellIm{n};
    [ydim(n) xdim(n)] = size(CellIm);
    bChann{n} = imadjust(CellIm(:,:,3));
    
    bIsolate{n} = imadjust(ChannelIsolate(CellIm,'blue'));
    % Median filter to reduce noise
    medFilt{n} = imadjust(medfilt2(bIsolate{n},2.*[1 1]));
    
    % Threshold and Binarize
    imBW{n} = imbinarize(medFilt{n},0.8);
    
    % Solidify
    imSolid{n} = imdilate(imclose(imBW{n},strel('disk',5)),strel('disk',1));
    
    % Select largest 
    imBB{n} = bwpropfilt(imSolid{n},bChann{n},'MeanIntensity',1);
end

CellProps = BBOrient(CellProps,imBB,'BB');
end
