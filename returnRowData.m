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