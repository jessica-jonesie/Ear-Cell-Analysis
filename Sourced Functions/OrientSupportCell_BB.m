function [CellProps] = OrientSupportCell_BB(CellProps)
nCells = length(CellProps.Area);

for n = 1:nCells
    CellIm = CellProps.CellIm{n};
    [ydim(n) xdim(n)] = size(CellIm);
    bChann{n} = imadjust(CellIm(:,:,3));
    
    bIsolate{n} = imadjust(ChannelIsolate(CellIm,'blue'));
    % Median filter to reduce noise
    medFilt{n} = imadjust(medfilt2(bIsolate{n},2.*[1 1]));
    
    % Threshold and Binarize
    imBW{n} = imbinarize(medFilt{n},0.6);
    
    % Solidify
    imSolid{n} = imclose(imBW{n},strel('disk',2));
    
    % Select largest 
    imBB{n} = bwpropfilt(imSolid{n},'Area',1);
end

CellProps = BBOrient(CellProps,imBB,'BB');
end
