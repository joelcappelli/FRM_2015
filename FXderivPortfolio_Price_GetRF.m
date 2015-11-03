function combinedFXderivPortfolio = FXderivPortfolio_Price_GetRF(combinedFXderivPortfolio)
        
    combinedFXderivPortfolio.Price = combinedFXderivPortfolio.FWDFX_Portfolio.Price + combinedFXderivPortfolio.FXOptions_Portfolio.Price;
    numOptPositions = size(combinedFXderivPortfolio.ShareOptions_Portfolio.ShareOption,2);
    numFXFWDPositions = size(combinedFXderivPortfolio.PhysicalShares_Portfolio.Share,2);

    numRF = 0;
    for i = 1:numOptPositions
        tempCode = combinedFXderivPortfolio.FXOptions_Portfolio.ShareOption(i).UnderlyingCode;

        OwnOrSold = combinedFXderivPortfolio.FXOptions_Portfolio.ShareOption(i).OwnOrSold;
        numShares = combinedFXderivPortfolio.FXOptions_Portfolio.ShareOption(i).numShares;
        delta = combinedFXderivPortfolio.FXOptions_Portfolio.ShareOption(i).Delta;
        gamma = combinedFXderivPortfolio.FXOptions_Portfolio.ShareOption(i).Gamma;

        index = strcmp(tempCode,combinedFXderivPortfolio.UnderlyingCode);
        if(~sum(index))
            numRF = numRF + 1;
            combinedFXderivPortfolio.UnderlyingCode{numRF} = tempCode;
            combinedFXderivPortfolio.RF(:,numRF) = combinedFXderivPortfolio.FXOptions_Portfolio.RF(:,i);  

            combinedFXderivPortfolio.sharePositions(:,numRF) = 0 ;

            combinedFXderivPortfolio.optionPositions(:,numRF) = OwnOrSold*numShares;
            combinedFXderivPortfolio.Deltas(:,numRF) = OwnOrSold*delta*numShares;
            combinedFXderivPortfolio.Gammas(:,numRF) = OwnOrSold*gamma*numShares;
        else
            combinedFXderivPortfolio.optionPositions(:,index) = combinedFXderivPortfolio.optionPositions(:,index) + OwnOrSold*numShares;
            combinedFXderivPortfolio.Deltas(:,index) = combinedFXderivPortfolio.Deltas(:,index) + OwnOrSold*delta*numShares;
            combinedFXderivPortfolio.Gammas(:,index) = combinedFXderivPortfolio.Gammas(:,index) + OwnOrSold*gamma*numShares;
        end
    end

    for i = 1:numFXFWDPositions
        tempCode = combinedFXderivPortfolio.PhysicalShares_Portfolio.Share(i).IssuerCode;

        OwnOrSold = combinedFXderivPortfolio.PhysicalShares_Portfolio.Share(i).OwnOrSold;
        numShares = combinedFXderivPortfolio.PhysicalShares_Portfolio.Share(i).numShares;

        index = strcmp(tempCode,combinedFXderivPortfolio.UnderlyingCode);    
        if(~sum(index))
            numRF = numRF + 1;
            combinedFXderivPortfolio.UnderlyingCode{numRF} = tempCode;
            combinedFXderivPortfolio.RF(:,numRF) = combinedFXderivPortfolio.PhysicalShares_Portfolio.RF(:,i);

            combinedFXderivPortfolio.sharePositions(:,numRF) = OwnOrSold*numShares;          
            combinedFXderivPortfolio.Deltas(:,numRF) = OwnOrSold*numShares;  

            combinedFXderivPortfolio.optionPositions(:,numRF) = 0 ;
            combinedFXderivPortfolio.Gammas(:,numRF) = 0;
        else
            combinedFXderivPortfolio.sharePositions(:,index) = combinedFXderivPortfolio.sharePositions(:,index) + OwnOrSold*numShares;        
            combinedFXderivPortfolio.Deltas(:,index) = combinedFXderivPortfolio.Deltas(:,index) + OwnOrSold*numShares;
        end
    end
end