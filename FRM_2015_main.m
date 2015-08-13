
%% Financial Risk Management Ass Spring 2015
% Joel Cappelli
% 12137384

function [] = FRM_2015_main()
                           
%date to time format
formatIn = 'dd/mm/yyyy';
valuationDate_dateFormat = '7/8/2015';
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
    fileName = '2015_FRM_ASSIGNMENT_DATA.xlsx';     
    workbookSheetNames = {'stock prices';...
                          'exchange rates';...
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

[AU_yieldData_2M,dates] = returnData('AUSTRALIA_ZERO_CURVE','AU00Y02',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
[AU_yieldData_2M_check] = returnData('AUSTRALIA_ZERO_CURVE','AU00Y02',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);

[BBSR5M,dates] = returnData('Interest Rate Swap Data','BBSR5M',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
[BBSR5M_check] = returnData('Interest Rate Swap Data','BBSR5M',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);

[AUD_INR,dates] = returnData('exchange rates','AUD $ TO INR (Indian Rupee)',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
[AUD_INR_check] = returnData('exchange rates','AUD $ TO INR (Indian Rupee)',workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);

end

function [colNumeric, varargout] = returnData(sheetName,codeString,sheetNames,workbookDates,workbookCodes,workbookNumericData)
    sheetIndex = strcmp(sheetNames',sheetName);
    sheetNumericData = workbookNumericData{sheetIndex};
    colIndex = strcmp(workbookCodes{sheetIndex},codeString);
    colNumeric = sheetNumericData(:,colIndex);
    
    nout = max(nargout,1)-1;
    if(nout > 0)
        varargout{1} = workbookDates{sheetIndex};
    end
end
