function center_fig(h,resize)
%Centers the specified figure on the computer screen
%
%syntax: center_fig(h,resize)
%
%inputs:
%   h = figure handle (default = gcf)
%   resize = option to resize figures that are greater than the current screensize
%      0 = no resize
%      1 = resize(default)
%
%outputs:
%   none
%
%(c)2004 by Wade Sheldon
%
%This file is part of the GCE Data Toolbox for MATLAB(r) software library.
%
%The GCE Data Toolbox is free software: you can redistribute it and/or modify it under the terms
%of the GNU General Public License as published by the Free Software Foundation, either version 3
%of the License, or (at your option) any later version.
%
%The GCE Data Toolbox is distributed in the hope that it will be useful, but WITHOUT ANY
%WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
%PURPOSE. See the GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License along with The GCE Data Toolbox
%as 'license.txt'. If not, see <http://www.gnu.org/licenses/>.
%Department of Marine Sciences
%University of Georgia
%Athens, Georgia  30602-3636
%sheldon@uga.edu
%
%last modified: 21-Jun-2002

if exist('resize') ~= 1
   resize = 1;
elseif ischar(resize)
   resize = 1;
end

if exist('h') ~= 1
   h = [];
end

if isempty(h)
   if length(findobj) > 1
      h = gcf;
   else
      h = [];
   end
end

if ~isempty(h)

   res = get(0,'screensize');

   origunits = get(h,'units');
   set(h,'units','pixels')
   pos = get(h,'position');

   %check for need to resize
   if resize == 1 & (pos(3)>(res(3)-20) | pos(4)>(res(4)-80))
      ar = pos(4)./pos(3);
      diff_wid = pos(3)-(res(3)-20);
      diff_ht = pos(4)-(res(4)-80);
      if diff_wid >= diff_ht  %adjust based on width
         pos = [pos(1:2) res(3)-20 (res(3)-20).*ar];
      else  %adjust based on height
         pos = [pos(1:2) (res(4)-80)./ar res(4)-80];
      end
   end

   set(h,'position',[max(0,(res(3)-pos(3))./2) max(30,(res(4)-pos(4))./2) pos(3:4)])
   set(h,'units',origunits)  %reset original units

end


