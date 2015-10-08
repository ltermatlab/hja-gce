function tval = t_value_onetail(alpha,df)
%Returns the area under the Student t distribution (single side) for a given alpha and degrees of freedom
%
%syntax: tval = t_value_onetail(alpha,df)
%
%inputs:
%  alpha = probability (e.g. 0.05)
%  df = degrees of freedom
%
%outputs:
%  tval = t-value (area under the right tail of the t-distribution given alpha, df)
%
%adapted from functions 'qt', 'qbeta' and 'dbeta' written by Anders Holtsberg in:
%
%  STIXBOX
%  A statistics toolbox for Matlab and Octave. 
%  Version 1.29, 10-May-2000 
%  GNU Public Licence Copyright (c) Anders Holtsberg. 
%  Comments and suggestions to andersh@maths.lth.se
%  url: http://www.maths.lth.se/matstat/stixbox/
%
%Wade Sheldon
%Dept. of Marine Sciences
%Univ. of Georgia
%Athens, GA 30602
%email: sheldon@uga.edu
%
%last modified: 13-Sep-2010

tval = [];

if nargin == 2
   
   if alpha > 0 && alpha <= 1 && df > 0
      try
         tval = abs(sub_qt(alpha,df));
      catch
         tval = [];
      end
   end
   
end   


function x = sub_qt(p,a)
%QT       The student t inverse distribution function
%
%         x = qt(p,DegreesOfFreedom)

%       Anders Holtsberg, 18-11-93
%       Copyright (c) Anders Holtsberg

%added by Wade Sheldon on 26-Feb-2006 to match constraint in 'qbeta'
a = min(a,200000);

s = p<0.5; 
p = p + (1-2*p).*s;
p = 1-(2*(1-p));
x = sub_qbeta(p,1/2,a/2);
x = x.*a./((1-x));
x = (1-2*s).*sqrt(x);


function x = sub_qbeta(p,a,b)
%QBETA    The beta inverse distribution function
%
%         x = qbeta(p,a,b)

%       Anders Holtsberg, 27-07-95
%       Copyright (c) Anders Holtsberg

if any(any((a<=0)|(b<=0)))
   error('Parameter a or b is nonpositive')
end
if any(any(abs(2*p-1)>1))
   error('A probability should be 0<=p<=1, please!')
end
b = min(b,100000);

x = a ./ (a+b);
dx = 1;
while any(any(abs(dx)>256*eps*max(x,1)))
   dx = (betainc(x,a,b) - p) ./ sub_dbeta(x,a,b);
   x = x - dx;
   x = x + (dx - x) / 2 .* (x<0);
   x = x + (1 + (dx - x)) / 2 .* (x>1);
end


function d = sub_dbeta(x,a,b)
%DBETA    The beta density function
%
%         f = dbeta(x,a,b)

%       Anders Holtsberg, 18-11-93
%       Copyright (c) Anders Holtsberg

if any(any((a<=0)|(b<=0)))
   error('Parameter a or b is nonpositive')
end

I = find((x<0)|(x>1));

d = x.^(a-1) .* (1-x).^(b-1) ./ beta(a,b);
d(I) = 0*I;
