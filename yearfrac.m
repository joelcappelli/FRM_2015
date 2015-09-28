function [YearFraction] = yearfrac(Date1, Date2, Basis) 
%YEARFRAC Fraction of Year Between Dates.
%
%   [YearFraction] = yearfrac(Date1, Date2, Basis)
%
%   Summary: This function determines the fraction of a year occurring between
%            two dates based on the number days between those dates using a
%            specified day count Basis.  
%
%   Inputs: Date1 - Nx1 or 1xN vector containing values for Date 1 in either
%                   date string or serial date form
%           Date2 - Nx1 or 1xN vector containing values for Date 2 in either
%                   date string or serial date form
%           Basis - Nx1 or 1xN vector containing value specifying the Basis for
%                   each set of dates; possible values include:
%                   a) Basis 0 - actual/actual(default)
%                   b) Basis 1 - 30/360
%                   c) Basis 2 - actual/360
%                   d) Basis 3 - actual/365
%
%   Outputs: YearFraction - Nx1 or 1xN vector of real numbers identifying the
%            interval, in years, between Date 1 and Date 2
%
%   See also YEAR. 
 
%Author(s): C.F. Garvin, 2-23-95; C. Bassignani, 11-12-97 
%   Copyright 1995-2002 The MathWorks, Inc. 
%$Revision: 1.15 $   $Date: 2002/03/11 19:19:12 $ 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                   ************* GET/PARSE INPUT(S) **************
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Check the number of arguments being passed in and set defaults
if (nargin < 3)
     Basis = 0;
end


if (nargin < 2) 
     error('Please enter values for Date1 and Date2!') 
end 


%Parse inputs as necessary
if isstr(Date1)
     Date1 = datenum(Date1); 
end


if isstr(Date2)
     Date2 = datenum(Date2); 
end


%Parse Basis argument
if (isstr(Basis))
     Basis = str2double(Basis);
end


if (any(Basis ~= 0 & Basis ~= 1 & Basis ~= 2 & Basis ~= 3))
   error('Invalid bond Basis specified!')
end


%Scale up input arguments as required
InputsSize = [size(Date1); size(Date2); size(Basis)]; 

if length(Date1) == 1 
     Date1 = Date1*ones(max(InputsSize(:,1)), max(InputsSize(:,2))); 
end

if length(Date2) == 1 
     Date2 = Date2*ones(max(InputsSize(:,1)), max(InputsSize(:,2))); 
end

if length(Basis) == 1 
     Basis = Basis*ones(max(InputsSize(:,1)), max(InputsSize(:,2))); 
end 


%Make sure all input arguments are of the same size and shape
if (checksiz([size(Date1); size(Date2); size(Basis)], mfilename))
     return
end 



%Get the shape of the input arguments for later reshaping of the output
[RowSize, ColumnSize] = size(Date1);


%Make sure all inputs are packed into column vectors
Date1 = Date1(:);
Date2 = Date2(:);
Basis = Basis(:);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                   ************* GENERATE OUTPUT(S) **************
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Preallocate the output variable
YearFraction = zeros(size(Date1));


%Find cases where Basis is actual/actual and determine the year fraction
Ind = find(Basis == 0); 
if (~isempty(Ind)) 
     pad = ones(size(Date1(Ind))); 
     YearFraction(Ind) = daysact(Date1(Ind), Date2(Ind)) ./...
          (datenum(year(Date1(Ind)) + 1, pad, pad) - datenum(year(Date1(Ind)), pad, pad)); 
end


%Find cases where Basis is 30/360 and determine the year fraction
Ind = find(Basis == 1); 
if (~isempty(Ind)) 
     YearFraction(Ind) = days360(Date1(Ind), Date2(Ind)) ./ 360;     
end


%Find cases where Basis is actual/360 and determine the year fraction
Ind = find(Basis == 2); 
if (~isempty(Ind))
     pad = ones(size(Date1(Ind))); 
     YearFraction(Ind) = daysact(Date1(Ind), Date2(Ind)) ./ 360; 
end 


%Find cases where Basis is actual/365 and determine the year fraction
Ind = find(Basis == 3); 
if (~isempty(Ind))
     YearFraction(Ind) = daysact(Date1(Ind), Date2(Ind)) ./ 365;
end 


YearFraction = reshape(YearFraction, RowSize, ColumnSize);