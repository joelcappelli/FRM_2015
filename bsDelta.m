function d = bsDelta(spot, strike, rate, div, vol, expiry, callOrPut)
% BSCALLDELTA: Black-Scholes delta of a European option
%
% usage: 
%           d = bsCDelta( S, K, r, q, vol, T , callOrPut)
%
% input:
%           S:      spot price of the underlying asset, S>0
%           K:      strike of the option, K>0
%           r:      risk-free interest rate
%           q:      underlying asset's continuous dividend yield
%           vol:    asset's volatility
%           T:      time until the option's expiry date
%           callOrPut: call or put indicator; 1 or -1 respectively
% output:
%           d:      the bs delta
%
% Jeff Dewynne, January 2008
%

    % MATLAB doesn't have the normal cumulative density function
    NC = @(x) erfc(-x/sqrt(2))/2;
    
    tmp1 = log( spot ./ strike );
    tmp2 = ( rate - div ) .* expiry;
    tmp3 = ( vol .^ 2 ) .* expiry;
    
    d1 = ( tmp1 + tmp2 + tmp3/2 ) ./ sqrt(tmp3);
    
    d =  callOrPut.*exp(  -div .* expiry ) .* NC( callOrPut.*d1 ) ;

end