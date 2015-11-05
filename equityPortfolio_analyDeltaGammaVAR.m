function VAR = equityPortfolio_analyDeltaGammaVAR(CI,holdingTdays,combinedEquityPortfolio,valuationDate,workbookSheetNames,workbookDates)
    dates = returnDates(combinedEquityPortfolio.pricesSheet,workbookSheetNames,workbookDates);
    valDateIndex = find(dates == valuationDate);
    
    RFreturns = log(combinedEquityPortfolio.RF((valDateIndex-252):(valDateIndex-1),:)./combinedEquityPortfolio.RF((valDateIndex-251):valDateIndex,:));

    alpha = norminv(CI);
    covars = cov(RFreturns);
    
    S = combinedEquityPortfolio.RF(valDateIndex,:);
    xdelta = transpose(combinedEquityPortfolio.DeltasAndLinearPos.*S);
    
    S2 = transpose(combinedEquityPortfolio.RF(valDateIndex,:).*combinedEquityPortfolio.RF(valDateIndex,:));
    gammaCovarS2 = diag(combinedEquityPortfolio.Gammas)*covars*S2;
    
    VAR = alpha*sqrt(holdingTdays)*sqrt(xdelta'*covars*xdelta + 0.5*gammaCovarS2'*gammaCovarS2); 
end