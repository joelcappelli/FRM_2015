function VAR_ETL = BondPortfolio_durConvexMCVaR(sims,CI,holdingTdays,couponBond_Portfolio,valuationDate,workbookSheetNames,workbookDates,plotTitle)
    
    valDateIndex = find(returnDates(couponBond_Portfolio.YieldCode,workbookSheetNames,workbookDates) == valuationDate);
    
    %non-overlapping data
    if(holdingTdays > 1)
        periods = 250;
    else
        periods = 1000;
    end
    
    diffRFYields = RFreturns(couponBond_Portfolio.RF(1:valDateIndex,:),periods,holdingTdays,'diff');%take transpose for VAR calcs
    
    %simulated the difference of yields with zero drift
    diffRFsim = PCA_RF_MV_GBM(diffRFYields,sims,0.99);
     
    PV_CF = couponBond_Portfolio.PV_CF;
    RF_yearFrac = couponBond_Portfolio.ZCB_yearFrac;
    MCSimDeltaP = sort((PV_CF.*RF_yearFrac)*diffRFsim + 0.5*(PV_CF.*RF_yearFrac.*RF_yearFrac)*(diffRFsim.*diffRFsim));

    pointer = round( (1-CI) * length(MCSimDeltaP) + 0.1 );
    pointer = reshape( pointer, length(pointer), 1);
    pointer = max( pointer, ones(length(pointer), 1) );

    % typically VAR is presented as positive value
    VAR_ETL(1) = -MCSimDeltaP(pointer);
    VAR_ETL(2) = -mean(MCSimDeltaP(1:pointer));
    
    if(~isempty(plotTitle))
        drawPNL_HistogramPlotWithNorm(-VAR_ETL(1)*1000000,MCSimDeltaP*1000000,CI,plotTitle)
    end
end
