function [x,y,sizey,endslopes] = chckxy2(x,y)
%CHCKXY check and adjust input for SPLINE and PCHIP
%   [X,Y,SIZEY] = CHCKXY(X,Y) checks the data sites X and corresponding data
%   values Y, making certain that there are exactly as many sites as values,
%   that no two data sites are the same, removing any data points that involve 
%   NaNs, reordering the sites if necessary to ensure that X is a strictly
%   increasing row vector and reordering the data values correspondingly,
%   and reshaping Y if necessary to make sure that it is a matrix, with Y(:,j)
%   the data value corresponding to the data site X(j), and with SIZEY the
%   actual dimensions of the given values. 
%   This call to CHCKXY is suitable for PCHIP.
%
%   [X,Y,SIZEY,ENDSLOPES] = CHCKXY(X,Y) also considers the possibility that
%   there are two more data values than there are data sites.
%   If there are, then the first and the last data value are removed from Y
%   and returned separately as ENDSLOPES. Otherwise, an empty ENDSLOPES is
%   returned.  This call to CHCKXY is suitable for SPLINE.
%
%   See also PCHIP, SPLINE.

%   Copyright 1984-2011 The MathWorks, Inc.

% make sure X is a vector:
if length(find(size(x)>1))>1 
  error(message('MATLAB:chckxy:XNotVector')) 
end

% ensure X is real
if any(~isreal(x)) 
  error(message('MATLAB:chckxy:XComplex')) 
end

% deal with NaN's among the sites:
nanx = find(isnan(x));
if ~isempty(nanx)
   x(nanx) = [];
   warning(message('MATLAB:chckxy:nan'))
end

n=length(x);
if n<2 
  error(message('MATLAB:chckxy:NotEnoughPts')) 
end

% re-sort, if needed, to ensure strictly increasing site sequence:
x=x(:).'; 
dx = diff(x);

if any(dx<0), [x,ind] = sort(x); dx = diff(x); else ind=1:n; end

% if ~all(dx), error(message('MATLAB:chckxy:RepeatedSites')), end
% YOU COMMENTED OUT THE ABOVE LINE B/C IT REQUIRES ALL ELEMENTS TO BE
% UNIQUE
% if Y is ND, reshape it to a matrix by combining all dimensions but the last:
sizey = size(y);


while length(sizey)>2&&sizey(end)==1, sizey(end) = []; end


yn = sizey(end); 
sizey(end)=[]; 
yd = prod(sizey);

if length(sizey)>1
   y = reshape(y,yd,yn);
else
   % if Y happens to be a column matrix, change it to the expected row matrix.
   if yn==1
       yn = yd;
       y = reshape(y,1,yn); 
       yd = 1; 
       sizey = yd;
   end
end

% determine whether not-a-knot or clamped end conditions are to be used:
nstart = n+length(nanx);
if yn==nstart
   endslopes = [];
elseif nargout==4&&yn==nstart+2
   endslopes = y(:,[1 n+2]); y(:,[1 n+2])=[];
   if any(isnan(endslopes))
      error(message('MATLAB:chckxy:EndslopeNaN'))
   end
   if any(isinf(endslopes))
       error(message('MATLAB:chckxy:EndslopeInf'))
   end
else
   error(message('MATLAB:chckxy:NumSitesMismatchValues',nstart, yn))
end

% deal with NaN's among the values:
if ~isempty(nanx)
    y(:,nanx) = [];
end

y=y(:,ind);
nany = find(sum(isnan(y),1));
if ~isempty(nany)
   y(:,nany) = []; x(nany) = [];
   warning(message('MATLAB:chckxy:IgnoreNaN'))
   n = length(x);
   if n<2 
     error(message('MATLAB:chckxy:NotEnoughPts')) 
   end
end

