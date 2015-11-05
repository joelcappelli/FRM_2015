function VAR = equityPortfolio_histSimDeltaNormVAR(CI,holdingTdays,combinedEquityPortfolio,valuationDate,workbookSheetNames,workbookDates)
    dates = returnDates(combinedEquityPortfolio.pricesSheet,workbookSheetNames,workbookDates);
    valDateIndex = find(dates == valuationDate);
    
    RFreturns_252periods = log(combinedEquityPortfolio.RF((valDateIndex-252*holdingTdays):holdingTdays:(valDateIndex-1),:)./combinedEquityPortfolio.RF((valDateIndex-251*holdingTdays):holdingTdays:valDateIndex,:));
    
    S = repmat(combinedEquityPortfolio.RF(valDateIndex,:),size(RFreturns_252periods,1),1);
    dS = S.*RFreturns_252periods;

    dP_delta = sort(dS*transpose(combinedEquityPortfolio.DeltasAndLinearPos));
    pointer = round( (1-CI)*length(dP_delta) + 0.1 );
    pointer = reshape(pointer, length(pointer),1);
    pointer = max(pointer, ones(length(pointer),1));
    VAR = -dP_delta(pointer);  
end