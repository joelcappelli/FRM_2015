function VAR = BondPortfolio_durConvexAnalyVAR(CI,holdingTdays,couponBond_Portfolio,valuationDate,workbookSheetNames,workbookDates)
    
    alpha = norminv(CI);
    valDateIndex = find(returnDates(couponBond_Portfolio.YieldCode,workbookSheetNames,workbookDates) == valuationDate);
    
    RFreturns_ = RFreturns(couponBond_Portfolio.RF(1:valDateIndex,:),999,1,'diff')./repmat((1+couponBond_Portfolio.RF(valDateIndex,:)),999,1);
    
    covars = cov(RFreturns_);
    deltaLinear = transpose(couponBond_Portfolio.PV_CF.*couponBond_Portfolio.ZCB_yearFrac);    
    gammaCovar = (couponBond_Portfolio.PV_CF.*(couponBond_Portfolio.ZCB_yearFrac).^2)*covars;
    
    VAR = alpha*sqrt(holdingTdays)*sqrt(deltaLinear'*covars*deltaLinear + 0.5*(gammaCovar)*gammaCovar'); 
end