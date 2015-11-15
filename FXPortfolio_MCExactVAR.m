function VAR_ETL = FXPortfolio_MCExactVAR(sims,FX_Portfolio, CI, holdingTdays,workbookSheetNames,workbookDates,valuationDate)
    
    valDateIndex = find(returnDates(FX_Portfolio.exchaRateSheet,workbookSheetNames,workbookDates) == valuationDate);
       
    %non-overlapping data
    if(holdingTdays > 1)
        periods = 250;
    else
        periods = 1000;
    end
    
    RFReturns_ = RFreturns(FX_Portfolio.RF(1:valDateIndex,:),periods,holdingTdays,'reldiff');
    
    returnsRFsim = PCA_RF_MV_GBM(RFReturns_,sims,0.99);
    
    portReturns = sort(returnsRFsim'*FX_Portfolio.weights');
    pointer = round( (1-CI)*length(portReturns) + 0.1 );
    pointer = reshape(pointer, length(pointer),1);
    pointer = max(pointer, ones(length(pointer),1));

    VAR_ETL(1) = -FX_Portfolio.Price * portReturns(pointer);
    VAR_ETL(2) = -FX_Portfolio.Price *mean(portReturns(1:pointer));
end