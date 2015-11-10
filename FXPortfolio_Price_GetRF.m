function FX_Portfolio = FXPortfolio_Price_GetRF(FX_Portfolio,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData)
    sizeFxPortfolio = size(FX_Portfolio.Currencies,2);
    numRF = 0;
    FX_Portfolio.weights = zeros(1,sizeFxPortfolio);
    for i =1:sizeFxPortfolio

        [ForeignPerDomesticFX_rates,~] = returnColData(FX_Portfolio.exchaRateSheet,FX_Portfolio.Currencies(i).exchaRateCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
        %DomesticPerForeignFX_rates = 1./ForeignPerDomesticFX_rates;
        numRF = numRF + 1;
        FX_Portfolio.RF(:,numRF) = ForeignPerDomesticFX_rates;       
        FX_Portfolio.UnderlyingCode{numRF} = FX_Portfolio.Currencies(i).exchaRateCode;
        
        FX_Portfolio.Price = FX_Portfolio.Price + FX_Portfolio.Currencies(i).DomesticEquivAmount;
    end

    for i = 1:sizeFxPortfolio
        FX_Portfolio.weights(i) = FX_Portfolio.Currencies(i).DomesticEquivAmount/FX_Portfolio.Price;
    end
end