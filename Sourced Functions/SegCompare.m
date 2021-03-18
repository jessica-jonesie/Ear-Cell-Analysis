function [Stats] = SegCompare(controlMask,testMask)
%SegCompare compare segmentation masks to assess similarity and evaluate
%segmentation sensitivity and specificity. 
%   Detailed explanation goes here
TPMask = controlMask.*testMask; % True Positive entries
FPMask = testMask-controlMask; % False Positive entries
FPMask(FPMask<0)= 0; 

FNMask = controlMask-testMask; % False Negative entries
FNMask(FNMask<0) = 0;

TNMask = true(size(controlMask))-TPMask-FPMask-FNMask;
TNMask(TNMask<0)=0;

%% Count Pixels
TP = sum(TPMask(:));
FP = sum(FPMask(:));
FN = sum(FNMask(:));
TN = sum(TNMask(:));

Stats.Sensitivity = TP/(TP+FN);
Stats.Specificity = TN/(TN+FP);
Stats.Precision = TP/(TP+FP);
Stats.F1Score = 2*TP/(2*TP+FP+FN);

Stats.TruePos = TP;
Stats.FalsePos = FP;
Stats.FalseNeg = FN;
Stats.TrueNeg =TN;
end