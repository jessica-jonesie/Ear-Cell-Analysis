function [SepIms,imMasks] = labelSeparate(im,labels,type,varargin)
%LABELSEPARATE Converts labeled portions of an image into separate images.
%   [SepIms] = LABELSEPARATE(im,labels)uses the labels assigned to each
%   pixel in the input image im to isolate the labeled portions of im into
%   separate images, then stores these as separate cells in the cell array
%   SepIms.
%
%   Set type to 'mask' to apply the labels exactly. Set type to 'crop' to
%   make the image cropped to a rectangle. With type set to crop, specify a
%   4th argument to add a buffer around the rectangle. 

nLabels = max(labels(:));

SepIms = cell(1,nLabels);
imMasks = cell(1,nLabels);
[rowmax,colmax,~]=size(im);

for k = 1:nLabels
    switch type
        case 'mask'
            MaskID = ismember(labels,k);
            [rows,cols] = find(MaskID);
            MaskID = MaskID(min(rows):max(rows), min(cols):max(cols));
            SingleIm = im(min(rows):max(rows), min(cols):max(cols),:);
            SingleIm = uint8(double(MaskID).*double(SingleIm));
            SepIms{k} = SingleIm;
        case 'crop'
            % Compute and save the masked version
            MaskID = ismember(labels,k);
            [rows,cols] = find(MaskID);
            MaskID = MaskID(min(rows):max(rows), min(cols):max(cols));
            
            [rows,cols] = find(labels==k);
            if nargin==4
                buff = varargin{1};
            else
                buff = 0;
            end
            initrowmin = min(rows);
            initrowmax = max(rows);
            initcolmin = min(cols);
            initcolmax = max(cols);
            
            finrowmin = min(rows)-buff;
            finrowmax = max(rows)+buff;
            fincolmin = min(cols)-buff;
            fincolmax = max(cols)+buff;
            
            finrowmin(finrowmin<=0) = 1;
            finrowmax(finrowmax>rowmax) = rowmax;
            fincolmin(fincolmin<=0) = 1;
            fincolmax(fincolmax>colmax) = colmax;
            
            minrowdiff = initrowmin-finrowmin;
            maxrowdiff = finrowmax-initrowmax;
            mincoldiff = initcolmin-fincolmin;
            maxcoldiff = fincolmax-initcolmax;

            SingleIm = im(finrowmin:finrowmax, fincolmin:fincolmax,:);
            
            % Adjust the mask to match the image
            MaskID = padarray(MaskID,[minrowdiff mincoldiff],'pre');
            MaskID = padarray(MaskID,[maxrowdiff maxcoldiff],'post');
            alphaIm = double(MaskID);
            alphaIm(alphaIm==0) = 0;
            imMasks{k} = logical(alphaIm);
            
            SepIms{k} = SingleIm;
    end
end

