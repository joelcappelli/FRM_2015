
%% Financial Risk Management Ass Spring 2015
% Joel Cappelli
% 12137384

function [] = FRM_2015_main()
         
close all;
clear all;
clc;

%date to time format
formatIn = 'dd/mm/yyyy';
valuationDate_dateFormat = '7/08/2015';
valuationDate = datenum(valuationDate_dateFormat,formatIn);

loadData = 1;

if(loadData)
    workbookSheetNames = {};
    workbookDates = {};
    workbookCodes = {};
    workbookNumericData = {};
    load('workbookSheetNames.mat');    
    load('workbookDates.mat');
    load('workbookCodes.mat');
    load('workbookNumericData.mat');
else
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
                       
    numSheets = size(workbookSheetNames,1);
    %create cell array containing 
    %there is always the same number of data row entries per sheet but 
    workbookCodes = cell(1,numSheets);
    workbookNumericData = cell(1,numSheets);
    workbookDates = cell(1,numSheets);

    %%
    % open excel spreadsheet and read in data
    disp('Reading excel data...');
    for i = 1:numSheets
        [NUMERIC,TXT]=xlsread(fileName,workbookSheetNames{i});

        temp_sheetDates = datenum(TXT((firstRowOfCodesPerSheet(i)+1):end,1),formatIn);
        temp_sheetCodes = TXT(firstRowOfCodesPerSheet(i),2:end);

        workbookDates{i} = temp_sheetDates;
        workbookCodes{i} = temp_sheetCodes;
        workbookNumericData{i} = NUMERIC;
    end
    disp('Finished importing excel data...');
    disp('Saving data...');
    save('workbookSheetNames.mat','workbookSheetNames');
    save('workbookDates.mat','workbookDates');
    save('workbookCodes.mat','workbookCodes');
    save('workbookNumericData.mat','workbookNumericData');
end

%% test to grab some data
[BBSR5M,dates] = returnColData('Interest Rate Swap Data','BBSR5M',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
[BBSR5M_check] = returnColData('Interest Rate Swap Data','BBSR5M',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);

[AUD_INR,dates] = returnColData('exchange_rates','AUD $ TO INR (Indian Rupee)',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
[AUD_INR_check] = returnColData('exchange_rates','AUD $ TO INR (Indian Rupee)',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);

[yields,yearCodes] = returnRowData('AUSTRALIA_ZERO_CURVE',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);
[exRate,exRCodes] = returnRowData('exchange_rates',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);

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
couponBond1 = struct('Price',0,'C_rate_pa',0.0475,'Maturity',datenum('15/06/2016',formatIn),'FV',10,'C_frequ',0.5,'RF',[],'PV_CF',[],'ZCB_yearFrac',[]);
couponBond2 = struct('Price',0,'C_rate_pa',0.0425,'Maturity',datenum('21/07/2017 ',formatIn),'FV',5,'C_frequ',0.5,'RF',[],'PV_CF',[],'ZCB_yearFrac',[]);
couponBond3 = struct('Price',0,'C_rate_pa',0.055,'Maturity',datenum('21/01/2018',formatIn),'FV',8,'C_frequ',0.5,'RF',[],'PV_CF',[],'ZCB_yearFrac',[]);
couponBond4 = struct('Price',0,'C_rate_pa',0.0525,'Maturity',datenum('15/03/2019 ',formatIn),'FV',10,'C_frequ',0.5,'RF',[],'PV_CF',[],'ZCB_yearFrac',[]);
couponBond5 = struct('Price',0,'C_rate_pa',0.045,'Maturity',datenum('15/04/2019 ',formatIn),'FV',5,'C_frequ',0.5,'RF',[],'PV_CF',[],'ZCB_yearFrac',[]);   
                 
couponBond_Portfolio = struct('CouponBonds',[couponBond1 couponBond2 couponBond3 couponBond4 couponBond5],'Price',0,'RF',[],'x',[]);
numBonds = size(couponBond_Portfolio.CouponBonds,2);

[valuDateYearFracs, codes, valuDateYields] = returnYieldCurveData('AUSTRALIA_ZERO_CURVE',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);

%growing column vectors of risk factors which are the coupon bonds
%decomposed into ZCB with assoicated linearly interpolated yield data for
%each cash flow 
numRF = 0;
% make sure each risk factor is column vector to be used with covar matlab
% method
for i = 1:numBonds

    couponBond_RF = [];
    couponBond_PV_CF = [];
    couponBond_ZCB_yearFrac = [];
    couponBond_Price = 0;
    
    FV = couponBond_Portfolio.CouponBonds(i).FV;
    couponRate = couponBond_Portfolio.CouponBonds(i).C_rate_pa*couponBond_Portfolio.CouponBonds(i).C_frequ;
    
    couponDateYearFrac = yearfrac(valuationDate,couponBond_Portfolio.CouponBonds(i).Maturity,1);
    maturityPayment = 1;
    %while(couponDateYearFrac >= couponBond_Portfolio.CouponBonds(i).C_frequ)  
    while(couponDateYearFrac > 0) 
        ZCB = ZCB_price_contComp(couponDateYearFrac,interpolYield(couponDateYearFrac,valuDateYearFracs,valuDateYields));
        if(maturityPayment)
            PV_CF = (1+couponRate)*FV*ZCB;
            maturityPayment = 0;
        else
            PV_CF = couponRate*FV*ZCB;
        end

        numRF = numRF + 1;
        couponBond_Portfolio.RF(:,numRF) = ZCB_yieldCurveRiskFactor(couponDateYearFrac,valuDateYearFracs,codes,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
        couponBond_RF = [couponBond_RF, couponBond_Portfolio.RF(:,numRF)];
        couponBond_Portfolio.x(numRF,:) = PV_CF*couponDateYearFrac;
        couponBond_PV_CF = [couponBond_PV_CF,PV_CF];
        couponBond_ZCB_yearFrac = [couponBond_ZCB_yearFrac,couponDateYearFrac];
        
        couponDateYearFrac = couponDateYearFrac - couponBond_Portfolio.CouponBonds(i).C_frequ;
        couponBond_Price = couponBond_Price + PV_CF;
    end
    
    %work out accural interest since last coupon date
    %couponBond_Price = couponBond_Price + couponRate*FV*couponDateYearFrac/couponBond_Portfolio.CouponBonds(i).C_frequ;  
    couponBond_Portfolio.CouponBonds(i).Price = couponBond_Price;
    
    couponBond_Portfolio.CouponBonds(i).RF = couponBond_RF;
    couponBond_Portfolio.CouponBonds(i).PV_CF = couponBond_PV_CF;
    couponBond_Portfolio.CouponBonds(i).ZCB_yearFrac = couponBond_ZCB_yearFrac;
    
    couponBond_Portfolio.Price = couponBond_Portfolio.Price + couponBond_Price;
end

CI = 0.99;
alpha = norminv(CI);
couponBond_Portfolio.Price;
valDateIndex = find(returnDates('AUSTRALIA_ZERO_CURVE',workbookSheetNames,workbookDates) == valuationDate);
couponBond_PortfolioRF_last1000days = couponBond_Portfolio.RF((valDateIndex-999):valDateIndex,:);
couponBond_Portfolio_VAR = alpha*sqrt(couponBond_Portfolio.x'*cov(diff(couponBond_PortfolioRF_last1000days,1,1))*couponBond_Portfolio.x);

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
% GBP UK £ 55
% NZD New Zealand $ 30
% INR Indian Rupee -50
% JPY Yen -30

%AUD $ to US $	 AUD $ TO UK £  	 AUD $ TO EURO	AUD $ TO CHF	AUD $
%TO INR (Indian Rupee)	AUD $ TO NZD $	AUD $ TO JPY

currency1 = struct('Price',-40,'exchaRateCode','AUD $ to US $','Currency','USD');
currency2 = struct('Price',60,'exchaRateCode','AUD $ TO EURO','Currency','EUR');
currency3 = struct('Price',55,'exchaRateCode','AUD $ TO UK £','Currency','GBP');
currency4 = struct('Price',30,'exchaRateCode','AUD $ TO NZD $','Currency','NZD');
currency5 = struct('Price',-50,'exchaRateCode','AUD $ TO INR (Indian Rupee)','Currency','INR');
currency6 = struct('Price',-30,'exchaRateCode','AUD $ TO JPY','Currency','JPY');  

FX_Portfolio = struct('Currencies',[currency1 currency2 currency3 currency4 currency5 currency6],'Price',0);

sizeFxPortfolio = size(FX_Portfolio.Currencies,2);

for i =1:sizeFxPortfolio
    FX_Portfolio.Price = FX_Portfolio.Price + abs(FX_Portfolio.Currencies(i).Price);
end

FX_Portfolio.Price;

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

fxoption1 = struct('Price',0,'Exp_Date',datenum('9/10/2015',formatIn),'UnderlyingExchaRateCode','AUD $ to US $','UnderlyingYieldCode','US_ZERO_CURVE','CallOrPut',1,'OwnOrSold',1,'ForeignAmount',150.00,'DomesticAmount',205.68);
fxoption2 = struct('Price',0,'Exp_Date',datenum('11/12/2015',formatIn),'UnderlyingExchaRateCode','AUD $ to US $','UnderlyingYieldCode','US_ZERO_CURVE','CallOrPut',-1,'OwnOrSold',1,'ForeignAmount',210.00,'DomesticAmount',280.15);
fxoption3 = struct('Price',0,'Exp_Date',datenum('13/12/2015',formatIn),'UnderlyingExchaRateCode','AUD $ TO CHF','UnderlyingYieldCode','SWISS_ZERO_CURVE','CallOrPut',1,'OwnOrSold',1,'ForeignAmount',100.00,'DomesticAmount',138.12);
fxoption4 = struct('Price',0,'Exp_Date',datenum('08/02/2016',formatIn),'UnderlyingExchaRateCode',' AUD $ TO EURO','UnderlyingYieldCode','EURO_ZERO_CURVE','CallOrPut',1,'OwnOrSold',-1,'ForeignAmount',180.00,'DomesticAmount',265.53);
fxoption5 = struct('Price',0,'Exp_Date',datenum('05/04/2016',formatIn),'UnderlyingExchaRateCode',' AUD $ TO EURO','UnderlyingYieldCode','EURO_ZERO_CURVE','CallOrPut',-1,'OwnOrSold',1,'ForeignAmount',220.00,'DomesticAmount',337.99);

FXOptions_Portfolio = struct('FXOption',[fxoption1 fxoption2 fxoption3 fxoption4 fxoption5],'Price',0);
numFXOptPositions = size(FXOptions_Portfolio.FXOption,2);

[valuDateYearFracsDomestic, codesDomesticYields, valuDateDomesticYields] = returnYieldCurveData('AUSTRALIA_ZERO_CURVE',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);

for i = 1:numFXOptPositions
    [valuDateYearFracsForeign, codesForeignYields, valuDateForeignYields] = returnYieldCurveData(FXOptions_Portfolio.FXOption(i).UnderlyingYieldCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);
    [ForeignPerDomesticFX_rates,dates] = returnColData('exchange_rates',FXOptions_Portfolio.FXOption(i).UnderlyingExchaRateCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
    DomesticPerForeignFX_rates = 1./ForeignPerDomesticFX_rates;
    spotDomesticPerForeign = DomesticPerForeignFX_rates(dates == valuationDate);
    
    returns = diff(DomesticPerForeignFX_rates((valDateIndex-364):valDateIndex)) ./ DomesticPerForeignFX_rates((valDateIndex-364):(valDateIndex-1));
    stdv = std(returns);
    vol = sqrt(365)*stdv;
        
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
FXOptions_Portfolio.Price;

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

fwdfx1 = struct('Price',0,'Exp_Date',datenum('07/11/2015',formatIn),'BuyYieldCode','JAPAN_ZERO_CURVE','BuyAmount',1500,'SellYieldCode','AUSTRALIA_ZERO_CURVE','SellAmount',16.38,'SellExchaRateCode','AUD $ TO JPY');
fwdfx2 = struct('Price',0,'Exp_Date',datenum('08/12/2015',formatIn),'BuyYieldCode','US_ZERO_CURVE','BuyAmount',50,'SellYieldCode','AUSTRALIA_ZERO_CURVE','SellAmount',66.83,'SellExchaRateCode','AUD $ to US $');
fwdfx3 = struct('Price',0,'Exp_Date',datenum('15/01/2016',formatIn),'BuyYieldCode','EURO_ZERO_CURVE','BuyAmount',30,'SellYieldCode','AUSTRALIA_ZERO_CURVE','SellAmount',44.67,'SellExchaRateCode',' AUD $ TO EURO');

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

% in millions 
FWDFX_Portfolio.Price;

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

PhysicalShares_Portfolio = struct('Share',[share1 share2 share3 share4 share5 share6],'Price',0);
numSharesPositions = size(PhysicalShares_Portfolio.Share,2);
[spotArray,issuerCodes] = returnRowData('stock prices',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);

for i = 1:numSharesPositions
    spot = spotArray(strcmp(PhysicalShares_Portfolio.Share(i).IssuerCode,issuerCodes));
    OwnOrSold = PhysicalShares_Portfolio.Share(i).OwnOrSold;
    PhysicalShares_Portfolio.Share(i).Price = OwnOrSold*PhysicalShares_Portfolio.Share(i).numShares*spot/1000000; %price in millions AUD
    PhysicalShares_Portfolio.Price = PhysicalShares_Portfolio.Price + PhysicalShares_Portfolio.Share(i).Price;
end

% in millions 
PhysicalShares_Portfolio.Price;

option1 = struct('Price',0,'Maturity',datenum('9/10/2015',formatIn),'UnderlyingCode','BHP','CallOrPut',1,'OwnOrSold',1,'numShares',250000,'strike',28.00,'vol_pa',0.2953);
option2 = struct('Price',0,'Maturity',datenum('8/01/2016',formatIn),'UnderlyingCode','RIO','CallOrPut',-1,'OwnOrSold',1,'numShares',200000,'strike',54.00,'vol_pa',0.2606);
option3 = struct('Price',0,'Maturity',datenum('12/03/2016',formatIn),'UnderlyingCode','RIO','CallOrPut',1,'OwnOrSold',1,'numShares',200000,'strike',53.00,'vol_pa',0.2648);
option4 = struct('Price',0,'Maturity',datenum('04/03/2016',formatIn),'UnderlyingCode','NCM','CallOrPut',-1,'OwnOrSold',-1,'numShares',200000,'strike',12.00,'vol_pa',0.4418);
option5 = struct('Price',0,'Maturity',datenum('07/04/2016',formatIn),'UnderlyingCode','NCM','CallOrPut',1,'OwnOrSold',-1,'numShares',250000,'strike',10.00,'vol_pa',0.44);
option6 = struct('Price',0,'Maturity',datenum('09/06/2016',formatIn),'UnderlyingCode','WPL','CallOrPut',-1,'OwnOrSold',1,'numShares',200000,'strike',33.00,'vol_pa',0.2522);

ShareOptions_Portfolio = struct('ShareOption',[option1 option2 option3 option4 option5 option6],'Price',0);
numSharesOptPositions = size(ShareOptions_Portfolio.ShareOption,2);

[valuDateYearFracs, codes, valuDateYields] = returnYieldCurveData('AUSTRALIA_ZERO_CURVE',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);

for i = 1:numSharesOptPositions      
    [stockPrices,dates] = returnColData('stock prices',ShareOptions_Portfolio.ShareOption(i).UnderlyingCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
    spot = stockPrices(dates == valuationDate);
    
    %returns = diff(stockPrices((valDateIndex-364):valDateIndex)) ./ stockPrices((valDateIndex-364):(valDateIndex-1));
    %stdv = std(returns);
    %vol = sqrt(365)*stdv;
 
    OwnOrSold = ShareOptions_Portfolio.ShareOption(i).OwnOrSold;
    numShares = ShareOptions_Portfolio.ShareOption(i).numShares;
    strike = ShareOptions_Portfolio.ShareOption(i).strike;
    div = 0;
    vol = ShareOptions_Portfolio.ShareOption(i).vol_pa;
    
    expiry = yearfrac(valuationDate,ShareOptions_Portfolio.ShareOption(i).Maturity,1);
    callOrPut = ShareOptions_Portfolio.ShareOption(i).CallOrPut;
    rate = interpolYield(expiry,valuDateYearFracs,valuDateYields);
    
    ShareOptions_Portfolio.ShareOption(i).Price = OwnOrSold*numShares*bsPrice(spot, strike, rate, div, vol, expiry, callOrPut)/1000000;
    ShareOptions_Portfolio.Price = ShareOptions_Portfolio.Price + ShareOptions_Portfolio.ShareOption(i).Price;
end

% in millions 
ShareOptions_Portfolio.Price;

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
swap1 = struct('Price',0,'PayerOrRec',1,'Maturity',datenum('07/11/2015',formatIn),'Notional',20,'Sett_period',0.25,'SwapRate_pa',0.022);
swap2 = struct('Price',0,'PayerOrRec',-1,'Maturity',datenum('07/08/2016',formatIn),'Notional',80,'Sett_period',0.5,'SwapRate_pa',0.023);
swap3 = struct('Price',0,'PayerOrRec',1,'Maturity',datenum('06/11/2016',formatIn),'Notional',70,'Sett_period',0.25,'SwapRate_pa',0.0245);
        
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

end







function [dates] = returnDates(sheetName,sheetNames,workbookDates)
    sheetIndex = strcmp(sheetNames',sheetName);
    dates = workbookDates{sheetIndex};
end

function [colNumeric, varargout] = returnColData(sheetName,codeString,sheetNames,workbookDates,workbookCodes,workbookNumericData)
    sheetIndex = strcmp(sheetNames',sheetName);
    sheetNumericData = workbookNumericData{sheetIndex};
    colIndex = strcmp(workbookCodes{sheetIndex},codeString);
    colNumeric = sheetNumericData(:,colIndex);
    
    nout = max(nargout,1)-1;
    if(nout > 0)
        varargout{1} = workbookDates{sheetIndex};
    end
end

function [rowNumeric,varargout] = returnRowData(sheetName,sheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate) 
    sheetIndex = strcmp(sheetNames',sheetName);
    sheetNumericData = workbookNumericData{sheetIndex};
    rowIndex = find(workbookDates{sheetIndex}== valuationDate);
    rowNumeric = sheetNumericData(rowIndex,:);
    
    nout = max(nargout,1)-1;
    if(nout > 0)
        varargout{1} = workbookCodes{sheetIndex};
    end
end

function [varargout] = returnYieldCurveData(sheetName,sheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate)
    if(nargout > 0)
          % using 30/360 convention
          RELDATE00Y00 = valuationDate;
          RELDATE00Y01 = daysadd(valuationDate,1*30,1);
          RELDATE00Y02 = daysadd(valuationDate,2*30,1);
          RELDATE00Y03 = daysadd(valuationDate,3*30,1);
          RELDATE00Y06 = daysadd(valuationDate,6*30,1);
          RELDATE00Y09 = daysadd(valuationDate,9*30,1);
          RELDATE01Y00 = daysadd(valuationDate,1*360,1);
          RELDATE02Y00 = daysadd(valuationDate,2*360,1);
          RELDATE03Y00 = daysadd(valuationDate,3*360,1);
          RELDATE04Y00 = daysadd(valuationDate,4*360,1);
          RELDATE05Y00 = daysadd(valuationDate,5*360,1);
          RELDATE06Y00 = daysadd(valuationDate,6*360,1);
          RELDATE07Y00 = daysadd(valuationDate,7*360,1);
          RELDATE08Y00 = daysadd(valuationDate,8*360,1);
          RELDATE09Y00 = daysadd(valuationDate,9*360,1);
          
          varargout{1} = yearfrac(valuationDate,[RELDATE00Y00 RELDATE00Y01 RELDATE00Y02 RELDATE00Y03	RELDATE00Y06	RELDATE00Y09	RELDATE01Y00	...
                                                 RELDATE02Y00 RELDATE03Y00 RELDATE04Y00 RELDATE05Y00	RELDATE06Y00	RELDATE07Y00	RELDATE08Y00	RELDATE09Y00],1);
          
          sheetIndex = strcmp(sheetNames',sheetName);
          
          if(nargout > 1)
            varargout{2} = workbookCodes{sheetIndex};
          
            if(nargout > 2)
                sheetNumericData = workbookNumericData{sheetIndex};
                rowIndex = find(workbookDates{sheetIndex}== valuationDate);
                varargout{3} = sheetNumericData(rowIndex,:);
            end
          end
    
    end
end

function [varargout] = returnIRSCurveData(sheetName,sheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate)
    if(nargout > 0)
          % using 30/360 convention
          RELDATE00Y01 = daysadd(valuationDate,1*30,1);
          RELDATE00Y02 = daysadd(valuationDate,2*30,1);
          RELDATE00Y03 = daysadd(valuationDate,3*30,1);
          RELDATE00Y04 = daysadd(valuationDate,4*30,1);
          RELDATE00Y05 = daysadd(valuationDate,5*30,1);
          RELDATE00Y06 = daysadd(valuationDate,6*30,1);
          RELDATE01Y00 = daysadd(valuationDate,1*360,1);
          RELDATE02Y00 = daysadd(valuationDate,2*360,1);
          RELDATE03Y00 = daysadd(valuationDate,3*360,1);
          
          varargout{1} = yearfrac(valuationDate,[RELDATE00Y01 RELDATE00Y02 RELDATE00Y03	RELDATE00Y04    RELDATE00Y05    RELDATE00Y06...
                                                RELDATE01Y00	RELDATE02Y00 RELDATE03Y00],1);
          
          sheetIndex = strcmp(sheetNames',sheetName);
          
          if(nargout > 1)
            varargout{2} = workbookCodes{sheetIndex};
          
            if(nargout > 2)
                sheetNumericData = workbookNumericData{sheetIndex};
                rowIndex = find(workbookDates{sheetIndex}== valuationDate);
                varargout{3} = sheetNumericData(rowIndex,:);
            end
          end
    
    end
end

function price = ZCB_price_contComp(maturityYears,yield)
%using cont compounding..what about simple? 
price = exp(-maturityYears*yield);
end

function forwardRateT1_T2 = ForwardRate_contComp(T1,yieldT1,T2,yieldT2)
%using cont compounding..what about simple? 
forwardRateT1_T2 = -(log(ZCB_price_contComp(T2,yieldT2))-log(ZCB_price_contComp(T1,yieldT1)))/(T2-T1);
end

function intepYield = interpolYield(yearFrac,setYearFracs,setYields)
minDateLoc = min(find(yearFrac < setYearFracs))-1; %#ok<MXFND>
intepYield = setYields(minDateLoc) + (yearFrac - setYearFracs(minDateLoc)).*(setYields(minDateLoc + 1) - setYields(minDateLoc))./(setYearFracs(minDateLoc + 1) - setYearFracs(minDateLoc));
end

function RF_yield = ZCB_yieldCurveRiskFactor(yearFrac,setYearFracs,codes,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData)
minDateLoc = min(find(yearFrac < setYearFracs))-1;
minYield = returnColData('AUSTRALIA_ZERO_CURVE',codes{minDateLoc},workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
maxYield = returnColData('AUSTRALIA_ZERO_CURVE',codes{minDateLoc + 1},workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
RF_yield = minYield + (yearFrac - setYearFracs(minDateLoc)).*(maxYield - minYield)./(setYearFracs(minDateLoc + 1) - setYearFracs(minDateLoc));
end
