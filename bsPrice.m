function p = bsPrice(spot, strike, rate, div, vol, expiry, callOrPut)
% BSCALLPRICE: Black-Scholes price of a European call option
%
% usage: 
%           c = bsPrice( S, K, r, q, vol, T ,callOrPut)
%
% input:
%           S:      spot price of the underlying asset, S>0
%           K:      strike of the call option, K>0
%           r:      risk-free interest rate
%           q:      underlying asset's continuous dividend yield
%           vol:    asset's volatility
%           T:      time until the option's expiry date
%           callOrPut: call or put indicator; 1 or -1 respectively
%
% output:
%           p:      the price
%
% Jeff Dewynne, January 2008
%

    if ( expiry <= 0)
        p = max(callOrPut*(spot-strike), 0);
    else
        % MATLAB doesn't have the normal cumulative density function
        NC = @(x) erfc(-x/sqrt(2))/2;
    
        tmp1 = log( spot ./ strike );
        tmp2 = ( rate - div ) .* expiry;
        tmp3 = ( vol .^ 2 ) .* expiry;
    
        d1 = ( tmp1 + tmp2 + tmp3/2 ) ./ sqrt(tmp3);
        d2 = ( tmp1 + tmp2 - tmp3/2 ) ./ sqrt(tmp3);
    
        p =   callOrPut.*spot .* exp(  -div .* expiry ) .* NC( callOrPut.*d1 ) ...
          - callOrPut.*strike .* exp( -rate .* expiry ) .* NC( callOrPut.*d2 );
    end
end