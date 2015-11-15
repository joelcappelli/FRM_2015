function [] = drawPNL_HistogramPlotWithNorm(VaR,pl,confidence,plotTitle)    

av = mean(pl);                       % average P/L
stdv = std(pl);                       % standard deviation of P/L

nVaR = av - stdv * norminv(confidence);
% this is the VaR we'd get if we assumed normally distributed returns
pts = length(pl);
%d = av - VaR                           % this stuff just generates
xMin = av-4*stdv;%min(av - d - stdv,av-4*stdv)    % a sensible range of values
xMax = av+4*stdv;%max(av + d + stdv,av+4*stdv)    % to plot the graph on
xBins = linspace(xMin,xMax,51);         % choose 50 equally spaced bins on this range
[h, x] = hist(pl,xBins);                % generate the histogram
h = h/(pts*(x(2)-x(1)));               % scale the histogram so its area is 1
xx = linspace(xMin,xMax,201);           % generate x points for the exact pdf
pdf = exp( -(xx-av).^2 / (2*stdv^2) ) / (sqrt(2*pi)*stdv); % generate the normal pdf
pdfMax = max(max(pdf),max(h));                      % use thisfor scaling the graph

figure;
plot(xx,pdf,'--','color',[0.0,0.6,0.0], 'lineWidth', 2); % this draws the exact normal distribution
hold on;    % don't erase anything
bar(x,h,'b','edgecolor','w');   % draw the scaled histogram
plot([VaR, VaR], [-0.1*pdfMax,0.9*pdfMax],'k:','lineWidth',2); % plot the empirical var 
plot([nVaR,nVaR], [-0.1*pdfMax, 0.9*pdfMax], ':', ...
     'color',[0.0,0.6,0.0],'lineWidth',2);
legend('Normal P/L','Empirical P/L','Empirical VaR','Normal VaR');   % put in a legend 

lmv = (x <= VaR );                         % find the bin values that are less than the var
bar(x(lmv),h(lmv),'r','edgeColor','w');     % redraw the histogram at these bin values in red

% the following two lines just redraw things that had to be plotted
% first - or the legend command won't work - but may have been drawn
% over by subsequent plots
plot([VaR, VaR], [-0.1*pdfMax,0.9*pdfMax],'k:','lineWidth',2);    % redraw the var value
plot(xx,pdf,'--','color',[0.0, 0.6, 0.0], 'lineWidth', 2);      % redraw the exact pdf

% put in some axes
plot([xMin,xMax],[0,0],'k-');                   % draw a line along the x-axis
plot([av, av],[-0.1*pdfMax,pdfMax*1.1],'k-');     % draw a vertical line at the average

tX = xx(1);
tY = pdfMax;
text(tX,tY,['VaR = ', num2str(VaR,'%.2f')],'fontSize',12, 'fontWeight','bold');
tY = 1.075*pdfMax;
text(tX,tY,['confidence = ',num2str(100*confidence),'%'],'fontSize',12, ...
     'fontWeight','bold');
 hold on;
title(strcat('P&L distribution: ',plotTitle));%strcat('P&L distribution: ',title));
     
end