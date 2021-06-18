clc; clear; close all;

addpath('Source Images')
addpath('Sourced Functions')
addpath('Data')
addpath('Results')

[file,path] = uigetfile('*.mat');
load(fullfile(path,file));

roots = inputdlg('Set Root Name:','Input',4,{erase(file,'.mat')});
rootfile = [roots{1} '_Results'];
mkdir(rootfile);

root = fullfile(rootfile,roots{1});


[TypeID,ntypes,types] = GetTypeIDs(CellProps,'Type');

%% Define various colormaps and other display parameters
OrientColMap = flipud(cbrewer('div','RdYlBu',64));
PolarMap = cbrewer('seq','YlOrRd',64);
haircolor = hex2rgb('#e66101');
supportcolor = hex2rgb('#5e3c99');

TypeMap = MyBrewerMap('qual','Set2',ntypes);

%% Histograms
figure
[ha] = HistArray(CellProps,'NormOrientationR','Type',...
    'histtype','polar','splitcolors',TypeMap);
sgtitle('Normalized Orientation')
print(gcf,'-dpdf',[root '_OrientationHistogram.pdf'])

% Polarity Histograms
figure
[hb] = HistArray(CellProps,'Polarity','Type','splitcolors',TypeMap,...
    'fixmax',true,'xlabel','Polarity','nullpolarity',true);
sgtitle('Polarity')
print(gcf,'-dpdf',[root '_PolarityHistogram.pdf'])
close all
%% Model Cell Array
figure
[hc] = ModelCellArray(CellProps,'Type','fixmax',true);
export_fig(gcf,[root '_ModelCell_FixedMax'],'-pdf')

figure
[hc] = ModelCellArray(CellProps,'Type');
export_fig(gcf,[root '_ModelCell'],'-pdf')

close all
%% Individual Files
for k = 1:length(poolIms)
    
    ImDat = poolIms{k};
    TempProps = poolProps{k};
    curType = TempProps.Type{1};
    curRep = num2str(TempProps.Replicate(1));
    
    figure
    imshow(ImDat.RAW)
    hold on
    visboundaries(bwboundaries(ImDat.CellMaskR),'Color','w','Linewidth',0.5);
    title(curType)
    export_fig(gcf,[root '_' curType '_' curRep '_CellOverlay'],'-pdf')
    
    figure
    VectorOverlayMap(ImDat,TempProps,'Type','splitcolors',[1 1 1]);
    title(curType)
    export_fig(gcf,[root '_' curType '_' curRep '_VectorOverlay'],'-pdf')
    
    %% Orientation Map
    ImDat.(['R' curType 'CellMask']) = ImDat.CellMaskR;
    DataMapArray(ImDat,TempProps,'NormOrientation180','Type','cmap',OrientColMap,'varlims',[0 180])
    title(curType)
    export_fig(gcf,[root '_' curType '_' curRep '_OrientationMap'],'-pdf')
    
    %% Polarity Map
    ImDat.(['R' curType 'CellMask']) = ImDat.CellMaskR;
    DataMapArray(ImDat,TempProps,'Polarity','Type','cmap',PolarMap,'varlims',[0 1])
    title(curType)
    export_fig(gcf,[root '_' curType '_' curRep '_PolarityMap'],'-pdf')
    
    close all
end

%% Angle K
% If it isn't already done, perform angle K now. 
if ~exist('AngK','var')  
    scales = (50:50:1000)';
    alpha = 0.01;

    for k = 1:length(types)
        curType = types(k);
        kID = CellProps.Type==curType;
        replicates = unique(CellProps.Replicate(kID));

        for n = 1:length(replicates)
            nkID = kID&CellProps.Replicate==replicates(n);

            hvec.origin = CellProps.Center(nkID,:);
            hvec.angle = CellProps.OrientationR(nkID);
            hvec.magnitude = ones(sum(nkID),1);

            [K(n,:),Ori{n,k}] = AngleK(scales,hvec,hvec); 
            [~,KsimMax(n,:),KsimMin(n,:),] = AngleK_Env(scales,hvec,alpha);
            a=1;
        end
        KPool{k} = mean(K,1);
        KsimMaxPool{k} = max(KsimMax,[],1);
        KsimMinPool{k} = min(KsimMin,[],1);

        % Because AngleK is the mean of a set of alignments. We can find pooled
        % AngleK values by averaging them again. (if it wasn't a simple mean
        % you'd have to pool the alignments first, then compute AngleK based 
        % on the pooled set). Similarly, we can find the max of KsimMax and
        % KsimMin.
        a=1;
    end
    AngK.KPool = KPool;
    AngK.KsimMaxPool = KsimMaxPool;
    AngK.KsimMinPool = KsimMinPool;
    AngK.Ori = Ori;
    AngK.scales = scales;
    AngK.types = types;
    AngK.alpha = alpha;

    save(fullfile(path,file),'AngK','-append');
end
close all
%% Angle K Plot
[sprows,spcols] = squaresubplotdims(length(AngK.types)); % Approximately square array.
ha = tight_subplot(sprows,spcols,0.1,0.1,0.1);
lwd = 2;

maxy = ceil(11*max(abs([cell2mat(AngK.KPool)...
    cell2mat(AngK.KsimMaxPool)...
    cell2mat(AngK.KsimMinPool)])))/10;

for n=1:length(AngK.types)
    axes(ha(n))
    lincolor = TypeMap(n,:);
    plot(AngK.scales,AngK.KPool{n},'Color',lincolor,'LineWidth',lwd)
    hold on
    plot(AngK.scales,AngK.KsimMaxPool{n},'Color',lincolor,...
        'LineStyle','--','LineWidth',lwd/2)
    plot(AngK.scales,AngK.KsimMinPool{n},'Color',lincolor,...
        'LineStyle','--','LineWidth',lwd/2)
    title(AngK.types(n))
    ylim([-1 1].*maxy)
    xlim(AngK.scales([1 end])');
end

export_fig(gcf,[root '_AngleK'],'-pdf')
close all
%% Orientation Maps

scaleID = [2 10];

for m = 1:length(scaleID)
    cnt = 0;
    for k = 1:length(types)
            curType = types(k);
            kID = CellProps.Type==curType;
            replicates = unique(CellProps.Replicate(kID));
            for n = 1:length(replicates)
                cnt= cnt+1;
                ImDat = poolIms{cnt};

                Ori = AngK.Ori{n,k};
                DataMap(ImDat.CellMaskR,Ori(:,scaleID(m)));
                cax=colorbar;
                colormap(OrientColMap)
                caxis([-1 1])
                ylabel(cax,sprintf('Alignment at r=%d',AngK.scales(scaleID(m))))
                title(strcat(curType,'-',num2str(n)))
                
                % Turn off axes
                ax = gca;
                ax.XTick = [];
                ax.YTick = [];
                
                savename = strjoin({root,char(curType),num2str(n),'Alignment',num2str(AngK.scales(scaleID(m)))},'_');
                export_fig(gcf,savename,'-pdf')

            end
    end
end
close all  