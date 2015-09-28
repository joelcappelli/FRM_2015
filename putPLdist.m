%
% this script shows the distribution of PL for a put option assuming the
% PL for the underlying asset is normally distributed
%

dt     = 1/250;       % one trading day
daysToExpiry = 10;    % number of days to expiry

spot   = 100;     % current spot price
strike = 100;     % option's strike
rate   = 0.05;    % risk-free rate
div    = 0.0;     % assume no dividends
vol    = 0.4;     % underlying's volatility, PER ANNUM

expiry = daysToExpiry*dt;    % option's expiry date

% work out the price of a call option with these parameters
putPrice = bsPutPrice(spot, strike, rate, div, vol, expiry);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mu     = 0.10;    % underlying asset's ANNUAL growth rate

sims   = 100000;  % number of price changes to simulate

dayMu  = mu * dt;   % get the daily expected change
dayVol = vol * dt;  % and volatility

% simulate the daily changes in the spot price
dS = spot * ( dayMu + sqrt( dayVol )*randn(sims,1) );

% simulate the spot prices at expiry
ST = repmat(spot,size(dS)) + dS;

% work out the change in the option value
expiry1 = expiry-dt;
if (expiry1 > 0) 
    dV = bsPutPrice(ST, strike, rate, div, vol, expiry1) - putPrice;
else
    dV = bsPutPayoff(ST, strike) - putPrice;
end
    
% create a histogram of the changes in the spot price
[Sh, Sx] = hist( dS, 51 );
% turn it into a pdf by scaling
Sh = Sh / ( sum(Sh)*(Sx(2)-Sx(1)) );
% create a histogram of the changes in the option price
[Vh, Vx] = hist( dV, 51 );
Vh = Vh / ( sum(Vh)*(Vx(2)-Vx(1)) );

clf reset
hold off

% draw the option changes as a histogram
bar(Vx, Vh, 'b', 'edgeColor', 'w');

% draw the share changes as a line, ON THE SAME GRAPH
hold on
plot(Sx, Sh, 'r-', 'lineWidth', 2);

xlabel('One day P&L','fontSize',15);
ylabel('probability density','fontSize',15);
legend('Option','Put','location','NW');

hold off