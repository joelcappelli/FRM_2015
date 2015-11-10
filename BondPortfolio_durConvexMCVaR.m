function VAR_ETL = BondPortfolio_durConvexMCVaR(sims,CI,holdingTdays,couponBond_Portfolio,valuationDate,workbookSheetNames,workbookDates)
    
    valDateIndex = find(returnDates(couponBond_Portfolio.YieldCode,workbookSheetNames,workbookDates) == valuationDate);
    
    %non-overlapping data
    couponBond_PortfolioRF_last252periods = couponBond_Portfolio.RF((valDateIndex-252*holdingTdays):holdingTdays:(valDateIndex - holdingTdays),:);
    diffRFYields = diff(couponBond_PortfolioRF_last252periods,1,1);%take transpose for VAR calcs
    
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
end
