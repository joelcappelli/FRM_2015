function p = bsPutPrice(spot, strike, rate, div, vol, expiry)
% BSPUTPRICE: Black-Scholes price of a European put option
%
% usage: 
%           p = bsPutPrice( S, K, r, q, vol, T )
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
%           p:      the put's price
%
% Jeff Dewynne, January 2008
%

    if (expiry <= 0)
        p = max(strike-spot,0);
    else
        % MATLAB doesn't have the normal cumulative density function
        NC = @(x) erfc(-x/sqrt(2))/2;
    
        tmp1 = log( spot ./ strike );
        tmp2 = ( rate - div ) .* expiry;
        tmp3 = ( vol .^ 2 ) .* expiry;
    
        d1 = ( tmp1 + tmp2 + tmp3/2 ) ./ sqrt(tmp3);
        d2 = ( tmp1 + tmp2 - tmp3/2 ) ./ sqrt(tmp3);
    
        p = - spot .* exp(  -div .* expiry ) .* NC( -d1 ) ...
          + strike .* exp( -rate .* expiry ) .* NC( -d2 );
    end
end