function [CellProps] = OrientSupportCell_BB(CellProps)
nCells = length(CellProps.Area);
imBB = cell(1,nCells);
for n = 1:nCells
    CellIm = CellProps.CellIm{n};
%     [ydim(n) xdim(n)] = size(CellIm);
    bChann = imadjust(CellIm(:,:,3));
    
    bIsolate = imadjust(ChannelIsolate(CellIm,'blue'));
    % Median filter to reduce noise
    medFilt = imadjust(medfilt2(bIsolate,2.*[1 1]));
    
    % Threshold and Binarize
    imBW = imbinarize(medFilt,0.6);
    
    % Solidify
    imSolid = imclose(imBW,strel('disk',2));
    
    % Select largest 
    imBB{n} = bwpropfilt(imSolid,'Area',1);
end

CellProps = BBOrient(CellProps,imBB,'BB');
end
