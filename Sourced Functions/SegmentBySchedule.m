function [imOut,ims] = SegmentBySchedule(varargin)
%SEGMENTBYSCHEDULE segment an an image according to a prescribed schedule. 
%   Detailed explanation goes here
%% parse inputs
p=inputParser;

% Raw Image Input
checkim = @(x) (isa(x,'uint8')|islogical(x))|isempty(x);
addOptional(p,'RawImage',[],checkim);

% Schedule Input
checkSched = @(x) istable(x)|isempty(x);
addOptional(p,'Schedule',[],checkSched);

parse(p,varargin{:});

RawImage = p.Results.RawImage;
Schedule = p.Results.Schedule;

% UI read images if not provided as inputs to SEGMENTBYSCHEDULE.
if isempty(RawImage)
    [imfile,impath] = uigetfile({'*.png;*.jpg;*.bmp'});
end
RawImage = imread(fullfile(impath,imfile));

if isempty(Schedule)
    [schedfile,schedpath] = uigetfile({'*.mat;*.xlsx'},...
        'Select Segmentation Schedule',impath);
    [~,schedname,schedext] = fileparts(schedfile);
end

schedfpath = fullfile(schedpath,schedfile);
switch schedext
    case '.xlsx'
        [~,~,rawsched] = xlsread(schedfpath);
    case '.mat'
end

%% Prepare Segment By Schedule
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

%% Define operation categories
% morphological operations that use the bwmorph function.
bwmorphops = {'remove','skel','bothat','bridge','clean','thicken',...
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
maskops = {'mask','remcontact','neighbordist'}';

% Basic image processing operations.
imops = {'contrast','denoise','flatfield','channel','threshold','invert'}';

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
ims{1}=RawImage; % Initialize image
for k=2:nsteps+1
    curOp = SegT.Oper{k-1};
    curParams = SegT.Params{k-1};
    curType = opTbl.type(find(strcmp(opTbl.oper,curOp)));
    
    ims{k} = applyOperation(ims,curOp,curType,curParams,impath);
    % pass all images to apply Operation so that they can be used in
    % various operations.
end
imOut = ims{end}; % Final Output
end

function imgOut = applyOperation(imgs,oper,type,params,impath)
switch type
    case {"bwmorph","othermorph"}
        imgOut = applyMorphOp(imgs{end},oper,type,params);
    case {"otherpropfilts","bwpropfilt","bwpropfiltI"}
        imgOut = applyPropFilt(imgs,oper,type,params,impath);
    case "mask"
        % set mask 
        imgOut = applyMaskOp(imgs{end},oper,mask);
    case "impro"
        imgOut = applyImProcess(imgs{end},oper,params);
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
                imgOut = imclose(imgIn,kern);
            case 'open'
                kern = strel('disk',params{1});
                imgOut = imopen(imgIn,kern);
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
        
        if isnumeric(params{1}) % handle image id instance
            imID = params{1}+1;
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
        elseif ischar(params{1}) % handle image file instance.
            imID = params{1};
            if exist(fullfile(impath,imID),'file')==2
                filtim = imread(fullfile(impath,imID));
            end
        end
        
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
    case "otherpropfilt"
        switch oper
            case 'circularity'
        end
        
end


end

function imgOut = applyMaskOp(imgIn,oper,mask)
% Check image type
if ~(isRGB(imgIn)||isGray(imgIn)||isBW(imgIn))
    imWarnMsg(oper,{'RGB','grayscale','BW'})
    imgOut = imgIn;
    return
end

% Check mask type
if ~isBW(mask)
    warning('Masks must be binary (BW) images. No changes made')
    imgOut = imgIn;
    return
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
            case 'local'
                imgOut = localcontrast(imgIn,params{2:end});
            case 'global'
                imgOut = imadjust(imgIn);
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
        
    case 'threshold' % Convert a grayscale image to a binary BW image via thresholding
        if isRGB(imgIn)
            imgIn = rgb2gray(imgIn);
            warning('RGB image converted to grayscale prior to thresholding')
        end
        imgOut = imbinarize(imgIn,params{:});
    case 'invert'
        imgOut = iminvert(imgIn);
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