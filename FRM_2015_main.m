
%% Financial Risk Management Ass Spring 2015
% Joel Cappelli
% 12137384

function [] = FRM_2015_main()
         
close all;
clear all;
clc;

workbookSheetNames = {};
workbookDates = {};
workbookCodes = {};
workbookNumericData = {};
    
loadData = 1;

if(loadData)   
    load('dateFormatIn.mat','dateFormatIn');
    load('valuationDate.mat','valuationDate');
    load('workbookSheetNames.mat','workbookSheetNames');
    load('workbookDates.mat','workbookDates');
    load('workbookCodes.mat','workbookCodes');
    load('workbookNumericData.mat','workbookNumericData');   
else
    %date to time format
    dateFormatIn = 'dd/mm/yyyy';
    valuationDate_dateFormat = '7/08/2015';
    valuationDate = datenum(valuationDate_dateFormat,dateFormatIn);
    save('valuationDate.mat','valuationDate');
    
    fileName = '2015_FRM_ASSIGNMENT_DATA_updated.xlsx';     
    workbookSheetNames = {'stock prices';...
                          'exchange_rates';...
                          'AUSTRALIA_ZERO_CURVE';...
                          'EURO_ZERO_CURVE';...
                          'US_ZERO_CURVE';...
                          'JAPAN_ZERO_CURVE';...
                          'SWISS_ZERO_CURVE';...
                          'Interest Rate Swap Data';...
                          'Sheet7';...
                          };       
    firstRowOfCodesPerSheet = [2;...
                               3;...
                               2;...
                               2;...
                               2;...
                               2;...
                               2;...
                               1;...
                               3];
                           
    readExcelSpreadsheet_SaveInputs(fileName,workbookSheetNames,firstRowOfCodesPerSheet,dateFormatIn);
    
    load('dateFormatIn.mat','dateFormatIn');
    load('valuationDate.mat','valuationDate');
    load('workbookSheetNames.mat','workbookSheetNames');
    load('workbookDates.mat','workbookDates');
    load('workbookCodes.mat','workbookCodes');
    load('workbookNumericData.mat','workbookNumericData');   
end
    
%%
% Portfolio 1
% Physical Bonds
% Issuer Coupon rate
% p.a
% Maturity Next Coupon
% Date
% Face Value
% (Millions)
% Com G 4.75% 15-Jun-2016 15-Dec-2015 10
% Com G 4.25% 21-Jul-2017 21-Jan-2016 5
% Com G 5.50% 21-Jan-2018 21-Jan-2016 8
% Com G 5.25% 15-Mar-2019 15-Sep-2015 10
% Com G 4.50% 15-Apr-2020 15-Oct-2015 5

%might help in future to write the C_frequ using yearfrac function
%dependent upon day count basis used
couponBond1 = struct('Price',0,'C_rate_pa',0.0475,'Maturity',datenum('15/06/2016',dateFormatIn),'FV',10,'C_frequ',0.5);
couponBond2 = struct('Price',0,'C_rate_pa',0.0425,'Maturity',datenum('21/07/2017 ',dateFormatIn),'FV',5,'C_frequ',0.5);
couponBond3 = struct('Price',0,'C_rate_pa',0.055,'Maturity',datenum('21/01/2018',dateFormatIn),'FV',8,'C_frequ',0.5);
couponBond4 = struct('Price',0,'C_rate_pa',0.0525,'Maturity',datenum('15/03/2019 ',dateFormatIn),'FV',10,'C_frequ',0.5);
couponBond5 = struct('Price',0,'C_rate_pa',0.045,'Maturity',datenum('15/04/2019 ',dateFormatIn),'FV',5,'C_frequ',0.5);  

%assume same yield curve risk factors for all coupon bonds 
% can price and compute VAR separately for portfolio of bonds per yield
% curve
couponBond_Portfolio = struct('CouponBond',[couponBond1 couponBond2 couponBond3 couponBond4 couponBond5],'Price',0,'yieldCurveSheet','AUSTRALIA_ZERO_CURVE','RF',[],'PV_CF',[],'ZCB_yearFrac',[]);
couponBond_Portfolio = decomposeBondPortfolio(couponBond_Portfolio,valuationDate,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);

fprintf('Portfolio 1: Bond portfolio \n\n');
fprintf('Valuation date: %s\n',datestr(valuationDate,dateFormatIn));
for i = 1:size(couponBond_Portfolio.CouponBond,2)
    fprintf('Value of bond %d: $%f  million AUD\n', i,couponBond_Portfolio.CouponBond(i).Price);
end
fprintf('Total value of bond portfolio: $%f  million AUD\n\n', couponBond_Portfolio.Price);
    
CI = [0.95,0.99];
holdingTdays = [1,10];

for i = 1:size(CI,2)
    for j = 1:size(holdingTdays,2)
        couponBond_Portfolio_deltaNormAnalyVAR = BondPortfolio_deltaNormAnalyVAR(CI(i),holdingTdays(j),couponBond_Portfolio,valuationDate,workbookSheetNames,workbookDates);
        couponBond_Portfolio_deltaGammaHistSimVaR = BondPortfolio_deltaGammaHistSimVaR(CI(i),holdingTdays(j),couponBond_Portfolio,valuationDate,workbookSheetNames,workbookDates);
        
        fprintf('VAR with CI: %.2f%% and holding period of %d days\n', 100*CI(i),holdingTdays(j));
        fprintf('deltaNormAnalyVAR of bond portfolio $%f  million AUD\n', couponBond_Portfolio_deltaNormAnalyVAR);
        fprintf('deltaGammaHistSimVaR of bond portfolio $%f  million AUD\n\n', couponBond_Portfolio_deltaGammaHistSimVaR);
    end
end

fprintf('#################################################################################################\n\n');

%%
% Portfolio 2
% Spot Foreign Exchange
% Currency Currency
% Description
% AUD
% Million
% Equivalents
% USD US $ -40
% EUR Euro 60
% GBP UK � 55
% NZD New Zealand $ 30
% INR Indian Rupee -50
% JPY Yen -30

%AUD $ to US $	 AUD $ TO UK �  	 AUD $ TO EURO	AUD $ TO CHF	AUD $
%TO INR (Indian Rupee)	AUD $ TO NZD $	AUD $ TO JPY

currency1 = struct('DomesticEquivAmount',-40,'exchaRateCode','AUD $ to US $','Currency','USD');
currency2 = struct('DomesticEquivAmount',60,'exchaRateCode',' AUD $ TO EURO','Currency','EUR');
currency3 = struct('DomesticEquivAmount',55,'exchaRateCode',' AUD $ TO UK �  ','Currency','GBP');
currency4 = struct('DomesticEquivAmount',30,'exchaRateCode','AUD $ TO NZD $','Currency','NZD');
currency5 = struct('DomesticEquivAmount',-50,'exchaRateCode','AUD $ TO INR (Indian Rupee)','Currency','INR');
currency6 = struct('DomesticEquivAmount',-30,'exchaRateCode','AUD $ TO JPY','Currency','JPY');  

FX_Portfolio = struct('Currencies',[currency1 currency2 currency3 currency4 currency5 currency6],'Price',0,'RF',[],'weights',[],'exchaRateSheet','exchange_rates');
FX_Portfolio = FXPortfolio_Price_GetRF(FX_Portfolio,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);

fprintf('Portfolio 2: Spot Foreign Exchange \n\n');
fprintf('Valuation date: %s\n',datestr(valuationDate,dateFormatIn));
for i = 1:size(FX_Portfolio.Currencies,2)
    fprintf('Value of currency position %d: $%f  million AUD\n', i,FX_Portfolio.Currencies(i).DomesticEquivAmount);
end
fprintf('Total value of FX portfolio: $%f  million AUD\n\n', FX_Portfolio.Price);
    
CI = [0.95,0.99];
holdingTdays = [1,10];

for i = 1:size(CI,2)
    for j = 1:size(holdingTdays,2)
        FX_Portfolio_analyExactVAR = FXPortfolio_analyExactVAR(FX_Portfolio, CI(i), holdingTdays(j),workbookSheetNames,workbookDates,valuationDate);
        FX_Portfolio_histVAR = FXPortfolio_histExactVAR(FX_Portfolio, CI(i), holdingTdays(j),workbookSheetNames,workbookDates,valuationDate);
        
        fprintf('VAR with CI: %.2f%% and holding period of %d days\n', 100*CI(i),holdingTdays(j));
        fprintf('analyExactVAR of FX portfolio $%f  million AUD\n', FX_Portfolio_analyExactVAR);
        fprintf('histVAR of FX portfolio $%f  million AUD\n\n', FX_Portfolio_histVAR);
    end
end

fprintf('#################################################################################################\n\n');

%%
% Portfolio 3
% Foreign Exchange Options & Forward Foreign Exchange Contracts
% Expiration
% Date
% Put/C
% all
% Bought/
% Underlying
% Asset Amount
% AUD
% Amount
% (Millions)
% Strike Sold
% 09-Oct-2015 Call Bought USD 150.00 205.68 0.7293
% 11-Dec-2015 Put Bough USD 210.00 280.15 0.7496
% 13-Dec-2015 Call Bought CHF 100.00 138.12 0.7240
% 08-Feb-2016 Call sold Euro 180.00 265.53 0.6779
% 05-Apr-2016 Put Bought Euro 220.00 337.99 0.6509
% bought is positive value
% sold is negative value

fxoption1 = struct('Price',0,'Exp_Date',datenum('9/10/2015',dateFormatIn),'UnderlyingExchaRateCode','AUD $ to US $','UnderlyingYieldCode','US_ZERO_CURVE','CallOrPut',1,'OwnOrSold',1,'ForeignAmount',150.00,'DomesticAmount',205.68);
fxoption2 = struct('Price',0,'Exp_Date',datenum('11/12/2015',dateFormatIn),'UnderlyingExchaRateCode','AUD $ to US $','UnderlyingYieldCode','US_ZERO_CURVE','CallOrPut',-1,'OwnOrSold',1,'ForeignAmount',210.00,'DomesticAmount',280.15);
fxoption3 = struct('Price',0,'Exp_Date',datenum('13/12/2015',dateFormatIn),'UnderlyingExchaRateCode','AUD $ TO CHF','UnderlyingYieldCode','SWISS_ZERO_CURVE','CallOrPut',1,'OwnOrSold',1,'ForeignAmount',100.00,'DomesticAmount',138.12);
fxoption4 = struct('Price',0,'Exp_Date',datenum('08/02/2016',dateFormatIn),'UnderlyingExchaRateCode',' AUD $ TO EURO','UnderlyingYieldCode','EURO_ZERO_CURVE','CallOrPut',1,'OwnOrSold',-1,'ForeignAmount',180.00,'DomesticAmount',265.53);
fxoption5 = struct('Price',0,'Exp_Date',datenum('05/04/2016',dateFormatIn),'UnderlyingExchaRateCode',' AUD $ TO EURO','UnderlyingYieldCode','EURO_ZERO_CURVE','CallOrPut',-1,'OwnOrSold',1,'ForeignAmount',220.00,'DomesticAmount',337.99);

FXOptions_Portfolio = struct('FXOption',[fxoption1 fxoption2 fxoption3 fxoption4 fxoption5],'Price',0);
numFXOptPositions = size(FXOptions_Portfolio.FXOption,2);

[valuDateYearFracsDomestic, codesDomesticYields, valuDateDomesticYields] = returnYieldCurveData('AUSTRALIA_ZERO_CURVE',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);

for i = 1:numFXOptPositions
    [valuDateYearFracsForeign, codesForeignYields, valuDateForeignYields] = returnYieldCurveData(FXOptions_Portfolio.FXOption(i).UnderlyingYieldCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);
    [ForeignPerDomesticFX_rates,dates] = returnColData('exchange_rates',FXOptions_Portfolio.FXOption(i).UnderlyingExchaRateCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
    DomesticPerForeignFX_rates = 1./ForeignPerDomesticFX_rates;
    valDateIndex = find(dates == valuationDate);
    spotDomesticPerForeign = DomesticPerForeignFX_rates(valDateIndex);
    
    % assuming daily data
%     returns = diff(DomesticPerForeignFX_rates((valDateIndex-359):valDateIndex)) ./ DomesticPerForeignFX_rates((valDateIndex-359):(valDateIndex-1));
%     stdv = std(returns);
%     vol = sqrt(360)*stdv;

    %cont compounded returns
    returns = log(DomesticPerForeignFX_rates((valDateIndex-360):(valDateIndex-1))./DomesticPerForeignFX_rates((valDateIndex-359):valDateIndex));
    stdv = std(returns);
    vol = sqrt(360)*stdv;
    
    OwnOrSold = FXOptions_Portfolio.FXOption(i).OwnOrSold;
    foreignAmount = FXOptions_Portfolio.FXOption(i).ForeignAmount;
    strikeDomesticPerForeign = FXOptions_Portfolio.FXOption(i).DomesticAmount/FXOptions_Portfolio.FXOption(i).ForeignAmount;
    
    expiry = yearfrac(valuationDate,FXOptions_Portfolio.FXOption(i).Exp_Date,1);
    callOrPut = FXOptions_Portfolio.FXOption(i).CallOrPut;
    domesticRate = interpolYield(expiry,valuDateYearFracsDomestic,valuDateDomesticYields);
    foreignRate = interpolYield(expiry,valuDateYearFracsForeign,valuDateForeignYields);
        
    FXOptions_Portfolio.FXOption(i).Price = OwnOrSold*foreignAmount*bsPrice(spotDomesticPerForeign, strikeDomesticPerForeign, domesticRate, foreignRate, vol, expiry, callOrPut);
    FXOptions_Portfolio.Price = FXOptions_Portfolio.Price + FXOptions_Portfolio.FXOption(i).Price;
end

% in millions 
fprintf('Portfolio 3: Foreign Exchange Options & Forward Foreign Exchange Contracts \n\n');
fprintf('Valuation date: %s\n',datestr(valuationDate,dateFormatIn));
for i = 1:size(FXOptions_Portfolio.FXOption,2)
    fprintf('Value of FXOption position %d: $%f  million AUD\n', i,FXOptions_Portfolio.FXOption(i).Price);
end
fprintf('Total value of FXOption portfolio: $%f  million AUD\n\n', FXOptions_Portfolio.Price);

%%
% Portfolio 3
% Forward Foreign Exchange Contracts
% Expiry Buy
% Currency
% Buy Sell
% Amount
% (Millions)
% Contracted
% Forward Rate
% (K)
% Amount
% (Millions
% )
% Sell
% Currency
% 07-Nov-2015 JPY 1500 AUD 16.38 91.57
% 08-Dec-2015 USD 50 AUD 66.83 0.7482
% 15-Jan-2016 EUR 30 AUD 44.67 0.6715

fwdfx1 = struct('Price',0,'Exp_Date',datenum('07/11/2015',dateFormatIn),'BuyYieldCode','JAPAN_ZERO_CURVE','BuyAmount',1500,'SellYieldCode','AUSTRALIA_ZERO_CURVE','SellAmount',16.38,'SellExchaRateCode','AUD $ TO JPY');
fwdfx2 = struct('Price',0,'Exp_Date',datenum('08/12/2015',dateFormatIn),'BuyYieldCode','US_ZERO_CURVE','BuyAmount',50,'SellYieldCode','AUSTRALIA_ZERO_CURVE','SellAmount',66.83,'SellExchaRateCode','AUD $ to US $');
fwdfx3 = struct('Price',0,'Exp_Date',datenum('15/01/2016',dateFormatIn),'BuyYieldCode','EURO_ZERO_CURVE','BuyAmount',30,'SellYieldCode','AUSTRALIA_ZERO_CURVE','SellAmount',44.67,'SellExchaRateCode',' AUD $ TO EURO');

FWDFX_Portfolio = struct('FWDFX',[fwdfx1 fwdfx2 fwdfx3],'Price',0);
numFWDFXPositions = size(FWDFX_Portfolio.FWDFX,2);

for i = 1:numFWDFXPositions
    [valuDateYearFracsBuy, codesBuyYields, valuDateBuyYields] = returnYieldCurveData(FWDFX_Portfolio.FWDFX(i).BuyYieldCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);
    [valuDateYearFracsSell, codesSellYields, valuDateSellYields] = returnYieldCurveData(FWDFX_Portfolio.FWDFX(i).SellYieldCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);
    
    [sellFX_rates,dates] = returnColData('exchange_rates',FWDFX_Portfolio.FWDFX(i).SellExchaRateCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
    spotSellFX = sellFX_rates(dates == valuationDate);
    
    sellAmount = FWDFX_Portfolio.FWDFX(i).SellAmount;
    strikeSellFX = FWDFX_Portfolio.FWDFX(i).BuyAmount/FWDFX_Portfolio.FWDFX(i).SellAmount;
    
    expiry = yearfrac(valuationDate,FWDFX_Portfolio.FWDFX(i).Exp_Date,1);
    sellFXYield = interpolYield(expiry,valuDateYearFracsSell,valuDateSellYields);
    buyFXYield = interpolYield(expiry,valuDateYearFracsBuy,valuDateBuyYields);
        
    FWDFX_Portfolio.FWDFX(i).Price = sellAmount*(spotSellFX*exp(-buyFXYield*expiry) - strikeSellFX*exp(-sellFXYield*expiry));
    FWDFX_Portfolio.Price = FWDFX_Portfolio.Price + FWDFX_Portfolio.FWDFX(i).Price;
end

for i = 1:size(FWDFX_Portfolio.FWDFX,2)
    fprintf('Value of FWDFX position %d: $%f  million AUD\n', i,FWDFX_Portfolio.FWDFX(i).Price);
end
fprintf('Total value of FWDFX portfolio: $%f  million AUD\n\n', FWDFX_Portfolio.Price);

fprintf('#################################################################################################\n\n');


%%
% Portfolio 4
% shares and share options
% XJO	BHP	CBA	ANZ	RIO	NCM	WPL	TLS
% bought is positive value
% sold is negative value

share1 = struct('Price',0,'IssuerCode','CBA','OwnOrSold',-1,'numShares',60000);
share2 = struct('Price',0,'IssuerCode','ANZ','OwnOrSold',1,'numShares',80000);
share3 = struct('Price',0,'IssuerCode','RIO','OwnOrSold',1,'numShares',100000);
share4 = struct('Price',0,'IssuerCode','NCM','OwnOrSold',-1,'numShares',200000);
share5 = struct('Price',0,'IssuerCode','WPL','OwnOrSold',1,'numShares',150000);
share6 = struct('Price',0,'IssuerCode','TLS','OwnOrSold',-1,'numShares',250000); 

PhysicalShares_Portfolio = struct('Share',[share1 share2 share3 share4 share5 share6],'Price',0,'RF',[],'weights',[],'pricesSheet','stock prices');
numSharesPositions = size(PhysicalShares_Portfolio.Share,2);
PhysicalShares_Portfolio.weights = zeros(1,numSharesPositions);
numRF = 0;
for i = 1:numSharesPositions
    [stockPrices,dates] = returnColData(PhysicalShares_Portfolio.pricesSheet,PhysicalShares_Portfolio.Share(i).IssuerCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
    valDateIndex = find(dates == valuationDate);
    spot = stockPrices(valDateIndex);
        
    numRF = numRF + 1;
    PhysicalShares_Portfolio.RF(:,numRF) = stockPrices;  
    %using cont compounding returns - past year of data
    %PhysicalShares_Portfolio.Returns(:,numRF) = log(stockPrices((valDateIndex-252):(valDateIndex-1))./stockPrices((valDateIndex-251):valDateIndex));
    %PhysicalShares_Portfolio.Returns(:,numRF) = log(stockPrices((valDateIndex-360):(valDateIndex-1))./stockPrices((valDateIndex-359):valDateIndex));
    
    OwnOrSold = PhysicalShares_Portfolio.Share(i).OwnOrSold;
    PhysicalShares_Portfolio.Share(i).Price = OwnOrSold*PhysicalShares_Portfolio.Share(i).numShares*spot; %price in millions AUD / 1000000   
    PhysicalShares_Portfolio.Price = PhysicalShares_Portfolio.Price + PhysicalShares_Portfolio.Share(i).Price;
end

% in millions 
PhysicalShares_Portfolio.Price;

for i = 1:numSharesPositions
    PhysicalShares_Portfolio.weights(i) = PhysicalShares_Portfolio.Share(i).Price/PhysicalShares_Portfolio.Price;
end

% CI = 0.99;
% alpha = norminv(CI);
% holdingTdays = 1;
% avReturns = mean(PhysicalShares_Portfolio.Returns);
% covars = cov(PhysicalShares_Portfolio.Returns);
% mu    = sum(PhysicalShares_Portfolio.weights.*avReturns);
% x = 
% PhysicalShares_Portfolio_analyExactVAR = sqrt(holdingTdays)*(-PhysicalShares_Portfolio.Price*mu + alpha*sqrt(holdingTdays)*sqrt(x'*covars*x));   
% 
% sigma = sqrt( PhysicalShares_Portfolio.weights * covars * PhysicalShares_Portfolio.weights' );
% VaR = -sqrt(holdingTdays)*PhysicalShares_Portfolio.Price*(mu - sigma * norminv(CI));
% 
% portReturns = sort(PhysicalShares_Portfolio.Returns*PhysicalShares_Portfolio.weights');
% pointer = round( (1-CI)*length(portReturns) + 0.1 );
% pointer = reshape(pointer, length(pointer),1);
% pointer = max(pointer, ones(length(pointer),1));
% 
% PhysicalShares_Portfolio_histVAR = -sqrt(holdingTdays)*PhysicalShares_Portfolio.Price * portReturns(pointer);

% in $  
fprintf('Portfolio 4: Shares and share options \n\n');
fprintf('Valuation date: %s\n',datestr(valuationDate,dateFormatIn));
for i = 1:size(PhysicalShares_Portfolio.Share,2)
    fprintf('Value of PhysicalShares position %d: $%f  million AUD\n', i,PhysicalShares_Portfolio.Share(i).Price/1000000);
end
fprintf('Total value of PhysicalShares portfolio: $%f  million AUD\n\n', PhysicalShares_Portfolio.Price/1000000);



option1 = struct('Price',0,'Delta',0,'Gamma',0,'Maturity',datenum('9/10/2015',dateFormatIn),'UnderlyingCode','BHP','CallOrPut',1,'OwnOrSold',1,'numShares',250000,'strike',28.00,'vol_pa',0.2953);
option2 = struct('Price',0,'Delta',0,'Gamma',0,'Maturity',datenum('8/01/2016',dateFormatIn),'UnderlyingCode','RIO','CallOrPut',-1,'OwnOrSold',1,'numShares',200000,'strike',54.00,'vol_pa',0.2606);
option3 = struct('Price',0,'Delta',0,'Gamma',0,'Maturity',datenum('12/03/2016',dateFormatIn),'UnderlyingCode','RIO','CallOrPut',1,'OwnOrSold',1,'numShares',200000,'strike',53.00,'vol_pa',0.2648);
option4 = struct('Price',0,'Delta',0,'Gamma',0,'Maturity',datenum('04/03/2016',dateFormatIn),'UnderlyingCode','NCM','CallOrPut',-1,'OwnOrSold',-1,'numShares',200000,'strike',12.00,'vol_pa',0.4418);
option5 = struct('Price',0,'Delta',0,'Gamma',0,'Maturity',datenum('07/04/2016',dateFormatIn),'UnderlyingCode','NCM','CallOrPut',1,'OwnOrSold',-1,'numShares',250000,'strike',10.00,'vol_pa',0.44);
option6 = struct('Price',0,'Delta',0,'Gamma',0,'Maturity',datenum('09/06/2016',dateFormatIn),'UnderlyingCode','WPL','CallOrPut',-1,'OwnOrSold',1,'numShares',200000,'strike',33.00,'vol_pa',0.2522);

ShareOptions_Portfolio = struct('ShareOption',[option1 option2 option3 option4 option5 option6],'Price',0,'RF',[],'pricesSheet','stock prices');
numSharesOptPositions = size(ShareOptions_Portfolio.ShareOption,2);

[valuDateYearFracs, codes, valuDateYields] = returnYieldCurveData('AUSTRALIA_ZERO_CURVE',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);
numRF = 0;
for i = 1:numSharesOptPositions      
    [stockPrices,dates] = returnColData(ShareOptions_Portfolio.pricesSheet,ShareOptions_Portfolio.ShareOption(i).UnderlyingCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
    valDateIndex = find(dates == valuationDate);
    spot = stockPrices(valDateIndex);
    
    % assuming daily data
    %returns = diff(stockPrices((valDateIndex-359):valDateIndex)) ./ stockPrices((valDateIndex-359):(valDateIndex-1));
    %stdv = std(returns);
    %vol = sqrt(360)*stdv;
    
    %cont compounded returns
    %returns = log(stockPrices((valDateIndex-360):(valDateIndex-1))./stockPrices((valDateIndex-359):valDateIndex));
    %stdv = std(returns);
    %vol = sqrt(360)*stdv;
    
    numRF = numRF + 1;
    ShareOptions_Portfolio.RF(:,numRF) = stockPrices;  
 
    OwnOrSold = ShareOptions_Portfolio.ShareOption(i).OwnOrSold;
    numShares = ShareOptions_Portfolio.ShareOption(i).numShares;
    strike = ShareOptions_Portfolio.ShareOption(i).strike;
    div = 0;
    vol = ShareOptions_Portfolio.ShareOption(i).vol_pa;
    
    expiry = yearfrac(valuationDate,ShareOptions_Portfolio.ShareOption(i).Maturity,1);
    callOrPut = ShareOptions_Portfolio.ShareOption(i).CallOrPut;
    rate = interpolYield(expiry,valuDateYearFracs,valuDateYields);
    
    ShareOptions_Portfolio.ShareOption(i).Price = OwnOrSold*numShares*bsPrice(spot, strike, rate, div, vol, expiry, callOrPut);
    ShareOptions_Portfolio.ShareOption(i).Delta = bsDelta(spot, strike, rate, div, vol, expiry, callOrPut);
    ShareOptions_Portfolio.ShareOption(i).Gamma = bsGamma(spot, strike, rate, div, vol, expiry);
    
    ShareOptions_Portfolio.Price = ShareOptions_Portfolio.Price + ShareOptions_Portfolio.ShareOption(i).Price;
end

% in $  
for i = 1:size(ShareOptions_Portfolio.ShareOption,2)
    fprintf('Value of ShareOptions position %d: $%f  million AUD\n', i,ShareOptions_Portfolio.ShareOption(i).Price/1000000);
end
fprintf('Total value of ShareOptions portfolio: $%f  million AUD\n\n', ShareOptions_Portfolio.Price/1000000);


ShareOptions_Portfolio
PhysicalShares_Portfolio

go through each portfolio, look for the same rf create array of independent riskfactors 
fprintf('#################################################################################################\n\n');


%%
% Portfolio 5
% interest rate swaps
% Maturity
% Notional
% Amount
% (AUD
% Million)
% Payer
% /Receiver
% Swap
% Rate
% (p.a.)
% Settlement
% 07-Nov-2015 $20 Receiver 2.20% Quarterly
% 07-Aug-2016 $80 Payer 2.30% Semi-annual
% 06-Nov-2016 $70 Receiver 2.45% Quarterly

%might help in future to write the sett_frequ using yearfrac function
%dependent upon day count basis used
swap1 = struct('Price',0,'PayerOrRec',1,'Maturity',datenum('07/11/2015',dateFormatIn),'Notional',20,'Sett_period',0.25,'SwapRate_pa',0.022);
swap2 = struct('Price',0,'PayerOrRec',-1,'Maturity',datenum('07/08/2016',dateFormatIn),'Notional',80,'Sett_period',0.5,'SwapRate_pa',0.023);
swap3 = struct('Price',0,'PayerOrRec',1,'Maturity',datenum('06/11/2016',dateFormatIn),'Notional',70,'Sett_period',0.25,'SwapRate_pa',0.0245);
        
swap_Portfolio = struct('Swap',[swap1 swap2 swap3],'Price',0);
numSwaps = size(swap_Portfolio.Swap,2);
%% NOTE: VALUATION DATE IS INCORRECT BECAUSE DATA HAD ZERO RATES 
% SUBTRACTED ONE FROM VALUATION DATE TO TEST METHOD
%%[valuDateIRSYearFracs, IRScodes, valuDateIRSYields] = returnIRSCurveData('Interest Rate Swap Data',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);
[valuDateIRSYearFracs, IRScodes, valuDateIRSYields] = returnIRSCurveData('Interest Rate Swap Data',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate-1);

for i = 1:numSwaps

    swap_Price = 0;
    Notional = swap_Portfolio.Swap(i).Notional;
    
    swapYearFrac = yearfrac(valuationDate,swap_Portfolio.Swap(i).Maturity,1);
    while(swapYearFrac >= swap_Portfolio.Swap(i).Sett_period)        
        ZCB = ZCB_price_contComp(swapYearFrac,interpolYield(swapYearFrac,valuDateIRSYearFracs,valuDateIRSYields));
        PV_fixedLeg = Notional*swap_Portfolio.Swap(i).Sett_period*swap_Portfolio.Swap(i).SwapRate_pa*ZCB;
        
        T2 = swapYearFrac;
        T1 = T2 - swap_Portfolio.Swap(i).Sett_period;
        yieldT2 = interpolYield(T2,valuDateYearFracs,valuDateYields);
        yieldT1 = interpolYield(T1,valuDateYearFracs,valuDateYields);
        PV_floatingLeg = Notional*swap_Portfolio.Swap(i).Sett_period*ForwardRate_contComp(T1,yieldT1,T2,yieldT2)*ZCB;
        
        swapYearFrac = swapYearFrac - swap_Portfolio.Swap(i).Sett_period;
        swap_Price = swap_Price + swap_Portfolio.Swap(i).PayerOrRec*(PV_fixedLeg - PV_floatingLeg);
    end
    
    %work out accural interest since last coupon date
    swap_Price = swap_Price + swapYearFrac*swap_Portfolio.Swap(i).PayerOrRec*(PV_fixedLeg - PV_floatingLeg)/swap_Portfolio.Swap(i).Sett_period;    
    swap_Portfolio.Swap(i).Price = swap_Price;

    swap_Portfolio.Price = swap_Portfolio.Price + swap_Portfolio.Swap(i).Price;
end

% in millions 
fprintf('Portfolio 5: Interest rate swaps \n\n');
fprintf('Valuation date: %s\n',datestr(valuationDate-1,dateFormatIn));
for i = 1:size(swap_Portfolio.Swap,2)
    fprintf('Value of IRS position %d: $%f  million AUD\n', i,swap_Portfolio.Swap(i).Price);
end
fprintf('Total value of IRS portfolio: $%f  million AUD\n\n', swap_Portfolio.Price);

fprintf('#################################################################################################\n\n');


end
