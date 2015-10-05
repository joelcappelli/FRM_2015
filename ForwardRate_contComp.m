function forwardRateT1_T2 = ForwardRate_contComp(T1,yieldT1,T2,yieldT2)
%using cont compounding..what about simple? 
forwardRateT1_T2 = -(log(ZCB_price_contComp(T2,yieldT2))-log(ZCB_price_contComp(T1,yieldT1)))/(T2-T1);
end