function VAR = equityBondPortfolio_analyDeltaGammaVAR(CI,holdingTdays,portfolio,valuationDate,workbookSheetNames,workbookDates)
    dates = returnDates(portfolio.pricesSheet,workbookSheetNames,workbookDates);
    valDateIndex = find(dates == valuationDate);
    
    stockIndex = find(strcmp('stock',portfolio.RF_type));
    bondIndex = find(strcmp('bond',portfolio.RF_type));
        
    numDays = 252*3;
    RFreturns_ = zeros(numDays,size(portfolio.RF,2));
    RFstockReturns = RFreturns(portfolio.RF(1:valDateIndex,stockIndex),numDays,1,'diff');%log(portfolio.RF((valDateIndex-numDays):(valDateIndex-1),stockIndex)./portfolio.RF((valDateIndex-numDays+1):valDateIndex,stockIndex));
    RFyieldChanges = RFreturns(portfolio.RF(1:valDateIndex,bondIndex),numDays,1,'diff');%diff(portfolio.RF((valDateIndex-numDays):valDateIndex,bondIndex),1,1);

    RFreturns_(:,stockIndex) = RFstockReturns;
    %modified duration
    RFreturns_(:,bondIndex) = RFyieldChanges./repmat((1+portfolio.RF(valDateIndex,bondIndex)),numDays,1);
    
    alpha = norminv(CI);
    covars = cov(RFreturns_);
    
	%S = portfolio.RF(valDateIndex,:);
	%xdelta = transpose(portfolio.DeltasAndLinearPos.*S);
	xdelta = transpose(portfolio.DeltasAndLinearPos);
        
    %S2 = transpose(portfolio.RF(valDateIndex,:).*portfolio.RF(valDateIndex,:));
    %gammaCovarS2 = diag(portfolio.Gammas)*covars*S2;
    gammaCovarS2 = portfolio.Gammas*covars;
    
    %VAR = alpha*sqrt(holdingTdays)*sqrt(xdelta'*covars*xdelta + 0.5*(gammaCovarS2')*gammaCovarS2); 
    VAR = alpha*sqrt(holdingTdays)*sqrt(xdelta'*covars*xdelta + 0.5*(gammaCovarS2)*gammaCovarS2'); 
    
end