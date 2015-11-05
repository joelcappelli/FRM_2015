function FXOptions_Portfolio = FXOptionsPortfolio_Price_GetRF(FXOptions_Portfolio,valuationDate,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData)
    
    numFXOptPositions = size(FXOptions_Portfolio.FXOption,2);
    [valuDateYearFracsDomestic, ~, valuDateDomesticYields] = returnYieldCurveData(FXOptions_Portfolio.DomesticYieldCurveSheet,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);
    numRF = 0;
    
    for i = 1:numFXOptPositions
        [valuDateYearFracsForeign, ~, valuDateForeignYields] = returnYieldCurveData(FXOptions_Portfolio.FXOption(i).UnderlyingYieldCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);
        [ForeignPerDomesticFX_rates,dates] = returnColData(FXOptions_Portfolio.FXSheet,FXOptions_Portfolio.FXOption(i).UnderlyingExchaRateCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
        DomesticPerForeignFX_rates = 1./ForeignPerDomesticFX_rates;
        valDateIndex = find(dates == valuationDate);
        spotDomesticPerForeign = DomesticPerForeignFX_rates(valDateIndex);

        numRF = numRF + 1;
        FXOptions_Portfolio.RF(:,numRF) = DomesticPerForeignFX_rates; 
%         numRF = numRF + 1;
%         FWDFX_Portfolio.RF(:,numRF) = yieldCurveRiskFactor(FWDFX_Portfolio.FXOptions_Portfolio(i).BuyYieldCode,expiry,valuDateYearFracsBuy,codesBuyYields,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData); 
%         numRF = numRF + 1;
%         FWDFX_Portfolio.RF(:,numRF) = yieldCurveRiskFactor(FWDFX_Portfolio.FXOptions_Portfolio(i).SellYieldCode,expiry,valuDateYearFracsSell,codesSellYields,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData); 
%                 
    %     assuming daily data
    %     returns = diff(DomesticPerForeignFX_rates((valDateIndex-359):valDateIndex)) ./ DomesticPerForeignFX_rates((valDateIndex-359):(valDateIndex-1));
    %     stdv = std(returns);
    %     vol = sqrt(360)*stdv;

        %cont compounded returns
        returns = log(DomesticPerForeignFX_rates((valDateIndex-360):(valDateIndex-1))./DomesticPerForeignFX_rates((valDateIndex-359):valDateIndex));
        stdv = std(returns);
        vol = sqrt(360)*stdv;

        OwnOrSold = FXOptions_Portfolio.FXOption(i).OwnOrSold;
        foreignAmount = FXOptions_Portfolio.FXOption(i).ForeignAmount;
        strikeDomesticPerForeign = FXOptions_Portfolio.FXOption(i).DomesticAmount/FXOptions_Portfolio.FXOption(i).ForeignAmount;

        expiry = yearfrac(valuationDate,FXOptions_Portfolio.FXOption(i).Exp_Date,1);
        callOrPut = FXOptions_Portfolio.FXOption(i).CallOrPut;
        domesticRate = interpolYield(expiry,valuDateYearFracsDomestic,valuDateDomesticYields);
        foreignRate = interpolYield(expiry,valuDateYearFracsForeign,valuDateForeignYields);

        FXOptions_Portfolio.FXOption(i).Price = OwnOrSold*foreignAmount*bsPrice(spotDomesticPerForeign, strikeDomesticPerForeign, domesticRate, foreignRate, vol, expiry, callOrPut);
        FXOptions_Portfolio.Price = FXOptions_Portfolio.Price + FXOptions_Portfolio.FXOption(i).Price;
        
        FXOptions_Portfolio.FXOption(i).Delta = bsDelta(spotDomesticPerForeign, strikeDomesticPerForeign, domesticRate, foreignRate, vol, expiry, callOrPut);
        FXOptions_Portfolio.FXOption(i).Gamma = bsGamma(spotDomesticPerForeign, strikeDomesticPerForeign, domesticRate, foreignRate, vol, expiry);
    end
end