function setpath(pos)
%Adds the current directory to the Matlab path
%
%syntax:  setpath(pos)
%
%input:
%  pos = position option
%    'begin' = prepend to beginning of path
%    'end' = append to path (default)
%
%output:
%  none
%
%last modified: 25-Jul-2008

if exist('pos','var') ~= 1
   pos = 'end';
end

if strcmp(pos,'begin')
   path(pwd,path);
else
   path(path,pwd);
end


