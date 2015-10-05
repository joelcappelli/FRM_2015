function  readExcelSpreadsheet_SaveInputs(fileName,workbookSheetNames,firstRowOfCodesPerSheet,dateFormatIn)
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

        temp_sheetDates = datenum(TXT((firstRowOfCodesPerSheet(i)+1):end,1),dateFormatIn);
        temp_sheetCodes = TXT(firstRowOfCodesPerSheet(i),2:end);

        workbookDates{i} = temp_sheetDates;
        workbookCodes{i} = temp_sheetCodes;
        workbookNumericData{i} = NUMERIC;
    end
    disp('Finished importing excel data...');
    disp('Saving data...');
    
    save('dateFormatIn.mat','dateFormatIn');
    save('workbookSheetNames.mat','workbookSheetNames');
    save('workbookDates.mat','workbookDates');
    save('workbookCodes.mat','workbookCodes');
    save('workbookNumericData.mat','workbookNumericData');    
end