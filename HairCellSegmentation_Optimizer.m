RAW = imread('Data\RAW.png');
Control = ~imread('Data\RAW_HairCells.bmp');
Control = imclearborder(Control);

MedFilt=15;
FlatField = 100;
Thresh = 0.2;
CLRads = 1:10;
OPRads = 1:10;
DILRads = 1:10;
MinAvgI = 15;

nsims = length(MedFilt)*length(FlatField)*length(Thresh)*length(CLRads)*...
    length(OPRads)*length(DILRads)*length(MinAvgI);
T=table('Size',[nsims 15],'VariableTypes',repmat({'double'},[1 15]),...
    'VariableNames',{'MedFilt','FlatField','Thresh','CLRads','OPRads',...
    'DILRads','MinAvgI','Sensitivity','Specificity','Precision','F1Score',...
    'TruePos','FalsePos','FalseNeg','TrueNeg'});

cnt = 0;
simtime=[];
f = waitbar(0,'Running Optimization');
for kMF = 1:length(MedFilt)
    for kFF = 1:length(FlatField)
        for kTHR = 1:length(Thresh)
            for kCL = 1:length(CLRads)
                for kOP = 1:length(OPRads)
                    for kDil = 1:length(DILRads)
                        for kMinAvI = 1:length(MinAvgI)
                            tic
                            cnt=cnt+1;
                            
                            temp.MedFilt = MedFilt(kMF);
                            temp.FlatField = FlatField(kFF);
                            temp.Thresh = Thresh(kTHR);
                            temp.CLRads = CLRads(kCL);
                            temp.OPRads = OPRads(kOP);
                            temp.DILRads = DILRads(kDil);
                            temp.MinAvgI = MinAvgI(kMinAvI);
                            
                            [~,ImDat] = SelectHairCell(RAW,'MedFilt',temp.MedFilt,...
                                'FlatField',temp.FlatField,...
                                'BWThresh',temp.Thresh,...
                                'CloseRad',temp.CLRads,...
                                'OpenRad',temp.OPRads,...
                                'DilateRad',temp.DILRads,...
                                'MinAvgInt',temp.MinAvgI,...
                                'EllipApprox',false,...
                                'Suppress',true);
                            
                            Test = ImDat.HairCellMask;
                            Stats = SegCompare(Control,Test);
                            simtime(cnt)=toc;
                            
                            T(cnt,:) = [struct2table(temp) struct2table(Stats)];
                            
                            timerem = (nsims-cnt).*mean(simtime)/60; 
                            waitbar(cnt/nsims,f,sprintf('Time Rem: %3.1f min',timerem))
                        end
                    end
                end
            end
        end
    end
end
close(f)
% [~,ImDat] = SelectHairCell(RAW);
% Test = ImDat.HairCellMask;

% Stats = SegCompare(Control,Test);

%% Preview
tgt = T(832,:);
[~,ImDat] = SelectHairCell(RAW,'MedFilt',tgt.MedFilt,...
                                'FlatField',tgt.FlatField,...
                                'BWThresh',tgt.Thresh,...
                                'CloseRad',tgt.CLRads,...
                                'OpenRad',tgt.OPRads,...
                                'DilateRad',tgt.DILRads,...
                                'MinAvgInt',tgt.MinAvgI,...
                                'EllipApprox',false,...
                                'Suppress',true);
imshowpair(ImDat.HairCellMask,Control);

ImDat = SelectHairCell(RAW);