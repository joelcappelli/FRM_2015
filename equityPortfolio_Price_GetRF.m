function combinedEquityPortfolio = equityPortfolio_Price_GetRF(combinedEquityPortfolio)
        
    combinedEquityPortfolio.Price = combinedEquityPortfolio.ShareOptions_Portfolio.Price + combinedEquityPortfolio.PhysicalShares_Portfolio.Price;
    numSharesOptPositions = size(combinedEquityPortfolio.ShareOptions_Portfolio.ShareOption,2);
    numSharesPositions = size(combinedEquityPortfolio.PhysicalShares_Portfolio.Share,2);

    numRF = 0;
    for i = 1:numSharesOptPositions
        tempCode = combinedEquityPortfolio.ShareOptions_Portfolio.ShareOption(i).UnderlyingCode;

        OwnOrSold = combinedEquityPortfolio.ShareOptions_Portfolio.ShareOption(i).OwnOrSold;
        numShares = combinedEquityPortfolio.ShareOptions_Portfolio.ShareOption(i).numShares;
        delta = combinedEquityPortfolio.ShareOptions_Portfolio.ShareOption(i).Delta;
        gamma = combinedEquityPortfolio.ShareOptions_Portfolio.ShareOption(i).Gamma;

        index = strcmp(tempCode,combinedEquityPortfolio.UnderlyingCode);
        if(~sum(index))
            numRF = numRF + 1;
            combinedEquityPortfolio.UnderlyingCode{numRF} = tempCode;
            combinedEquityPortfolio.RF(:,numRF) = combinedEquityPortfolio.ShareOptions_Portfolio.RF(:,i);  

            combinedEquityPortfolio.sharePositions(:,numRF) = 0 ;

            combinedEquityPortfolio.optionPositions(:,numRF) = OwnOrSold*numShares;
            combinedEquityPortfolio.Deltas(:,numRF) = OwnOrSold*delta*numShares;
            combinedEquityPortfolio.Gammas(:,numRF) = OwnOrSold*gamma*numShares;
        else
            combinedEquityPortfolio.optionPositions(:,index) = combinedEquityPortfolio.optionPositions(:,index) + OwnOrSold*numShares;
            combinedEquityPortfolio.Deltas(:,index) = combinedEquityPortfolio.Deltas(:,index) + OwnOrSold*delta*numShares;
            combinedEquityPortfolio.Gammas(:,index) = combinedEquityPortfolio.Gammas(:,index) + OwnOrSold*gamma*numShares;
        end
    end

    for i = 1:numSharesPositions
        tempCode = combinedEquityPortfolio.PhysicalShares_Portfolio.Share(i).IssuerCode;

        OwnOrSold = combinedEquityPortfolio.PhysicalShares_Portfolio.Share(i).OwnOrSold;
        numShares = combinedEquityPortfolio.PhysicalShares_Portfolio.Share(i).numShares;

        index = strcmp(tempCode,combinedEquityPortfolio.UnderlyingCode);    
        if(~sum(index))
            numRF = numRF + 1;
            combinedEquityPortfolio.UnderlyingCode{numRF} = tempCode;
            combinedEquityPortfolio.RF(:,numRF) = combinedEquityPortfolio.PhysicalShares_Portfolio.RF(:,i);

            combinedEquityPortfolio.sharePositions(:,numRF) = OwnOrSold*numShares;          
            combinedEquityPortfolio.Deltas(:,numRF) = OwnOrSold*numShares;  

            combinedEquityPortfolio.optionPositions(:,numRF) = 0 ;
            combinedEquityPortfolio.Gammas(:,numRF) = 0;
        else
            combinedEquityPortfolio.sharePositions(:,index) = combinedEquityPortfolio.sharePositions(:,index) + OwnOrSold*numShares;        
            combinedEquityPortfolio.Deltas(:,index) = combinedEquityPortfolio.Deltas(:,index) + OwnOrSold*numShares;
        end
    end
end