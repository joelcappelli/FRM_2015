function FWDFX_Portfolio = FWDFXPortfolio_Price_GetRF(FWDFX_Portfolio,valuationDate,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData)
    
    numFWDFXPositions = size(FWDFX_Portfolio.FWDFX,2);

    for i = 1:numFWDFXPositions
        [valuDateYearFracsBuy, codesBuyYields, valuDateBuyYields] = returnYieldCurveData(FWDFX_Portfolio.FWDFX(i).BuyYieldCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);
        [valuDateYearFracsSell, codesSellYields, valuDateSellYields] = returnYieldCurveData(FWDFX_Portfolio.FWDFX(i).SellYieldCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);

        [sellFX_rates,dates] = returnColData(FWDFX_Portfolio.FXSheet,FWDFX_Portfolio.FWDFX(i).SellExchaRateCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
        spotSellFX = sellFX_rates(dates == valuationDate);

        sellAmount = FWDFX_Portfolio.FWDFX(i).SellAmount;
        buyAmount = FWDFX_Portfolio.FWDFX(i).BuyAmount;

        expiry = yearfrac(valuationDate,FWDFX_Portfolio.FWDFX(i).Exp_Date,1);
        sellFXYield = interpolYield(expiry,valuDateYearFracsSell,valuDateSellYields);
        buyFXYield = interpolYield(expiry,valuDateYearFracsBuy,valuDateBuyYields);

        FWDFX_Portfolio.FWDFX(i).Price = buyAmount*(1/spotSellFX)*exp(-buyFXYield*expiry) - sellAmount*exp(-sellFXYield*expiry);
        FWDFX_Portfolio.Price = FWDFX_Portfolio.Price + FWDFX_Portfolio.FWDFX(i).Price;
    end
end