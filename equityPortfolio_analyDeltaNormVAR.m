function VAR = equityPortfolio_analyDeltaNormVAR(CI,holdingTdays,combinedEquityPortfolio,valuationDate,workbookSheetNames,workbookDates)
    dates = returnDates(combinedEquityPortfolio.pricesSheet,workbookSheetNames,workbookDates);
    valDateIndex = find(dates == valuationDate);
    
    RFreturns = log(combinedEquityPortfolio.RF((valDateIndex-252):(valDateIndex-1),:)./combinedEquityPortfolio.RF((valDateIndex-251):valDateIndex,:));

    alpha = norminv(CI);
    covars = cov(RFreturns);
    S = combinedEquityPortfolio.RF(valDateIndex,:);
    xdelta = transpose(combinedEquityPortfolio.Deltas.*S);
    VAR = alpha*sqrt(holdingTdays)*sqrt(xdelta'*covars*xdelta);   
end