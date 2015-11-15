function RFret = RFreturns(RF,periods,holdingPeriod,method)

lastIndex = size(RF,1);
%most recent data at end of column vectors

past = (lastIndex-(periods+1)*holdingPeriod):holdingPeriod:(lastIndex-holdingPeriod);
recent = (lastIndex-periods*holdingPeriod):holdingPeriod:lastIndex;

if(strcmpi(method,'log'))
    RFret = log(RF(recent,:)./RF(past,:));
elseif(strcmpi(method,'diff'))
    RFret = diff(RF(recent,:),1);
elseif(strcmpi(method,'relDiff'))
    RFret = diff(RF(recent,:),1)./RF(past(2:end),:);
end

end