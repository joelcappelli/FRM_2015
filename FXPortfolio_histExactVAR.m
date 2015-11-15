function VAR_ETL = FXPortfolio_histExactVAR(FX_Portfolio, CI, holdingTdays,workbookSheetNames,workbookDates,valuationDate,plotTitle)
    
    valDateIndex = find(returnDates(FX_Portfolio.exchaRateSheet,workbookSheetNames,workbookDates) == valuationDate);
    
    %non-overlapping data
    if(holdingTdays > 1)
        periods = 250;
    else
        periods = 1000;
    end
    
    RFReturns_ = RFreturns(FX_Portfolio.RF(1:valDateIndex,:),periods,holdingTdays,'reldiff');
    
    portReturns = sort(RFReturns_*FX_Portfolio.weights');
    pointer = round( (1-CI)*length(portReturns) + 0.1 );
    pointer = reshape(pointer, length(pointer),1);
    pointer = max(pointer, ones(length(pointer),1));

    VAR_ETL(1) = -FX_Portfolio.Price * portReturns(pointer);
    VAR_ETL(2) = -FX_Portfolio.Price *mean(portReturns(1:pointer));
    
    if(~isempty(plotTitle))
        drawPNL_HistogramPlotWithNorm(-VAR_ETL(1)*1000000,FX_Portfolio.Price*portReturns*1000000,CI,plotTitle)
    end
end