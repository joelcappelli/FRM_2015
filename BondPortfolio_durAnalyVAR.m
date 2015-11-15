function VAR = BondPortfolio_durAnalyVAR(CI,holdingTdays,couponBond_Portfolio,valuationDate,workbookSheetNames,workbookDates)
    
    alpha = norminv(CI);
    valDateIndex = find(returnDates(couponBond_Portfolio.YieldCode,workbookSheetNames,workbookDates) == valuationDate);
    
    x = transpose(couponBond_Portfolio.PV_CF.*couponBond_Portfolio.ZCB_yearFrac);                      
    VAR = alpha*sqrt(holdingTdays)*sqrt(x'*cov(RFreturns(couponBond_Portfolio.RF(1:valDateIndex,:),999,1,'diff'))*x); 
end
