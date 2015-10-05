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