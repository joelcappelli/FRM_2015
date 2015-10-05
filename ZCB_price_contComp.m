function price = ZCB_price_contComp(maturityYears,yield)
%using cont compounding..what about simple? 
price = exp(-maturityYears*yield);
end