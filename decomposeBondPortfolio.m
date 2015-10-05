function BondPortfolio = decomposeBondPortfolio(BondPortfolio,valuationDate,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData)
    numBonds = size(BondPortfolio.CouponBond,2);
    %growing column vectors of risk factors which are the coupon bonds
    %decomposed into ZCB with assoicated linearly interpolated yield data for
    %each cash flow 
    numRF = 0;
    [valuDateYearFracs, codes, valuDateYields] = returnYieldCurveData(BondPortfolio.yieldCurveSheet,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);
    % make sure each risk factor is column vector to be used with covar matlab
    % method
    for i = 1:numBonds

        couponBond_Price = 0;
        FV = BondPortfolio.CouponBond(i).FV;
        couponRate = BondPortfolio.CouponBond(i).C_rate_pa*BondPortfolio.CouponBond(i).C_frequ;

        couponDateYearFrac = yearfrac(valuationDate,BondPortfolio.CouponBond(i).Maturity,1);
        maturityPayment = 1;
        %while(couponDateYearFrac >= BondPortfolio.CouponBonds(i).C_frequ)  
        while(couponDateYearFrac > 0) 
            ZCB = ZCB_price_contComp(couponDateYearFrac,interpolYield(couponDateYearFrac,valuDateYearFracs,valuDateYields));
            if(maturityPayment)
                PV_CF = (1+couponRate)*FV*ZCB;
                maturityPayment = 0;
            else
                PV_CF = couponRate*FV*ZCB;
            end

            numRF = numRF + 1;
            BondPortfolio.RF(:,numRF) = yieldCurveRiskFactor(BondPortfolio.yieldCurveSheet,couponDateYearFrac,valuDateYearFracs,codes,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
            BondPortfolio.PV_CF(numRF) = PV_CF;
            BondPortfolio.ZCB_yearFrac(numRF) = couponDateYearFrac;

            couponDateYearFrac = couponDateYearFrac - BondPortfolio.CouponBond(i).C_frequ;
            couponBond_Price = couponBond_Price + PV_CF;
        end

        %work out accural interest since last coupon date
        %couponBond_Price = couponBond_Price + couponRate*FV*couponDateYearFrac/BondPortfolio.CouponBonds(i).C_frequ;  
        BondPortfolio.CouponBond(i).Price = couponBond_Price;    
        BondPortfolio.Price = BondPortfolio.Price + couponBond_Price;
    end
end