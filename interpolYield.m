function intepYield = interpolYield(yearFrac,setYearFracs,setYields)
minDateLoc = min(find(yearFrac < setYearFracs))-1; %#ok<MXFND>
intepYield = setYields(minDateLoc) + (yearFrac - setYearFracs(minDateLoc)).*(setYields(minDateLoc + 1) - setYields(minDateLoc))./(setYearFracs(minDateLoc + 1) - setYearFracs(minDateLoc));
end