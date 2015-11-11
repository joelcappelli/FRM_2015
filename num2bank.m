function [str]=num2bank(num)
     str = arrayfun(@(x) num2bankScalar(x) , num, 'UniformOutput', false) ;
end

function [str]=num2bankScalar(num)
     num=floor(num*100)/100;
     str = num2str(num);
     k=find(str == '.', 1);
     if(isempty(k))
         str=[str,'.00'];
     end
     FIN = min(length(str),find(str == '.')-1);
     for i = FIN-2:-3:2
     str(i+1:end+1) = str(i:end);
     str(i) = ',';
     end
end