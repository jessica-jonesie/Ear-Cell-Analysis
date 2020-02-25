function [CellProps] = CorrectPolarity(CellProps)
%CORRECTPOLARITY Correct or omit polarities greater than 1. 
%   Detailed explanation goes here
incorrectMIPID = CellProps.CombinedPolarity>1;
incorrectMIPDat = CellProps(incorrectMIPID ,:);
[correctMIPDat] = VCellManAnnot(incorrectMIPDat);
CellProps(incorrectMIPID,:) = correctMIPDat;
CellProps.CombinedPolarity(CellProps.CombinedPolarity>1)= NaN;
end

