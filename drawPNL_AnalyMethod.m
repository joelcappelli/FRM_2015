function [] = drawPNL_AnalyMethod(av,var,title)    
   
d = av - var;                           % choose sensible
xMin = min(av - d - stdv,av-4*stdv);    % scales for the 
xMax = max(av + d + stdv,av+4*stdv);    % x-axis
xx = linspace(xMin,xMax,201);           % generate x points
pdf = exp( -(xx-av).^2 / (2*stdv^2) ) / (sqrt(2*pi)*stdv);  % find the normal distribution at the x-points
pdfMax = max(pdf);                      % need this to scale the y-axis

figure;
plot(xx,pdf,'-','color',[0.0,0.6,0.0],'lineWidth',2);    % plot the normal distribution
hold on;                            % don't clear the graphs already drawn
plot([var, var], [-pdfMax/10,pdfMax],'k--','lineWidth',2); % plot the var value
legend('P/L distribution','VaR');   % put in a legend
hold on;
title(title);

lv = (xx < var);        % index the x-values that are less than the var
xv = [xx(1),xx(lv),var,var];  % create vertices of a polygon around the pdf where
yv = exp( -(xv-av).^2 / (2*stdv^2) ) / (sqrt(2*pi)*stdv); % it is less than the var
yv(1) = 0;
yv(end) = 0;
fill(xv,yv,'r');    % shade the part of the histogram < var in red

% the following two lines simply redraw parts of the graph that had to
% be drawn first, because of the way legend(...) works, but may have 
% subsequently be drawn over 
plot(xx,pdf,'-','color',[0.0,0.6,0.0],'lineWidth',2); 
plot([var, var], [-pdfMax/10,pdfMax],'k--','lineWidth',2);

% put in some axes
plot([xMin,xMax],[0,0],'k-');                   % x-axis
plot([av, av],[-pdfMax/5,pdfMax*1.2],'k-');     % vertical line thru' the mean
    
end