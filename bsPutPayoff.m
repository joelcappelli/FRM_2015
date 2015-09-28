function po = bsPutPayoff(spot, strike)
% BSPUTPAYOFF: the payoff for a put option
%
% usage:
%           po = bsPutPayoff( S, K )
%
% input:
%           S:  the underlying spot price at expiry
%           K:  the option's strike
%
% output:
%           po: the put's payoff
%
% Jeff Dewynne, January 2008
%

    fd = strike - spot;
    po = max( fd, zeros(size(fd) ));

end