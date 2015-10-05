function VAR = FXPortfolio_histExactVAR(FX_Portfolio, CI, holdingTdays,workbookSheetNames,workbookDates,valuationDate)
    
    valDateIndex = find(returnDates(FX_Portfolio.exchaRateSheet,workbookSheetNames,workbookDates) == valuationDate);
    
    % T period cont. compounded returns - over 252 periods
    RFReturns_252periods = log(FX_Portfolio.RF((valDateIndex-252*holdingTdays):holdingTdays:(valDateIndex-1),:)./FX_Portfolio.RF((valDateIndex-251*holdingTdays):holdingTdays:valDateIndex,:));
        
    portReturns = sort(RFReturns_252periods*FX_Portfolio.weights');
    pointer = round( (1-CI)*length(portReturns) + 0.1 );
    pointer = reshape(pointer, length(pointer),1);
    pointer = max(pointer, ones(length(pointer),1));

    VAR = -FX_Portfolio.Price * portReturns(pointer);
end