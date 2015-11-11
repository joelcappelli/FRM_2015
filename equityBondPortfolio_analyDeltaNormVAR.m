function VAR = equityBondPortfolio_analyDeltaNormVAR(CI,holdingTdays,portfolio,valuationDate,workbookSheetNames,workbookDates)
    dates = returnDates(portfolio.pricesSheet,workbookSheetNames,workbookDates);
    valDateIndex = find(dates == valuationDate);
    
    stockIndex = find(strcmp('stock',portfolio.RF_type));
    bondIndex = find(strcmp('bond',portfolio.RF_type));
        
    numDays = 252*3;
    RFreturns = zeros(numDays,size(portfolio.RF,2));
    RFstockReturns = log(portfolio.RF((valDateIndex-numDays):(valDateIndex-1),stockIndex)./portfolio.RF((valDateIndex-numDays+1):valDateIndex,stockIndex));
    RFyieldChanges = diff(portfolio.RF((valDateIndex-numDays):valDateIndex,bondIndex),1,1);

    RFreturns(:,stockIndex) = RFstockReturns;
    %modified duration
    RFreturns(:,bondIndex) = RFyieldChanges./repmat((1+portfolio.RF(valDateIndex,bondIndex)),numDays,1);
    
    alpha = norminv(CI);
    covars = cov(RFreturns);
    S = portfolio.RF(valDateIndex,:);
    xdelta = transpose(portfolio.DeltasAndLinearPos.*S);
    VAR = alpha*sqrt(holdingTdays)*sqrt(xdelta'*covars*xdelta);   
end