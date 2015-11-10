function VAR_ETL = equityPortfolio_histSimExactVAR(CI,holdingTdays,ShareOptions_Portfolio,PhysicalShares_Portfolio,valuationDate,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData)
    dates = returnDates(ShareOptions_Portfolio.pricesSheet,workbookSheetNames,workbookDates);
    valDateIndex = find(dates == valuationDate);
    [valuDateYearFracs, ~, valuDateYields] = returnYieldCurveData(ShareOptions_Portfolio.DomesticYieldCurveSheet,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);

    ShareOptions_RFreturns_252periods = log(ShareOptions_Portfolio.RF((valDateIndex-252*holdingTdays):holdingTdays:(valDateIndex-1),:)./ShareOptions_Portfolio.RF((valDateIndex-251*holdingTdays):holdingTdays:valDateIndex,:));
    PhysicalShares_RFreturns_252periods = log(PhysicalShares_Portfolio.RF((valDateIndex-252*holdingTdays):holdingTdays:(valDateIndex-1),:)./PhysicalShares_Portfolio.RF((valDateIndex-251*holdingTdays):holdingTdays:valDateIndex,:));
    
    ShareOptions_S = repmat(ShareOptions_Portfolio.RF(valDateIndex,:),size(ShareOptions_RFreturns_252periods,1),1);
    ShareOptions_dS = ShareOptions_S.*ShareOptions_RFreturns_252periods;
    ShareOptions_Snew = ShareOptions_S + ShareOptions_dS;
    
    PhysicalShares_S = repmat(PhysicalShares_Portfolio.RF(valDateIndex,:),size(PhysicalShares_RFreturns_252periods,1),1);
    PhysicalShares_dS = PhysicalShares_S.*PhysicalShares_RFreturns_252periods;
    
    Vnew = zeros(size(ShareOptions_Snew,1),1);
    
    numSharesOptPositions = size(ShareOptions_Portfolio.ShareOption,2);
    
    for i = 1:numSharesOptPositions  
        
        spot = ShareOptions_Snew(:,i);

        OwnOrSold = ShareOptions_Portfolio.ShareOption(i).OwnOrSold;%repmat(ShareOptions_Portfolio.ShareOption(i).OwnOrSold,size(spot,1),1);
        numShares = ShareOptions_Portfolio.ShareOption(i).numShares;%repmat(ShareOptions_Portfolio.ShareOption(i).numShares,size(spot,1),1);
        strike = repmat(ShareOptions_Portfolio.ShareOption(i).strike,size(spot,1),1);
        div = 0;
        %given
        vol = repmat(ShareOptions_Portfolio.ShareOption(i).vol_pa,size(spot,1),1);

        expiry = repmat(yearfrac(valuationDate,ShareOptions_Portfolio.ShareOption(i).Maturity,1)-1/360,size(spot,1),1);
        callOrPut = repmat(ShareOptions_Portfolio.ShareOption(i).CallOrPut,size(spot,1),1);
        rate = repmat(interpolYield(yearfrac(valuationDate,ShareOptions_Portfolio.ShareOption(i).Maturity,1)-1/360,valuDateYearFracs,valuDateYields),size(spot,1),1);

        Vnew = Vnew + OwnOrSold*numShares*bsPrice(spot, strike, rate, div, vol, expiry, callOrPut);       
    end
    
    totalShareOptions_dV = Vnew - repmat(ShareOptions_Portfolio.Price,size(Vnew));
    
    % and determine the changes in the portfolio value
    totalPhysicalShares_dS = zeros(size(PhysicalShares_dS,1),1);
    
    numSharesPositions = size(PhysicalShares_Portfolio.Share,2);
    
    for i = 1:numSharesPositions
        OwnOrSold = PhysicalShares_Portfolio.Share(i).OwnOrSold;
        totalPhysicalShares_dS = totalPhysicalShares_dS + OwnOrSold*PhysicalShares_Portfolio.Share(i).numShares*PhysicalShares_dS(:,i); %price in millions AUD / 1000000 
    end
    
    dP = totalPhysicalShares_dS + totalShareOptions_dV;
    
    % sort the changes in portfolio value
    dP = sort(dP);
    pointer = round( (1-CI)*length(dP) + 0.1 );
    pointer = reshape(pointer, length(pointer),1);
    pointer = max(pointer, ones(length(pointer),1));
    VAR_ETL(1) = -dP(pointer); 
    VAR_ETL(2) = -mean(dP(1:pointer));
end