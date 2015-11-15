function VAR = FXPortfolio_analyExactVAR(FX_Portfolio, CI, holdingTdays,workbookSheetNames,workbookDates,valuationDate)
    alpha = norminv(CI);
    valDateIndex = find(returnDates(FX_Portfolio.exchaRateSheet,workbookSheetNames,workbookDates) == valuationDate);
    
    %daily returns
    periods = 1000;
    RFdailyReturns = RFreturns(FX_Portfolio.RF(1:valDateIndex,:),periods,1,'reldiff');%log(FX_Portfolio.RF((valDateIndex-periods):(valDateIndex-1),:)./FX_Portfolio.RF((valDateIndex-(periods-1)):valDateIndex,:));
    %RFdailyReturns = diff(FX_Portfolio.RF((valDateIndex-251):valDateIndex,:))./FX_Portfolio.RF((valDateIndex-250):valDateIndex,:);%log(FX_Portfolio.RF((valDateIndex-252):(valDateIndex-1),:)./FX_Portfolio.RF((valDateIndex-251):valDateIndex,:));

    avReturns = mean(RFdailyReturns);
    covars = cov(RFdailyReturns);
    mu    = sum(FX_Portfolio.weights.*avReturns);
    sigma = sqrt( FX_Portfolio.weights * covars * FX_Portfolio.weights' );
    VAR = -sqrt(holdingTdays)*FX_Portfolio.Price*(mu - sigma * alpha);
end