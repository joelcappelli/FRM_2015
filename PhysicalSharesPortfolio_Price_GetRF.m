function PhysicalShares_Portfolio = PhysicalSharesPortfolio_Price_GetRF(PhysicalShares_Portfolio,valuationDate,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData)
    
    numSharesPositions = size(PhysicalShares_Portfolio.Share,2);
    PhysicalShares_Portfolio.weights = zeros(1,numSharesPositions);
    numRF = 0;
    
    for i = 1:numSharesPositions
        [stockPrices,dates] = returnColData(PhysicalShares_Portfolio.pricesSheet,PhysicalShares_Portfolio.Share(i).IssuerCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
        valDateIndex = find(dates == valuationDate);
        spot = stockPrices(valDateIndex);

        numRF = numRF + 1;
        PhysicalShares_Portfolio.RF(:,numRF) = stockPrices;  

        OwnOrSold = PhysicalShares_Portfolio.Share(i).OwnOrSold;
        PhysicalShares_Portfolio.Share(i).Price = OwnOrSold*PhysicalShares_Portfolio.Share(i).numShares*spot; %price in millions AUD / 1000000   
        PhysicalShares_Portfolio.Price = PhysicalShares_Portfolio.Price + PhysicalShares_Portfolio.Share(i).Price;
    end

    for i = 1:numSharesPositions
        PhysicalShares_Portfolio.weights(i) = PhysicalShares_Portfolio.Share(i).Price/PhysicalShares_Portfolio.Price;
    end
end