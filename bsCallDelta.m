function d = bsCallDelta(spot, strike, rate, div, vol, expiry)
% BSCALLDELTA: Black-Scholes delta of a European call option
%
% usage: 
%           d = bsCallDelta( S, K, r, q, vol, T )
%
% input:
%           S:      spot price of the underlying asset, S>0
%           K:      strike of the call option, K>0
%           r:      risk-free interest rate
%           q:      underlying asset's continuous dividend yield
%           vol:    asset's volatility
%           T:      time until the option's expiry date
%
% output:
%           d:      the call's delta
%
% Jeff Dewynne, January 2008
%

    % MATLAB doesn't have the normal cumulative density function
    NC = @(x) erfc(-x/sqrt(2))/2;
    
    tmp1 = log( spot ./ strike );
    tmp2 = ( rate - div ) .* expiry;
    tmp3 = ( vol .^ 2 ) .* expiry;
    
    d1 = ( tmp1 + tmp2 + tmp3/2 ) ./ sqrt(tmp3);
    
    d =  exp(  -div .* expiry ) .* NC( d1 ) ;

end