function RF_yield = yieldCurveRiskFactor(yieldCurveCode,yearFrac,setYearFracs,codes,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData)
minDateLoc = min(find(yearFrac < setYearFracs))-1;
minYield = returnColData(yieldCurveCode,codes{minDateLoc},workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
maxYield = returnColData(yieldCurveCode,codes{minDateLoc + 1},workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
RF_yield = minYield + (yearFrac - setYearFracs(minDateLoc)).*(maxYield - minYield)./(setYearFracs(minDateLoc + 1) - setYearFracs(minDateLoc));
end