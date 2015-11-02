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

for j = 1:size(holdingTdays,2)
    for i = 1:size(CI,2)
        couponBond_Portfolio_deltaAnalyVAR = BondPortfolio_deltaAnalyVAR(CI(i),holdingTdays(j),couponBond_Portfolio,valuationDate,workbookSheetNames,workbookDates);
        couponBond_Portfolio_deltaGammaHistSimVaR = BondPortfolio_deltaGammaHistSimVaR(CI(i),holdingTdays(j),couponBond_Portfolio,valuationDate,workbookSheetNames,workbookDates);
        
        fprintf('VAR with CI: %.2f%% and holding period of %d days\n', 100*CI(i),holdingTdays(j));
        fprintf('deltaAnalyVAR of bond portfolio $%f  million AUD\n', couponBond_Portfolio_deltaAnalyVAR);
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
% GBP UK £ 55
% NZD New Zealand $ 30
% INR Indian Rupee -50
% JPY Yen -30

%AUD $ to US $	 AUD $ TO UK £  	 AUD $ TO EURO	AUD $ TO CHF	AUD $
%TO INR (Indian Rupee)	AUD $ TO NZD $	AUD $ TO JPY

currency1 = struct('DomesticEquivAmount',-40,'exchaRateCode','AUD $ to US $','Currency','USD');
currency2 = struct('DomesticEquivAmount',60,'exchaRateCode',' AUD $ TO EURO','Currency','EUR');
currency3 = struct('DomesticEquivAmount',55,'exchaRateCode',' AUD $ TO UK £  ','Currency','GBP');
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
fprintf('Total value of Spot FX portfolio: $%f  million AUD\n\n', FX_Portfolio.Price);
    
CI = [0.95,0.99];
holdingTdays = [1,10];

for j = 1:size(holdingTdays,2)
    for i = 1:size(CI,2)
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

FXOptions_Portfolio = struct('FXOption',[fxoption1 fxoption2 fxoption3 fxoption4 fxoption5],'Price',0,'DomesticYieldCurveSheet','AUSTRALIA_ZERO_CURVE','FXSheet','exchange_rates');
FXOptions_Portfolio = FXOptionsPortfolio_Price_GetRF(FXOptions_Portfolio,valuationDate,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);

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

FWDFX_Portfolio = struct('FWDFX',[fwdfx1 fwdfx2 fwdfx3],'Price',0,'FXSheet','exchange_rates');
FWDFX_Portfolio = FWDFXPortfolio_Price_GetRF(FWDFX_Portfolio,valuationDate,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);

for i = 1:size(FWDFX_Portfolio.FWDFX,2)
    fprintf('Value of FWDFX position %d: $%f  million AUD\n', i,FWDFX_Portfolio.FWDFX(i).Price);
end
fprintf('Total value of FWDFX portfolio: $%f  million AUD\n\n', FWDFX_Portfolio.Price);


fprintf('#################################################################################################\n\n');

% %go through each portfolio, look for the same underlying create array of independent riskfactors 
% combinedFXderivPortfolio = struct('FXOptions_Portfolio',FXOptions_Portfolio,'FWDFX_Portfolio',FWDFX_Portfolio,'Price',0,'RF',[],'FWDPositions',[],'FXoptionPositions',[],'Deltas',[],'Gammas',[],'UnderlyingCode',{{}},'pricesSheet','stock prices');
% combinedFXderivPortfolio = equityPortfolio_Price_GetRF(combinedFXderivPortfolio);
% fprintf('Total value of FXderiv portfolio: $%f  million AUD\n\n', FWDFX_Portfolio.Price + FXOptions_Portfolio.Price);
% 
% CI = [0.95,0.99];
% holdingTdays = [1,10];
% 
% for j = 1:size(holdingTdays,2)
%     for i = 1:size(CI,2)
%         combinedEquityPortfolio_analyDeltaNormVAR = equityPortfolio_analyDeltaNormVAR(CI(i),holdingTdays(j),combinedFXderivPortfolio,valuationDate,workbookSheetNames,workbookDates);
%         combinedEquityPortfolio_analyDeltaGammaVAR = equityPortfolio_analyDeltaGammaVAR(CI(i),holdingTdays(j),combinedFXderivPortfolio,valuationDate,workbookSheetNames,workbookDates);        
% 
%         combinedEquityPortfolio_histSimDeltaNormVAR = equityPortfolio_histSimDeltaNormVAR(CI(i),holdingTdays(j),combinedFXderivPortfolio,valuationDate,workbookSheetNames,workbookDates);
%         combinedEquityPortfolio_histSimDeltaGammaVAR = equityPortfolio_histSimDeltaGammaVAR(CI(i),holdingTdays(j),combinedFXderivPortfolio,valuationDate,workbookSheetNames,workbookDates);
%         
%         fprintf('VAR with CI: %.2f%% and holding period of %d days\n', 100*CI(i),holdingTdays(j));
%         fprintf('analyDeltaNormVAR of Equity portfolio $%f  million AUD\n', combinedEquityPortfolio_analyDeltaNormVAR/1000000);
%         fprintf('analyDeltaGammaVAR of Equity portfolio $%f  million AUD\n', combinedEquityPortfolio_analyDeltaGammaVAR/1000000);
%         fprintf('histSimDeltaNormVAR of Equity portfolio $%f  million AUD\n', combinedEquityPortfolio_histSimDeltaNormVAR/1000000);
%         fprintf('histSimDeltaGammaVAR of Equity portfolio $%f  million AUD\n\n', combinedEquityPortfolio_histSimDeltaGammaVAR/1000000);
%     end
% end
%   
% fprintf('#################################################################################################\n\n');

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
PhysicalShares_Portfolio = PhysicalSharesPortfolio_Price_GetRF(PhysicalShares_Portfolio,valuationDate,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);

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

ShareOptions_Portfolio = struct('ShareOption',[option1 option2 option3 option4 option5 option6],'Price',0,'RF',[],'pricesSheet','stock prices','DomesticYieldCurveSheet','AUSTRALIA_ZERO_CURVE');
ShareOptions_Portfolio = ShareOptionsPortfolio_Price_GetRF(ShareOptions_Portfolio,valuationDate,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);

% in $  
for i = 1:size(ShareOptions_Portfolio.ShareOption,2)
    fprintf('Value of ShareOptions position %d: $%f  million AUD\n', i,ShareOptions_Portfolio.ShareOption(i).Price/1000000);
end
fprintf('Total value of ShareOptions portfolio: $%f  million AUD\n\n', ShareOptions_Portfolio.Price/1000000);

%go through each portfolio, look for the same underlying create array of independent riskfactors 
combinedEquityPortfolio = struct('ShareOptions_Portfolio',ShareOptions_Portfolio,'PhysicalShares_Portfolio',PhysicalShares_Portfolio,'Price',0,'RF',[],'sharePositions',[],'optionPositions',[],'Deltas',[],'Gammas',[],'UnderlyingCode',{{}},'pricesSheet','stock prices');
combinedEquityPortfolio = equityPortfolio_Price_GetRF(combinedEquityPortfolio);
fprintf('Total value of Equity Portfolio: $%f  million AUD\n\n', combinedEquityPortfolio.Price/1000000);

CI = [0.95,0.99];
holdingTdays = [1,10];

for j = 1:size(holdingTdays,2)
    for i = 1:size(CI,2)
        combinedEquityPortfolio_analyDeltaNormVAR = equityPortfolio_analyDeltaNormVAR(CI(i),holdingTdays(j),combinedEquityPortfolio,valuationDate,workbookSheetNames,workbookDates);
        combinedEquityPortfolio_analyDeltaGammaVAR = equityPortfolio_analyDeltaGammaVAR(CI(i),holdingTdays(j),combinedEquityPortfolio,valuationDate,workbookSheetNames,workbookDates);        

        combinedEquityPortfolio_histSimDeltaNormVAR = equityPortfolio_histSimDeltaNormVAR(CI(i),holdingTdays(j),combinedEquityPortfolio,valuationDate,workbookSheetNames,workbookDates);
        combinedEquityPortfolio_histSimDeltaGammaVAR = equityPortfolio_histSimDeltaGammaVAR(CI(i),holdingTdays(j),combinedEquityPortfolio,valuationDate,workbookSheetNames,workbookDates);
        
        fprintf('VAR with CI: %.2f%% and holding period of %d days\n', 100*CI(i),holdingTdays(j));
        fprintf('analyDeltaNormVAR of Equity portfolio $%f  million AUD\n', combinedEquityPortfolio_analyDeltaNormVAR/1000000);
        fprintf('analyDeltaGammaVAR of Equity portfolio $%f  million AUD\n', combinedEquityPortfolio_analyDeltaGammaVAR/1000000);
        fprintf('histSimDeltaNormVAR of Equity portfolio $%f  million AUD\n', combinedEquityPortfolio_histSimDeltaNormVAR/1000000);
        fprintf('histSimDeltaGammaVAR of Equity portfolio $%f  million AUD\n\n', combinedEquityPortfolio_histSimDeltaGammaVAR/1000000);
    end
end
  
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
[valuDateYieldYearFracs, Yieldcodes, valuDateYields] = returnYieldCurveData('AUSTRALIA_ZERO_CURVE',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,datenum('06/08/2015',dateFormatIn));
[valuDateIRSYearFracs, IRScodes, valuDateIRSR] = returnIRSCurveData('Interest Rate Swap Data',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,datenum('06/08/2015',dateFormatIn));
%add spot interest rate - IRS data doesnt have it
valuDateIRSYearFracs = [0 valuDateIRSYearFracs];
valuDateIRSR = [valuDateYields(1) valuDateIRSR];

for i = 1:numSwaps

    swap_Price = 0;
    Notional = swap_Portfolio.Swap(i).Notional;
    
    swapYearFrac = yearfrac(valuationDate,swap_Portfolio.Swap(i).Maturity,1);
    while(swapYearFrac > 0)        
        ZCB = ZCB_price_contComp(swapYearFrac,interpolYield(swapYearFrac,valuDateIRSYearFracs,valuDateIRSR));
        PV_fixedLeg = Notional*swap_Portfolio.Swap(i).Sett_period*swap_Portfolio.Swap(i).SwapRate_pa*ZCB;
        
        T2 = swapYearFrac;
        T1 = T2 - swap_Portfolio.Swap(i).Sett_period;
        if(T1 < 0 )
            T1 = 0;
        end
        yieldT2 = interpolYield(T2,valuDateIRSYearFracs,valuDateIRSR);
        yieldT1 = interpolYield(T1,valuDateIRSYearFracs,valuDateIRSR);
        PV_floatingLeg = Notional*swap_Portfolio.Swap(i).Sett_period*ForwardRate_contComp(T1,yieldT1,T2,yieldT2)*ZCB;
        
        swapYearFrac = swapYearFrac - swap_Portfolio.Swap(i).Sett_period;
        swap_Price = swap_Price + swap_Portfolio.Swap(i).PayerOrRec*(PV_fixedLeg - PV_floatingLeg);
    end
    
    %work out accural interest since last coupon date
    %swap_Price = swap_Price + swapYearFrac*swap_Portfolio.Swap(i).PayerOrRec*(PV_fixedLeg - PV_floatingLeg)/swap_Portfolio.Swap(i).Sett_period;    
    swap_Portfolio.Swap(i).Price = swap_Price;

    swap_Portfolio.Price = swap_Portfolio.Price + swap_Portfolio.Swap(i).Price;
end

% in millions 
fprintf('Portfolio 5: Interest rate swaps \n\n');
fprintf('Valuation date: %s\n',datestr(datenum('06/08/2015',dateFormatIn),dateFormatIn));
for i = 1:size(swap_Portfolio.Swap,2)
    fprintf('Value of IRS position %d: $%f  million AUD\n', i,swap_Portfolio.Swap(i).Price);
end
fprintf('Total value of IRS portfolio: $%f  million AUD\n\n', swap_Portfolio.Price);

fprintf('#################################################################################################\n\n');


end
