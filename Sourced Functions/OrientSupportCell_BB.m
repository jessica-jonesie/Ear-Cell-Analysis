function [CellProps] = OrientSupportCell_BB(CellProps,Chann)
nCells = length(CellProps.Area);
imBB = cell(1,nCells);

Channs = {'red','blue','green'};
channums = 1:3;
ChanNum = channums(strcmp(Channs,Chann));
for n = 1:nCells
    CellIm = CellProps.CellIm{n};
%     [ydim(n) xdim(n)] = size(CellIm);
    bChann = imadjust(CellIm(:,:,ChanNum));
    
    bIsolate = imadjust(ChannelIsolate(CellIm,Chann));
    % Median filter to reduce noise
    medFilt = imadjust(medfilt2(bIsolate,2.*[1 1]));
    
    % Threshold and Binarize
    imBW = imbinarize(medFilt,0.6);
    
    % Solidify
    imSolid = imclose(imBW,strel('disk',2));
    
    % Select largest 
    imBB{n} = bwpropfilt(imSolid,'Area',1);
%     imshowpair(bChann,imBB{n},'montage')
end

CellProps = BBOrient(CellProps,imBB,'BB');
end
