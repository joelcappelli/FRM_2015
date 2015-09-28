function po = bsCallPayoff(spot, strike)
% BSCALLPAYOFF: the payoff for a call option
%
% usage:
%           po = bsCallPayoff( S, K )
%
% input:
%           S:  the underlying spot price at expiry
%           K:  the option's strike
%
% output:
%           po: the call's payoff
%
% Jeff Dewynne, January 2008
%

    fd = spot - strike;
    po = max( fd, zeros(size(fd)) );

end