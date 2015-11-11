function [] = drawPNL_Histogram(dP,plotTitle)    
figure;
[hp, xp] = hist(dP,51);
bar(xp,hp,'r','edgeColor','w');
xlabel('P&L','fontSize',15);
ylabel('pdf','fontSize',15);
title(strcat('P&L distribution: ',plotTitle));
end