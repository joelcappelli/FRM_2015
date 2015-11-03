function swap_Portfolio = SwapPortfolio_Price_GetRF(swap_Portfolio,valuationDate,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData)

numSwaps = size(swap_Portfolio.Swap,2);
numRF = 0;

RECEIVER = 1;

[~, Yieldcodes, valuDateYields] = returnYieldCurveData(swap_Portfolio.YieldCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);
[valuDateIRSYearFracsminusSpot, ~, valuDateIRSRminusSpot] = returnIRSCurveData(swap_Portfolio.IRSCode,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData,valuationDate);
%add spot interest rate - IRS data doesnt have it
valuDateIRSYearFracs = [0 valuDateIRSYearFracsminusSpot];
valuDateIRSR = [valuDateYields(1) valuDateIRSRminusSpot];
    
for i = 1:numSwaps
    swap_Price = 0;
    Notional = swap_Portfolio.Swap(i).Notional;

    swapYearFrac = yearfrac(valuationDate,swap_Portfolio.Swap(i).Maturity,1);
    %work backwards from final payment and principal exchange
    principalFixedPayment = 1;
    while(swapYearFrac > 0)        
        ZCB = ZCB_price_contComp(swapYearFrac,interpolYield(swapYearFrac,valuDateIRSYearFracs,valuDateIRSR));
        PV_fixedLeg = Notional*swap_Portfolio.Swap(i).Sett_period*swap_Portfolio.Swap(i).SwapRate_pa*ZCB;
        
        T2 = swapYearFrac;
        T1 = T2 - swap_Portfolio.Swap(i).Sett_period;
        if(T1 < 0 )
            T1 = 0;
        end
        yieldT2 = interpolYield(T2,valuDateIRSYearFracs,valuDateIRSR);
        yieldT1 = interpolYield(T1,valuDateIRSYearFracs,valuDateIRSR);
        PV_floatingLeg = Notional*swap_Portfolio.Swap(i).Sett_period*ForwardRate_contComp(T1,yieldT1,T2,yieldT2)*ZCB;
        
        swap_Price = swap_Price + swap_Portfolio.Swap(i).PayerOrRec*(PV_fixedLeg - PV_floatingLeg);

        %there is no market risk with a payer swap i.e. receiving floating
        %payments therefore the value can be mapped as cash 
        if(swap_Portfolio.Swap(i).PayerOrRec == RECEIVER)            
            numRF = numRF + 1;
            %grab the zero rates because the fixed rate coupon on the swap
            %is the same as a coupon paying bond 
            swap_Portfolio.RF(:,numRF) = yieldCurveRiskFactor(swap_Portfolio.YieldCode,swapYearFrac,valuDateIRSYearFracs,Yieldcodes,workbookSheetNames,workbookDates,workbookCodes,workbookNumericData);
            
            if(principalFixedPayment == 1)
                swap_Portfolio.PV_CF(numRF) = PV_fixedLeg + Notional*ZCB;
                principalFixedPayment = 0;
            else
                swap_Portfolio.PV_CF(numRF) = PV_fixedLeg;
            end
            
            swap_Portfolio.ZCB_yearFrac(numRF) = swapYearFrac;
        end
        
        swapYearFrac = swapYearFrac - swap_Portfolio.Swap(i).Sett_period;
    end
    
    %work out accural interest since last coupon date
    %swap_Price = swap_Price + swapYearFrac*swap_Portfolio.Swap(i).PayerOrRec*(PV_fixedLeg - PV_floatingLeg)/swap_Portfolio.Swap(i).Sett_period;    
    swap_Portfolio.Swap(i).Price = swap_Price;

    swap_Portfolio.Price = swap_Portfolio.Price + swap_Portfolio.Swap(i).Price;
end

end