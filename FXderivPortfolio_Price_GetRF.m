function combinedFXderivPortfolio = FXderivPortfolio_Price_GetRF(combinedFXderivPortfolio)
        
    combinedFXderivPortfolio.Price = combinedFXderivPortfolio.FWDFX_Portfolio.Price + combinedFXderivPortfolio.FXOptions_Portfolio.Price;
    numOptPositions = size(combinedFXderivPortfolio.FXOptions_Portfolio.FXOption,2);
    numFXFWDPositions = size(combinedFXderivPortfolio.FWDFX_Portfolio.FWDFX,2);

    numRF = 0;
    for i = 1:numOptPositions
        tempCode = combinedFXderivPortfolio.FXOptions_Portfolio.FXOption(i).UnderlyingExchaRateCode;
        
        ForeignBuyAmount = combinedFXderivPortfolio.FXOptions_Portfolio.FXOption(i).ForeignAmount*1000000;
        OwnOrSold = combinedFXderivPortfolio.FXOptions_Portfolio.FXOption(i).OwnOrSold;
        delta = combinedFXderivPortfolio.FXOptions_Portfolio.FXOption(i).Delta;
        gamma = combinedFXderivPortfolio.FXOptions_Portfolio.FXOption(i).Gamma;

        index = strcmp(tempCode,combinedFXderivPortfolio.UnderlyingCode);
        if(~sum(index))
            numRF = numRF + 1;
            combinedFXderivPortfolio.UnderlyingCode{numRF} = tempCode;
            combinedFXderivPortfolio.RF(:,numRF) = combinedFXderivPortfolio.FXOptions_Portfolio.RF(:,i);  

            combinedFXderivPortfolio.FXoptionBuyPositions(:,numRF) = OwnOrSold*ForeignBuyAmount;
            combinedFXderivPortfolio.FWDBuyPositions(:,numRF) = 0;

            combinedFXderivPortfolio.DeltasAndLinearPos(:,numRF) = OwnOrSold*delta*ForeignBuyAmount;
            combinedFXderivPortfolio.Gammas(:,numRF) = OwnOrSold*gamma*ForeignBuyAmount;
        else
            combinedFXderivPortfolio.FXoptionBuyPositions(:,index) = combinedFXderivPortfolio.FXoptionBuyPositions(:,index) + OwnOrSold*ForeignBuyAmount;
            combinedFXderivPortfolio.DeltasAndLinearPos(:,index) = combinedFXderivPortfolio.DeltasAndLinearPos(:,index) + OwnOrSold*delta*ForeignBuyAmount;
            combinedFXderivPortfolio.Gammas(:,index) = combinedFXderivPortfolio.Gammas(:,index) + OwnOrSold*gamma*ForeignBuyAmount;
        end
    end

    for i = 1:numFXFWDPositions
        tempCode = combinedFXderivPortfolio.FWDFX_Portfolio.FWDFX(i).SellExchaRateCode;

        ForeignBuyAmount = combinedFXderivPortfolio.FWDFX_Portfolio.FWDFX(i).BuyAmount*1000000;
        
        index = strcmp(tempCode,combinedFXderivPortfolio.UnderlyingCode);    
        if(~sum(index))
            numRF = numRF + 1;
            combinedFXderivPortfolio.UnderlyingCode{numRF} = tempCode;
            combinedFXderivPortfolio.RF(:,numRF) = combinedFXderivPortfolio.FWDFX_Portfolio.RF(:,i);

            combinedFXderivPortfolio.FWDBuyPositions(:,numRF) = ForeignBuyAmount;          
            combinedFXderivPortfolio.DeltasAndLinearPos(:,numRF) = ForeignBuyAmount;  

            combinedFXderivPortfolio.FXoptionBuyPositions(:,numRF) = 0 ;
            combinedFXderivPortfolio.Gammas(:,numRF) = 0;
        else
            combinedFXderivPortfolio.FWDBuyPositions(:,index) = combinedFXderivPortfolio.FWDBuyPositions(:,index) + ForeignBuyAmount;        
            combinedFXderivPortfolio.DeltasAndLinearPos(:,index) = combinedFXderivPortfolio.DeltasAndLinearPos(:,index) + ForeignBuyAmount;
        end
    end
end