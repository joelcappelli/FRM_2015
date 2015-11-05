function VAR = BondPortfolio_durConvexHistSimVaR(CI,holdingTdays,couponBond_Portfolio,valuationDate,workbookSheetNames,workbookDates)
    
    valDateIndex = find(returnDates(couponBond_Portfolio.YieldCode,workbookSheetNames,workbookDates) == valuationDate);
    
    %non-overlapping data
    couponBond_PortfolioRF_last252periods = couponBond_Portfolio.RF((valDateIndex-252*holdingTdays):holdingTdays:(valDateIndex - holdingTdays),:);
    diffRFYields = diff(couponBond_PortfolioRF_last252periods,1,1)';%take transpose for VAR calcs
    
    PV_CF = couponBond_Portfolio.PV_CF;
    RF_yearFrac = couponBond_Portfolio.ZCB_yearFrac;
    histSimDeltaP = sort((PV_CF.*RF_yearFrac)*diffRFYields + 0.5*(PV_CF.*RF_yearFrac.*RF_yearFrac)*(diffRFYields.*diffRFYields));

    pointer = round( (1-CI) * length(histSimDeltaP) + 0.1 );
    pointer = reshape( pointer, length(pointer), 1);
    pointer = max( pointer, ones(length(pointer), 1) );

    % typically VAR is presented as positive value
    VAR = -histSimDeltaP(pointer);
end