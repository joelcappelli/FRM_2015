function VAR = equityPortfolio_analyDeltaGammaVAR(CI,holdingTdays,combinedEquityPortfolio,valuationDate,workbookSheetNames,workbookDates)
    dates = returnDates(combinedEquityPortfolio.pricesSheet,workbookSheetNames,workbookDates);
    valDateIndex = find(dates == valuationDate);
    
    %daily returns
    periods = 1000;
    RFreturns_ = RFreturns(combinedEquityPortfolio.RF(1:valDateIndex,:),periods,1,'reldiff');
    
    %periods = 252;
    %RFreturns_ = log(combinedEquityPortfolio.RF((valDateIndex-periods):(valDateIndex-1),:)./combinedEquityPortfolio.RF((valDateIndex-(periods-1)):valDateIndex,:));   
    
    alpha = norminv(CI);
    covars = cov(RFreturns_);
    
	S = combinedEquityPortfolio.RF(valDateIndex,:);
	xdelta = transpose(combinedEquityPortfolio.DeltasAndLinearPos.*S);
        
    S2 = transpose(combinedEquityPortfolio.RF(valDateIndex,:).*combinedEquityPortfolio.RF(valDateIndex,:));
    gammaCovarS2 = diag(combinedEquityPortfolio.Gammas)*covars*S2;
    
    VAR = alpha*sqrt(holdingTdays)*sqrt(xdelta'*covars*xdelta + 0.5*(gammaCovarS2')*gammaCovarS2); 
end