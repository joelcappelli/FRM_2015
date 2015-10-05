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
