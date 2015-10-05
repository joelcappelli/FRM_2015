function [dates] = returnDates(sheetName,sheetNames,workbookDates)
    sheetIndex = strcmp(sheetNames',sheetName);
    dates = workbookDates{sheetIndex};
end