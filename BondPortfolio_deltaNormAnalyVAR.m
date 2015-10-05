function VAR = BondPortfolio_deltaNormAnalyVAR(CI,holdingTdays,couponBond_Portfolio,valuationDate,workbookSheetNames,workbookDates)
    
    alpha = norminv(CI);
    valDateIndex = find(returnDates(couponBond_Portfolio.yieldCurveSheet,workbookSheetNames,workbookDates) == valuationDate);
    
    x = transpose(couponBond_Portfolio.PV_CF.*couponBond_Portfolio.ZCB_yearFrac);       
                
    couponBond_PortfolioRF_last1000days = couponBond_Portfolio.RF((valDateIndex-999):valDateIndex,:);
	VAR = alpha*sqrt(holdingTdays)*sqrt(x'*cov(diff(couponBond_PortfolioRF_last1000days,1,1))*x);   
end
