
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

[BBSR5M,dates] = returnColData('Interest Rate Swap Data','BBSR5M',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
[BBSR5M_check] = returnColData('Interest Rate Swap Data','BBSR5M',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);

[AUD_INR,dates] = returnColData('exchange_rates','AUD $ TO INR (Indian Rupee)',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
[AUD_INR_check] = returnColData('exchange_rates','AUD $ TO INR (Indian Rupee)',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);

%%add next coupon date to struct and also coupon rate timing i.e.
%%semi-annual
couponBond1 = struct('Price',0,'C_rate_pa',0.0475,'Maturity',datenum('15/06/2016',formatIn),'FV_millions',10,'C_frequ',0.5,'RF',[],'PV_CF',[],'ZCB_yearFrac',[]);
couponBond2 = struct('Price',0,'C_rate_pa',0.0425,'Maturity',datenum('21/07/2017 ',formatIn),'FV_millions',5,'C_frequ',0.5,'RF',[],'PV_CF',[],'ZCB_yearFrac',[]);
couponBond3 = struct('Price',0,'C_rate_pa',0.055,'Maturity',datenum('21/01/2018',formatIn),'FV_millions',8,'C_frequ',0.5,'RF',[],'PV_CF',[],'ZCB_yearFrac',[]);
couponBond4 = struct('Price',0,'C_rate_pa',0.0525,'Maturity',datenum('15/03/2019 ',formatIn),'FV_millions',10,'C_frequ',0.5,'RF',[],'PV_CF',[],'ZCB_yearFrac',[]);
couponBond5 = struct('Price',0,'C_rate_pa',0.045,'Maturity',datenum('15/04/2019 ',formatIn),'FV_millions',5,'C_frequ',0.5,'RF',[],'PV_CF',[],'ZCB_yearFrac',[]);   
                 
couponBond_Portfolio = [couponBond1 couponBond2 couponBond3 couponBond4 couponBond5];
numBonds = size(couponBond_Portfolio,2);

[valuDateYearFracs, codes, valuDateYields] = returnYieldCurveData('AUSTRALIA_ZERO_CURVE',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);

%growing column vectors of risk factors which are the coupon bonds
%decomposed into ZCB with assoicated linearly interpolated yield data for
%each cash flow 
numRF = 0;
for i = 1:numBonds

    couponBond_RF = [];
    couponBond_PV_CF = [];
    couponBond_ZCB_yearFrac = [];
    
    couponBond_Price = 0;
    FV = couponBond_Portfolio(i).FV_millions;
    couponRate = couponBond_Portfolio(i).C_rate_pa*couponBond_Portfolio(i).C_frequ;
    maturityPayment = 1;
    
    couponDateYearFrac = yearfrac(valuationDate,couponBond_Portfolio(i).Maturity,1);
    while(couponDateYearFrac > 0)        
        ZCB = ZCB_price_One(couponDateYearFrac,interpolYield(couponDateYearFrac,valuDateYearFracs,valuDateYields));
        if(maturityPayment)
            PV_CF = (1+couponRate)*FV*ZCB;
            maturityPayment = 0;
        else
            PV_CF = couponRate*FV*ZCB;
        end

        numRF = numRF + 1;
        couponBond_RF = [couponBond_RF, ZCB_riskFactor(couponDateYearFrac,valuDateYearFracs,codes,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData)];
        couponBond_PV_CF = [couponBond_PV_CF,PV_CF];
        couponBond_ZCB_yearFrac = [couponBond_ZCB_yearFrac,couponDateYearFrac];
        
        couponDateYearFrac = couponDateYearFrac - couponBond_Portfolio(i).C_frequ;
    end
    
    %work out accural interest since last coupon date
    couponDateYearFrac = couponDateYearFrac + couponBond_Portfolio(i).C_frequ;
    couponBond_Price = couponBond_Price + couponRate*FV*couponDateYearFrac/couponBond_Portfolio(i).C_frequ;  
    couponBond_Portfolio(i).Price = couponBond_Price;
    
    couponBond_Portfolio(i).RF = couponBond_RF;
    couponBond_Portfolio(i).PV_CF = couponBond_PV_CF;
    couponBond_Portfolio(i).ZCB_yearFrac = couponBond_ZCB_yearFrac;
end

covar_couponBond_Portfolio = zeros(numRF,numRF);
x_couponBond_Portfolio = zeros(numRF,1);


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
minDateLoc = min(find(yearFrac < setYearFracs))-1;
intepYield = setYields(minDateLoc) + (yearFrac - setYearFracs(minDateLoc)).*(setYields(minDateLoc + 1) - setYields(minDateLoc))./(setYearFracs(minDateLoc + 1) - setYearFracs(minDateLoc));
end

function RF_yield = ZCB_riskFactor(yearFrac,setYearFracs,codes,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData)
minDateLoc = min(find(yearFrac < setYearFracs))-1;
minYield = returnColData('AUSTRALIA_ZERO_CURVE',codes{minDateLoc},workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
maxYield = returnColData('AUSTRALIA_ZERO_CURVE',codes{minDateLoc + 1},workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
RF_yield = minYield + (yearFrac - setYearFracs(minDateLoc)).*(maxYield - minYield)./(setYearFracs(minDateLoc + 1) - setYearFracs(minDateLoc));
end
