function VAR_ETL = equityPortfolio_histSimDeltaGammaVAR(CI,holdingTdays,combinedEquityPortfolio,valuationDate,workbookSheetNames,workbookDates,plotTitle)
    dates = returnDates(combinedEquityPortfolio.pricesSheet,workbookSheetNames,workbookDates);
    valDateIndex = find(dates == valuationDate);
    
    %non-overlapping data
    if(holdingTdays > 1)
        periods = 250;
    else
        periods = 1000;
    end
    
    RFReturns_ = RFreturns(combinedEquityPortfolio.RF(1:valDateIndex,:),periods,holdingTdays,'reldiff');
    
    S = repmat(combinedEquityPortfolio.RF(valDateIndex,:),size(RFReturns_,1),1);
    dS = S.*RFReturns_;

    dP_deltaGamma = sort(dS*transpose(combinedEquityPortfolio.DeltasAndLinearPos) + 0.5*(dS.*dS)*transpose(combinedEquityPortfolio.Gammas));
    pointer = round( (1-CI)*length(dP_deltaGamma) + 0.1 );
    pointer = reshape(pointer, length(pointer),1);
    pointer = max(pointer, ones(length(pointer),1));
    VAR_ETL(1) =  -dP_deltaGamma(pointer); 
    VAR_ETL(2) = -mean(dP_deltaGamma(1:pointer));
    
    if(~isempty(plotTitle))
        drawPNL_HistogramPlotWithNorm(-VAR_ETL(1),dP_deltaGamma,CI,plotTitle)
    end
end