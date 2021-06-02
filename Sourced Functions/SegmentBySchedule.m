function [imOut,imM] = SegmentBySchedule(varargin)
%SEGMENTBYSCHEDULE segment an an image according to a prescribed schedule. 
%   Detailed explanation goes here
%% parse inputs
p=inputParser;

% Raw Image Input
checkim = @(x) (isa(x,'uint8')||islogical(x))||iscell(x)||isempty(x);
addParameter(p,'RawImage',[],checkim);

% Schedule Input
checkSched = @(x) istable(x)||isempty(x);
addParameter(p,'Schedule',[],checkSched);

% Save
addParameter(p,'save',false,@islogical);

parse(p,varargin{:});

RawImage = p.Results.RawImage;
Schedule = p.Results.Schedule;
doSave = p.Results.save;

% UI read images if not provided as inputs to SEGMENTBYSCHEDULE.
if isempty(RawImage)
%     [imfile,impath] = uigetfile({'*.png;*.jpg;*.bmp'},'Multiselect','on');
%     RawImage = {imread(fullfile(impath,imfile))};
    [RawImage,imfiles,impath] = uigetimages;
    imfile= imfiles{1};
else
    impath = pwd;
    imfile = 'manual.png';
end

if isempty(Schedule)
    [schedfile,schedpath] = uigetfile({'*.mat;*.xlsx'},...
        'Select Segmentation Schedule',impath);
    
    [~,schedname,schedext] = fileparts(schedfile);
else
    SegT = Schedule;
    schedfile = 'manualsched.mat';
    schedpath = pwd;
    schedname = 'manualsched';
    schedext = 'manual';
end

schedfpath = fullfile(schedpath,schedfile);
switch schedext
    case '.xlsx'
        [~,~,rawsched] = xlsread(schedfpath);
        
        % first remove empty rows (nan rows)
        isnancell = @(x) any(isnan(x));
        nanentries = cellfun(isnancell,rawsched);
        rawsched(nanentries(:,1),:)=[];
        
        Oper = rawsched(2:end,1);
        params = rawsched(2:end,2:end);

        nsteps = length(Oper);

        remnan = @(x) any(isnan(x));

        for k = 1:nsteps
            % remove nans
            tempcell = params(k,:);
            tempcell(cellfun(remnan,tempcell)) = [];

            parcell{k,1} = tempcell;
        end
        SegT = table(Oper);
        SegT.Params = parcell;
    case '.mat'
        try
            load(schedfpath,'SegT')
        catch
            error('Invalid segmentation file. When using .mat the file must contain a variable named SegT that provides the segmentation schedule')
        end
        
    case 'manual'
        if ~istable(SegT)
            error('schedpath must be a table providing the segmentation schedule operations and parameters')
        end
end

nsteps = height(SegT);

%% Define operation categories
% morphological operations that use the bwmorph function.
bwmorphops = {'outline','skel','bothat','bridge','clean','thicken',...
              'thin','tophat'}';
          
% all morphological operations.
othermorphops = {'dilate','erode','close','open','clearborder',...
            'watershed'}';

% proper filters that use the bwpropfilt function.
bwpropfilts = {'area','convexarea','eccentricity','equivdiameter',...
               'eulernumber','extent','filledarea','majoraxislength',...
               'minoraxislength','orientation','perimeter','solidity'}';
           
% proper filters that use the bwpropfilt function and require a second
% image input. 
bwpropfiltsI = {'maxintensity','minintensity','meanintensity'}';

% all property filters
otherpropfilts = {'circularity'}';

% mask operations
maskops = {'mask','asmask','cropbymask','neighborthresh'}';

% Basic image processing operations.
imops = {'contrast','denoise','flatfield','channel','isolatechann','binarize','threshold','invert'}';

allops = [bwmorphops;othermorphops;bwpropfilts;bwpropfiltsI;...
          otherpropfilts;maskops;imops];
      
optype = [repmat("bwmorph",[length(bwmorphops) 1]);...
          repmat("othermorph",[length(othermorphops) 1]);...
          repmat("bwpropfilt",[length(bwpropfilts) 1]);...
          repmat("bwpropfiltI",[length(bwpropfiltsI) 1]);...
          repmat("otherpropfilts",[length(otherpropfilts) 1]);...
          repmat("mask",[length(maskops) 1]);...
          repmat("impro",[length(imops) 1])];
opTbl = table(allops,optype);
opTbl.Properties.VariableNames = {'oper','type'};

%% Run through image operations
for m=1:length(RawImage) % place in loop in order to process sets of images later using identical settings. 
ims{1}=RawImage{m}; % Initialize image
for k=2:nsteps+1
    curOp = SegT.Oper{k-1};
    curParams = SegT.Params{k-1};
    curType = opTbl.type(find(strcmp(opTbl.oper,curOp)));
    
%     try
    ims{k} = applyOperation(ims,curOp,curType,curParams,impath);
    % pass all images to apply Operation so that they can be used in
    % various operations.
%     catch
%         error('Error during %s operation at step %d',curOp,k-1)
%     end
    
end
   imM(:,m)=ims';
   clear ims;
end

imOut = imM(end,:); % Final Output

%% Save if prompted
if doSave
    if isRGB(imOut)||isGray(imOut)
        filt = '*.png';
    elseif isBW(imOut)
        filt = '*.bmp';
    elseif iscell(imOut)
        filt = '*.mat';
    end
    
    %get image name
    [~,imname] = fileparts(imfile);
    
    suggName = fullfile(impath,strcat(imname,'_by_',schedname));
    
    [sfile, spath] = uiputfile(filt, 'Save Picture as',suggName);
    imwrite(imOut,fullfile(spath,sfile));
end
end

function imgOut = applyOperation(imgs,oper,type,params,impath)
switch type
    case {"bwmorph","othermorph"}
        imgOut = applyMorphOp(imgs{end},oper,type,params);
    case {"otherpropfilts","bwpropfilt","bwpropfiltI"}
        imgOut = applyPropFilt(imgs,oper,type,params,impath);
    case "mask"
        % set mask 
        imgOut = applyMaskOp(imgs,oper,params,impath);
    case "impro"
        imgOut = applyImProcess(imgs{end},oper,params);
    otherwise
        warning('Invalid Operation (%s). No change made at step %d.',oper,length(imgs));
        imgOut = imgs{end};
end
end

function imgOut = applyMorphOp(imgIn,oper,type,params)
% Check image type
if ~isBW(imgIn)
    imWarnMsg(oper,'BW')
    imgOut = imgIn;
    return
end

switch type
    case "bwmorph" % apply any of the morphological functions available in bwmorph.m
        if strcmp(oper,'outline')
            oper = 'remove';
        end
        imgOut = bwmorph(imgIn,oper,params{:});
    case "othermorph" % apply other morphological operations
        switch oper
            case 'dilate'
                kern = strel('disk',params{1});
                imgOut = imdilate(imgIn,kern);
            case 'erode'
                kern = strel('disk',params{1});
                imgOut = imerode(imgIn,kern);
            case 'close'
                kern = strel('disk',params{1});
                if any(strcmp(params,'bycomp'))
                    labim = imclose(bwlabel(imgIn),kern);
                    imgOut = labim>0;
                else
                    imgOut = imclose(imgIn,kern);
                end
            case 'open'
                kern = strel('disk',params{1});
                if any(strcmp(params,'bycomp'))
                    labim = imopen(bwlabel(imgIn),kern);
                    imgOut = labim>0;
                else
                    imgOut = imopen(imgIn,kern);
                end
            case 'fill'
                imgOut = imfill(imgIn,'holes');
            case 'clearborder'
                imgOut = imclearborder(imgIn);
            case 'watershed'
                imgOut = imWatershed(imgIn);
        end
end


end

function imgOut = applyPropFilt(imgs,oper,type,params,impath)

imgIn = imgs{end}; % current image
nIms = length(imgs); % no. of images;
% Check image type
if ~isBW(imgIn)
    imWarnMsg(oper,'BW')
    imgOut = imgIn;
    return
end


switch type
    case "bwpropfilt"
        % Convert params array to params accepted by bwpropfilt
        filtparms = getFiltParms(params);
        
        imgOut = bwpropfilt(imgIn,oper,filtparms{:});
    case "bwpropfiltI"
        % get image to filter on. It can be a previous image in ims or the
        % name of an image with the same resolution stored in the same
        % directory as the Segmentation schedule.
        
        [filtim] = getPriorImage(imgs,params{1},impath);
        
        % process channel specification
        channel = params{2}; % valid channel types are R, G, B, or all
        if strcmpi(channel,'all')
            filtim = rgb2gray(filtim);
        else
            try
                filtim = getImChannel(filtim,channel);
            catch
                warning('Invalid Channel specifier. No filter applied')
                imgOut = imgIn;
                return
            end
        end
        
        % Convert params array to params accepted by bwpropfilt
        filtparms = getFiltParms(params(3:end));
        
        imgOut = bwpropfilt(imgIn,filtim,oper,filtparms{:});
    case "otherpropfilts"
        switch oper
            case 'circularity'
                filtparms = getFiltParms(params);
                imgOut = bwcircfilt(imgIn,filtparms{:});

        end
        
end


end

function imgOut = applyMaskOp(imgs,oper,params,impath)
imgIn = imgs{end};

% Check image type
if ~(isRGB(imgIn)||isGray(imgIn)||isBW(imgIn))
    imWarnMsg(oper,{'RGB','grayscale','BW'})
    imgOut = imgIn;
    return
end

% separate mask params from other params.
mask = getPriorImage(imgs,params{1},impath);

remparams = params(2:end);

% reverse the relationship between image and mask. Use the current image as
% a way to mask a referenced image. 
if strcmpi(oper,'asmask') 
    tmask = mask;
    timg = imgIn;
    
    imgIn = tmask;
    mask = timg;
end


% Check mask type
if ~isBW(mask)
    warning('Masks must be binary (BW) images. No changes made')
    imgOut = imgIn;
    return
end

% Confirm that mask and image have the same resolution
if ~sameRez(imgIn,mask)
    warning('Mask and image must have the same resolution. No changes made')
    imgOut = imgIn;
    return
end

switch oper
    case {'mask','asmask'}
        imgOut = maskImage(imgIn,mask,remparams{:});
    case 'cropbymask'
        if ~isBW(imgIn)||~isBW(mask)
            warning('cropbymask requires two mask inputs. No change made')
            imgOut = imgIn;
            return
        end
        
        imgOut = CropComp2Mask(imgIn,mask,remparams{:});
    case 'neighborthresh'
        if ~isBW(imgIn)||~isBW(mask)
            warning('cropbymask requires two mask inputs. No change made')
            imgOut = imgIn;
            return
        end
        
        [~,~,imgOut] = IsNeighbor(imgIn,mask,remparams{:});
end

end

function imgOut = applyImProcess(imgIn,oper,params)
% Check image type
if ~(isRGB(imgIn)||isGray(imgIn)||strcmp(oper,'invert'))
    imWarnMsg(oper,{'RGB','grayscale'})
    imgOut = imgIn;
    return
end

% perform operations
switch oper
    case 'contrast' % apply global or local contrasting to the image. 
        conType = params{1};
        switch conType
            case {'local','Local'}
                imgOut = localcontrast(imgIn,params{2:end});
            case {'global','Global'}
                imgOut = imadjust(imgIn,stretchlim(imgIn));
        end
        
    case 'denoise' % denoise by lightly blurring the image with a median filter.
        kernRad = params{1};
        imgOut = medfilt2(imgIn,[1 1].*kernRad);
        
    case 'flatfield' % flatfield an image to correct uneven illumination.
        sigma = params{1};
        imgOut = imflatfield(imgIn,sigma);
        
    case 'channel' % Select a specific channel of an RGB image.
        if ~isRGB(imgIn)
            imWarnMsg(oper,'RGB')
            imgOut = imgIn;
            return
        end
        
        chann = params{1};
        imgOut = getImChannel(imgIn,chann);
    case 'isolatechann'
        imgOut = imadjust(ChannelIsolate(imgIn,params{1}));
    case 'binarize' % Convert a grayscale image to a binary BW image via thresholding
        if isRGB(imgIn)
            imgIn = rgb2gray(imgIn);
            warning('RGB image converted to grayscale prior to binarization')
        end
        imgOut = imbinarize(imgIn,params{:});
    case 'invert'
        imgOut = iminvert(imgIn);
    case 'threshold'
        imgOut = imthresh(imgIn,params{:});
end
end

function msg = imWarnMsg(oper,validtypes) % Generate a custom warning message.
    if length(validtypes)>2
        typeStr = insertBefore(strjoin(validtypes,', '),validtypes(end),'or ');
    elseif length(validtypes)==2
        typeStr = strjoin(validtypes,' or ');
    else
        typeStr = validtypes;
    end
    
    msg = sprintf('%s operation requires %s image input. No changes made',oper,typeStr);
end

function newparms = getFiltParms(params) % convert filter parameter inputs to inputs for bwpropfilts
        partype = params{1};
        
        switch partype
            case 'gt'
                newparms = {[params{2} inf]};
            case 'lt'
                newparms = {[0 params{2}]};
            case 'range'
                newparms = {[params{2} params{3}]};
            case 'botn'
                newparms = {params{2} 'smallest'} ;
            case 'topn'
                newparms = params(2);
        end
end

function [filtim] = getPriorImage(imgs,imSpec,impath)
    % access a previous image in the segmentation scheme or another image in the raw images directory. 
         nIms = length(imgs); % no. of images;
         imgIn = imgs{end};
        if isnumeric(imSpec) % handle image id instance
            imID = imSpec+1;
            if ismember(imID,1:(nIms-1)) % valid string to previous image.
            
                filtim = imgs{imID}; % filter image
                if (~isRGB(filtim)&&~isGray(filtim))
                    warning('Filter image must be grayscale or RGB. No filter applied.')
                    imgOut = imgIn;
                    return
                end
            else
                warning('Invalid image ID. No filter applied')
                imgOut = imgIn;
                return
            end
        elseif ischar(imSpec) % handle image file instance.
            imID = imSpec;
            if exist(fullfile(impath,imID),'file')==2
                filtim = imread(fullfile(impath,imID));
            end
        end
end

function [maskedim] = maskImage(img,mask,varargin)
p = inputParser;
addRequired(p,'img');
addRequired(p,'mask');
addOptional(p,'invert','',@ischar);

parse(p,img,mask,varargin{:});

DoInvert = p.Results.invert;

if isRGB(img) % duplicate the max for each channel in an rgb image.
    mask = repmat(mask,[1 1 3]);
end 

maskedim = img;
if strcmp(DoInvert,'invert')
    maskedim(mask)=0;
elseif strcmp(DoInvert,'')
    maskedim(~mask)=0;
else
    warning('Invalid masking parameter. No mask applied')
    maskedim = img;
end

end
