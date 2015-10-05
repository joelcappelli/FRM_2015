function ShareOptions_Portfolio = ShareOptionsPortfolio_Price_GetRF(ShareOptions_Portfolio,valuationDate,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
    
    numSharesOptPositions = size(ShareOptions_Portfolio.ShareOption,2);

    [valuDateYearFracs, codes, valuDateYields] = returnYieldCurveData(ShareOptions_Portfolio.DomesticYieldCurveSheet,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);
    numRF = 0;
    
    for i = 1:numSharesOptPositions      
        [stockPrices,dates] = returnColData(ShareOptions_Portfolio.pricesSheet,ShareOptions_Portfolio.ShareOption(i).UnderlyingCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
        valDateIndex = find(dates == valuationDate);
        spot = stockPrices(valDateIndex);

        numRF = numRF + 1;
        ShareOptions_Portfolio.RF(:,numRF) = stockPrices;  

        OwnOrSold = ShareOptions_Portfolio.ShareOption(i).OwnOrSold;
        numShares = ShareOptions_Portfolio.ShareOption(i).numShares;
        strike = ShareOptions_Portfolio.ShareOption(i).strike;
        div = 0;
        %given
        vol = ShareOptions_Portfolio.ShareOption(i).vol_pa;

        expiry = yearfrac(valuationDate,ShareOptions_Portfolio.ShareOption(i).Maturity,1);
        callOrPut = ShareOptions_Portfolio.ShareOption(i).CallOrPut;
        rate = interpolYield(expiry,valuDateYearFracs,valuDateYields);

        ShareOptions_Portfolio.ShareOption(i).Price = OwnOrSold*numShares*bsPrice(spot, strike, rate, div, vol, expiry, callOrPut);
        ShareOptions_Portfolio.ShareOption(i).Delta = bsDelta(spot, strike, rate, div, vol, expiry, callOrPut);
        ShareOptions_Portfolio.ShareOption(i).Gamma = bsGamma(spot, strike, rate, div, vol, expiry);

        ShareOptions_Portfolio.Price = ShareOptions_Portfolio.Price + ShareOptions_Portfolio.ShareOption(i).Price;
    end
end