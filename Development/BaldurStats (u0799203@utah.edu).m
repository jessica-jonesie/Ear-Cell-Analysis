score = [10 11 12 13 14 15 16 17 18];
pts = [0 1 2 3 5 7 9 11 14];
totPts = 27;

anames = {'STR','DEX','CON','INT','WIS','CHA'};
ascores = [10    16    15    12    12    15]; 

sumpts = 0;
for n =1:length(ascores)
    sumpts = pts(score==ascores(n))+sumpts;
end
sumpts