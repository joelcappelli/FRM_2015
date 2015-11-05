function VAR = FXDerivPortfolio_histSimExactVAR(CI,holdingTdays,FXOptions_Portfolio,FWDFX_Portfolio,valuationDate,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData)
    dates = returnDates(FXOptions_Portfolio.FXSheet,workbookSheetNames,workbookDates);
    valDateIndex = find(dates == valuationDate);
    [valuDateYearFracsDomestic, ~, valuDateDomesticYields] = returnYieldCurveData(FXOptions_Portfolio.DomesticYieldCurveSheet,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);

    FXOptions_RFreturns_252periods = log(FXOptions_Portfolio.RF((valDateIndex-252*holdingTdays):holdingTdays:(valDateIndex-1),:)./FXOptions_Portfolio.RF((valDateIndex-251*holdingTdays):holdingTdays:valDateIndex,:));
    FWDFX_RFreturns_252periods = log(FWDFX_Portfolio.RF((valDateIndex-252*holdingTdays):holdingTdays:(valDateIndex-1),:)./FWDFX_Portfolio.RF((valDateIndex-251*holdingTdays):holdingTdays:valDateIndex,:));
    
    FXOptions_DomesticPerForeignFX_spotRate = repmat(FXOptions_Portfolio.RF(valDateIndex,:),size(FXOptions_RFreturns_252periods,1),1);
    FXOptions_dRates = FXOptions_DomesticPerForeignFX_spotRate.*FXOptions_RFreturns_252periods;
    FXOptions_newRates = FXOptions_DomesticPerForeignFX_spotRate + FXOptions_dRates;
    
    FWDFX_DomesticPerForeignFX_spotRate = repmat(FWDFX_Portfolio.RF(valDateIndex,:),size(FWDFX_RFreturns_252periods,1),1);
    FWDFX_dRates = FWDFX_DomesticPerForeignFX_spotRate.*FWDFX_RFreturns_252periods;
    
    Vnew = zeros(size(FXOptions_newRates,1),1);
    
    numFXOptPositions = size(FXOptions_Portfolio.FXOption,2);
    
    for i = 1:numFXOptPositions  

        %get the same vol used in pricing 
        [valuDateYearFracsForeign, ~, valuDateForeignYields] = returnYieldCurveData(FXOptions_Portfolio.FXOption(i).UnderlyingYieldCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);
        [ForeignPerDomesticFX_rates,~] = returnColData(FXOptions_Portfolio.FXSheet,FXOptions_Portfolio.FXOption(i).UnderlyingExchaRateCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
        DomesticPerForeignFX_rates = 1./ForeignPerDomesticFX_rates;
        returns = log(DomesticPerForeignFX_rates((valDateIndex-360):(valDateIndex-1))./DomesticPerForeignFX_rates((valDateIndex-359):valDateIndex));
        stdv = std(returns);
        vol = sqrt(360)*stdv;
        
        spotDomesticPerForeign = FXOptions_newRates(:,i);

        OwnOrSold = FXOptions_Portfolio.FXOption(i).OwnOrSold;%repmat(ShareOptions_Portfolio.ShareOption(i).OwnOrSold,size(spot,1),1);
        foreignAmount = FXOptions_Portfolio.FXOption(i).ForeignAmount;
        strikeDomesticPerForeign = repmat(FXOptions_Portfolio.FXOption(i).DomesticAmount/FXOptions_Portfolio.FXOption(i).ForeignAmount,size(spotDomesticPerForeign,1),1);

        expiry = repmat(yearfrac(valuationDate,FXOptions_Portfolio.FXOption(i).Exp_Date,1)-1/360,size(spotDomesticPerForeign,1),1);
        callOrPut = FXOptions_Portfolio.FXOption(i).CallOrPut;

        domesticRate = repmat(interpolYield(expiry(1),valuDateYearFracsDomestic,valuDateDomesticYields),size(spotDomesticPerForeign,1),1);
        foreignRate = repmat(interpolYield(expiry(1),valuDateYearFracsForeign,valuDateForeignYields),size(spotDomesticPerForeign,1),1);
        
        Vnew = Vnew + OwnOrSold*foreignAmount*bsPrice(spotDomesticPerForeign, strikeDomesticPerForeign, domesticRate, foreignRate, vol, expiry, callOrPut);       
    end
    
    totalFXOptions_dV = Vnew - repmat(FXOptions_Portfolio.Price,size(Vnew));
    
    % and determine the changes in the portfolio value
    totalFWDFX_dS = zeros(size(FWDFX_dRates,1),1);
    
    numFWDFXPositions = size(FWDFX_Portfolio.FWDFX,2);
    
    for i = 1:numFWDFXPositions
        [valuDateYearFracsBuy, ~, valuDateBuyYields] = returnYieldCurveData(FWDFX_Portfolio.FWDFX(i).BuyYieldCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);

        buyAmount = FWDFX_Portfolio.FWDFX(i).BuyAmount;
        
        expiry = yearfrac(valuationDate,FWDFX_Portfolio.FWDFX(i).Exp_Date,1)-1/360;
        buyFXYield = interpolYield(expiry,valuDateYearFracsBuy,valuDateBuyYields);
        
        totalFWDFX_dS = totalFWDFX_dS + buyAmount*FWDFX_dRates(:,i)*exp(-buyFXYield*expiry); %price in millions AUD / 1000000 
    end
    
    dP = totalFWDFX_dS + totalFXOptions_dV;
    
    % sort the changes in portfolio value
    dP = sort(dP);
    pointer = round( (1-CI)*length(dP) + 0.1 );
    pointer = reshape(pointer, length(pointer),1);
    pointer = max(pointer, ones(length(pointer),1));
    VAR = -dP(pointer); 
end