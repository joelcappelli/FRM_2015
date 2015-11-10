function inputPortfolio = combinationPortfolio1_Price_GetRF(inputPortfolio)
        
    inputPortfolio.Price = inputPortfolio.FX_Portfolio.Price + inputPortfolio.combinedFXderiv_Portfolio.Price;

    numRF = size(inputPortfolio.combinedFXderiv_Portfolio.RF,2);

    inputPortfolio.UnderlyingCode = inputPortfolio.combinedFXderiv_Portfolio.UnderlyingCode;
    inputPortfolio.RF = inputPortfolio.combinedFXderiv_Portfolio.RF;  

    inputPortfolio.DeltasAndLinearPos = inputPortfolio.combinedFXderiv_Portfolio.DeltasAndLinearPos;
    inputPortfolio.Gammas = inputPortfolio.combinedFXderiv_Portfolio.Gammas;

    numSpotPositions = size(inputPortfolio.FX_Portfolio.UnderlyingCode,2);

    for i = 1:numSpotPositions
        tempCode = inputPortfolio.FX_Portfolio.UnderlyingCode{i};

        domesticAmount = inputPortfolio.FX_Portfolio.Currencies(i).DomesticEquivAmount*1000000;
        
        index = strcmp(tempCode,inputPortfolio.UnderlyingCode);    
        if(~sum(index))
            numRF = numRF + 1;
            inputPortfolio.UnderlyingCode{numRF} = tempCode;

            inputPortfolio.RF(:,numRF) = 1./inputPortfolio.FX_Portfolio.RF(:,i);

            inputPortfolio.DeltasAndLinearPos(:,numRF) = domesticAmount;  
            inputPortfolio.Gammas(:,numRF) = 0;
        else
            inputPortfolio.DeltasAndLinearPos(:,index) = inputPortfolio.DeltasAndLinearPos(:,index) + domesticAmount;
        end
    end
end