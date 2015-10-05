function g = bsGamma(S, K, r, q, vol, T)
% BSCALLGAMMA: the Black-Scholes gamma for a European option
%
% usage:
%           g = bsGamma(S, K, r, q, vol, T)
%
% input:
%           S:      the current spot price of the underlying
%           K:      the option's strike
%           r:      the risk-free rate
%           q:      the continuous dividend yield
%           vol:    the volatility
%           T:      time until expiry
%           callOrPut: call or put indicator; 1 or -1 respectively
%
% output:
%           g:      the Black-Scholes gamma
%
% Jeff Dewynne, January 2008
%

    if (T <= 0)
        g = 0;
    else
        d1 = log(S ./ K) + (r - q + vol .^2 / 2) .* T;
        d1 = d1 ./ sqrt( vol .^2 .* T );
        g = exp(-q .* T - d1 .^ 2 / 2 ) ./ (vol .* S .* sqrt(2*pi*T));
    end
end