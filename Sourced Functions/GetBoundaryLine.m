function [BoundPts,UserPts,fH,ax] = GetBoundaryLine(im,varargin)
%GETBOUNDARYLINE manually select boundary line for vestibular system
%analysis
%   [BoundPts,UserPts] = GetBoundaryLine(im) displays the image and prompts
%   the user to click to define the boundary, by default adds padding to
%   the edge of the image to permit the boundary to exceed the image
%   bounds. Additionally, a default cubic interpolation is applied.
%   BoundPts is the calculated boundary line with the interpolation,
%   UserPts are the coordinates of the points the user selected. 
%
%   [BoundPts,UserPts] = GetBoundaryLine(im,'Interp','none') turns off
%   interpolation and returns exactly the points the user selected.
%
%   BoundPts = GetBoundaryLine(im,'ndiv',50) by default the number of
%   divisions between user selected points used in interpolation is 20.
%   Specify the ndiv argument to change this number. 
%
%   BoundPts = GetBoundaryLine(im,'pad',false) turn off the image padding
%   that is on by default. 
%
%   BoundPts = GetBoundaryLine(im,'closeselection',true) by default the
%   selection is not closed. To close the selection pass true with the
%   close selection argument. 
%
%
%% parse inputs
p = inputParser;
addRequired(p,'im')
validInterps = {'none','cubic'};
checkInterp = @(x) any(validatestring(x,validInterps));
addParameter(p,'Interp','cubic',checkInterp);
addParameter(p,'ndiv',20,@isnumeric);
addParameter(p,'pad',true,@islogical);
addParameter(p,'closeselection',false,@islogical);
addParameter(p,'preview',false,@islogical);

parse(p,im,varargin{:});

Interp = p.Results.Interp;
ndiv = p.Results.ndiv;
pad = p.Results.pad;
closeselection=p.Results.closeselection;
preview = p.Results.preview;
[imx,imy,imz]=size(im);

%% pad if requested
if pad
    padsize = [ceil(imx/10) ceil(imy/10) 0];
    im = padarray(im,padsize,0);
end

%%
answer = 'No';
while strcmp(answer,'No')
fH=figure;
ax=imshow(im);
roi=drawpolyline;
UserPts = roi.Position;
% xq = linspace(UserPts(1,1),UserPts(end,1),npts);
close(fH);

%% Compute interpolation
switch Interp
    case 'none'
        BoundPts = UserPts;
    case 'cubic'
      xy = UserPts';
    %
    %  Repeat the first column at the end so the polygon closes.
    if closeselection
      xy = [ xy, [ xy(:,1) ] ];
    end

      [ m, n ] = size ( xy );
    %
    %  Consider the point index 1:N as the independent variable for X and Y.
    %
      s = ( 1 : n )';
    %
    %  Prepare to evaluate the spline function at a grid 20 times finer.
    %
      t = ( 1 : 1/ndiv : n )';
    %
    %  Compute splines U and V that treat X and Y as functions of the index.
    %
      u = spline ( s, xy(1,:), t );
      v = spline ( s, xy(2,:), t );
      
    BoundPts = [u v];
    

end

%% Preview results
fH2 = figure;
imshow(im)
hold on
plot(BoundPts(:,1),BoundPts(:,2),'-r')
plot(UserPts(:,1),UserPts(:,2),'.b','MarkerSize',15)

answer = questdlg('Accept?', ...
    'Boundary Line Interpolation', ...
    'Yes','No','Cancel','Cancel');
close(fH2)
end

%% correct padding
BoundPts = BoundPts-padsize(1:2);
end

