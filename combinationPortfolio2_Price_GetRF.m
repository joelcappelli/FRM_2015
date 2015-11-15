function inputPortfolio = combinationPortfolio2_Price_GetRF(inputPortfolio)
        
    inputPortfolio.Price = inputPortfolio.Bond_Portfolio.Price + inputPortfolio.physicalSharesEquity_Portfolio.Price/1000000;

    %initially
    numRF = size(inputPortfolio.physicalSharesEquity_Portfolio.RF,2);
    inputPortfolio.RF_type = repmat({'stock'},1,numRF);
    inputPortfolio.RF = inputPortfolio.physicalSharesEquity_Portfolio.RF;  

    inputPortfolio.DeltasAndLinearPos = inputPortfolio.physicalSharesEquity_Portfolio.DeltasAndLinearPos;
    inputPortfolio.Gammas = zeros(1,numRF);
    
    numZCBonds = size(inputPortfolio.Bond_Portfolio.RF,2);

    for i = 1:numZCBonds
            numRF = numRF + 1;
            inputPortfolio.RF_type{numRF} = 'bond';
            inputPortfolio.RF(:,numRF) = inputPortfolio.Bond_Portfolio.RF(:,i);
            inputPortfolio.Gammas(:,numRF) = 1000000*inputPortfolio.Bond_Portfolio.PV_CF(i)*(inputPortfolio.Bond_Portfolio.ZCB_yearFrac(i))^2;
            inputPortfolio.DeltasAndLinearPos(:,numRF) = 1000000*inputPortfolio.Bond_Portfolio.PV_CF(i)*inputPortfolio.Bond_Portfolio.ZCB_yearFrac(i);  
    end
end