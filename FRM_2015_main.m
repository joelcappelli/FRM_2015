
%% Financial Risk Management Ass Spring 2015
% Joel Cappelli
% 12137384

% questions to ask;
% MTM valuation

%% bond portfolio
% do we have to worry about accrued interest of each bond?
% vale working back from maturity to each coupon date by frequency, do we
% have to match to mentioned next coupon payment?
% cont compounding ok?
% assume linear interpolation between yield rates
% do we take all the yields in the data set for the diff and build covar
% matrix (if not, how many years back from valuation date?)

%%
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
                          'Interest Rate Swap Data';...
                          'Sheet7';...
                          };       
    firstRowOfCodesPerSheet = [2;...
                               3;...
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
    while(couponDateYearFrac > 0)        
        ZCB = ZCB_price_One(couponDateYearFrac,interpolYield(couponDateYearFrac,valuDateYearFracs,valuDateYields));
        if(maturityPayment)
            PV_CF = (1+couponRate)*FV*ZCB;
            maturityPayment = 0;
        else
            PV_CF = couponRate*FV*ZCB;
        end

        numRF = numRF + 1;
        couponBond_Portfolio.RF(:,numRF) = ZCB_riskFactor(couponDateYearFrac,valuDateYearFracs,codes,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
        couponBond_RF = [couponBond_RF, couponBond_Portfolio.RF(:,numRF)];
        couponBond_Portfolio.x(numRF,:) = PV_CF*couponDateYearFrac;
        couponBond_PV_CF = [couponBond_PV_CF,PV_CF];
        couponBond_ZCB_yearFrac = [couponBond_ZCB_yearFrac,couponDateYearFrac];
        
        couponDateYearFrac = couponDateYearFrac - couponBond_Portfolio.CouponBonds(i).C_frequ;
        couponBond_Price = couponBond_Price + PV_CF;
    end
    
    %work out accural interest since last coupon date
    couponDateYearFrac = couponDateYearFrac + couponBond_Portfolio.CouponBonds(i).C_frequ;
    couponBond_Price = couponBond_Price + couponRate*FV*couponDateYearFrac/couponBond_Portfolio.CouponBonds(i).C_frequ;  
    couponBond_Portfolio.CouponBonds(i).Price = couponBond_Price;
    
    couponBond_Portfolio.CouponBonds(i).RF = couponBond_RF;
    couponBond_Portfolio.CouponBonds(i).PV_CF = couponBond_PV_CF;
    couponBond_Portfolio.CouponBonds(i).ZCB_yearFrac = couponBond_ZCB_yearFrac;
    
    couponBond_Portfolio.Price = couponBond_Portfolio.Price + couponBond_Price;
end

CI = 0.99;
alpha = norminv(CI)
couponBond_Portfolio.Price
couponBond_Portfolio_VAR = alpha*sqrt(couponBond_Portfolio.x'*cov(diff(couponBond_Portfolio.RF,1,1))*couponBond_Portfolio.x)

%%
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

currency1 = struct('Price',-40,'exchaRateCode','AUD $ to US $','Currency','USD');
currency2 = struct('Price',60,'exchaRateCode','AUD $ TO EURO','Currency','EUR');
currency3 = struct('Price',55,'exchaRateCode','AUD $ TO UK �','Currency','GBP');
currency4 = struct('Price',30,'exchaRateCode','AUD $ TO NZD $','Currency','NZD');
currency5 = struct('Price',-50,'exchaRateCode','AUD $ TO INR (Indian Rupee)','Currency','INR');
currency6 = struct('Price',-30,'exchaRateCode','AUD $ TO JPY','Currency','JPY');  

FX_Portfolio = struct('Currencies',[currency1 currency2 currency3 currency4 currency5 currency6],'Price',0);

sizeFxPortfolio = size(FX_Portfolio.Currencies,2);

for i =1:sizeFxPortfolio
    FX_Portfolio.Price = FX_Portfolio.Price + abs(FX_Portfolio.Currencies(i).Price);
end

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
    spot = spotArray(find(strcmp(PhysicalShares_Portfolio.Share(i).IssuerCode,issuerCodes)));
    boughtOrSold = PhysicalShares_Portfolio.Share(i).OwnOrSold;
    PhysicalShares_Portfolio.Share(i).Price = boughtOrSold*PhysicalShares_Portfolio.Share(i).numShares*spot/1000000;
    PhysicalShares_Portfolio.Price = PhysicalShares_Portfolio.Price + PhysicalShares_Portfolio.Share(i).Price;
end

option1 = struct('Price',0,'Maturity',datenum('9/10/2015',formatIn),'UnderlyingCode','BHP','CallOrPut',1,'OwnOrSold',1,'numShares',250000,'strike',28.00,'vol_pa',0.2953);
option2 = struct('Price',0,'Maturity',datenum('8/01/2016',formatIn),'UnderlyingCode','RIO','CallOrPut',-1,'OwnOrSold',1,'numShares',200000,'strike',54.00,'vol_pa',0.2606);
option3 = struct('Price',0,'Maturity',datenum('12/03/2016',formatIn),'UnderlyingCode','RIO','CallOrPut',1,'OwnOrSold',1,'numShares',200000,'strike',53.00,'vol_pa',0.2648);
option4 = struct('Price',0,'Maturity',datenum('04/03/2016',formatIn),'UnderlyingCode','NCM','CallOrPut',-1,'OwnOrSold',-1,'numShares',200000,'strike',12.00,'vol_pa',0.4418);
option5 = struct('Price',0,'Maturity',datenum('07/04/2016',formatIn),'UnderlyingCode','NCM','CallOrPut',1,'OwnOrSold',-1,'numShares',250000,'strike',10.00,'vol_pa',0.44);
option6 = struct('Price',0,'Maturity',datenum('09/06/2016',formatIn),'UnderlyingCode','WPL','CallOrPut',-1,'OwnOrSold',1,'numShares',200000,'strike',33.00,'vol_pa',0.2522);

ShareOptions_Portfolio = struct('ShareOption',[option1 option2 option3 option4 option5 option6],'Price',0);
numSharesOptPositions = size(ShareOptions_Portfolio.ShareOption,2);
for i = 1:numSharesOptPositions
    
end


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
          RELDATE00Y01 = daysadd(valuationDate,30,1);
          RELDATE00Y02 = daysadd(valuationDate,2*30,1);
          RELDATE00Y03 = daysadd(valuationDate,3*30,1);
          RELDATE00Y06 = daysadd(valuationDate,6*30,1);
          RELDATE00Y09 = daysadd(valuationDate,9*30,1);
          RELDATE01Y00 = daysadd(valuationDate,12*30,1);
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

function price = ZCB_price_One(maturityYears,yield)
price = exp(-maturityYears*yield);
end

function intepYield = interpolYield(yearFrac,setYearFracs,setYields)
minDateLoc = min(find(yearFrac < setYearFracs))-1; %#ok<MXFND>
intepYield = setYields(minDateLoc) + (yearFrac - setYearFracs(minDateLoc)).*(setYields(minDateLoc + 1) - setYields(minDateLoc))./(setYearFracs(minDateLoc + 1) - setYearFracs(minDateLoc));
end

function RF_yield = ZCB_riskFactor(yearFrac,setYearFracs,codes,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData)
minDateLoc = min(find(yearFrac < setYearFracs))-1;
minYield = returnColData('AUSTRALIA_ZERO_CURVE',codes{minDateLoc},workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
maxYield = returnColData('AUSTRALIA_ZERO_CURVE',codes{minDateLoc + 1},workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
RF_yield = minYield + (yearFrac - setYearFracs(minDateLoc)).*(maxYield - minYield)./(setYearFracs(minDateLoc + 1) - setYearFracs(minDateLoc));
end
