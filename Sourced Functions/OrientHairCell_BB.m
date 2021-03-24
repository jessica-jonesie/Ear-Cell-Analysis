function [CellProps] = OrientHairCell_BB(CellProps,Chann)
nCells = length(CellProps.Area);
imBB = cell(1,nCells);
Channs = {'red','blue','green'};
channums = 1:3;
ChanNum = channums(strcmp(Channs,Chann));
for n = 1:nCells
    CellIm = CellProps.CellIm{n};
    imK{1}= CellIm;
    
    bChann = imadjust(CellIm(:,:,ChanNum));
    imK{2}= bChann;
    
    bIsolate = imadjust(ChannelIsolate(CellIm,Chann));
    imK{3}= bIsolate;
    
    % Median filter to reduce noise
    medFilt = imadjust(medfilt2(bIsolate,2.*[1 1]));
    imK{4} = medFilt;
    
    % Threshold and Binarize
    imBW = imbinarize(medFilt,0.8);
    imK{5} = imBW;
    
    % Solidify
    imSolid = imdilate(imclose(imBW,strel('disk',5)),strel('disk',1));
    imK{6} = imSolid;
    
    % Select largest 
    imBB{n} = bwpropfilt (imSolid,bChann,'MeanIntensity',1);
%     imshowpair(bChann,imBB{n},'montage')

    imK{7} =imBB{n};
    
%     montage(imK)
end

CellProps = BBOrient(CellProps,imBB,'BB');
end
