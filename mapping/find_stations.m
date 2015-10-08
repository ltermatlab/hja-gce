function [stat_coord,stat_labels,stat_codes] = find_stations(stat_ref,stat_begin,stat_end,stat_int,code,tol)
%Generates arrays of locations and labels for a range of CTD stations in a reference transect 
%
%syntax: [stat_coord,stat_labels] = find_stations(stat_ref,stat_begin,stat_end,stat_int,tol)
%
%input:
%  stat_ref = reference transect (3-column array of lon, lat, distance in km)
%  stat_begin = beginning station to find (in km)
%  stat_end = ending station to find (in km)
%  stat_int = station interval in km (default = 1, minimum = 0.01)
%  code = transect code for creating station codes (e.g. 'AL' for 'AL+03')
%  tol = tolerance for matching stations in km (default = 0.05, minimum 0.01)
%
%output:
%  stat_coord = station coordinates (3 column array of lon, lat, distance in km)
%  stat_labels = cell array of station labels
%
%
%(c)2005 Wade Sheldon
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
%last modified: 13-Apr-2005

stat_coord = [];
stat_labels = [];

if nargin >= 3
   
   %set default interval if omitted
   if exist('stat_int') ~= 1
      stat_int = 1;
   elseif stat_int < 0.01
      stat_int = 0.01;
   end
   
   %set default comparison tolerance
   if exist('tol') ~= 1
      tol = 0.05;
   elseif tol < 0.01
      tol = 0.01;
   end
   
   if exist('code') ~= 1
      code = '';
   end
   
   %generate label format string based on decimal places
   num_dec = max(fix(log10(abs(round(stat_begin)+1)))+1,fix(log10(abs(round(stat_end)+1)))+1);
   if stat_begin < 0
      num_dec = num_dec+1;
   end
   
   num_prec = 0;
   while stat_int ~= fix(stat_int * 10^num_prec)/10^num_prec
      num_prec = num_prec + 1;
   end
   
   formatstr = ['%-' int2str(num_dec+num_prec+1) '.' int2str(num_prec) 'f'];
   formatstr2 = ['%+03.',int2str(num_prec),'f'];
   
   %generate station interval and trim to data range
   all_int = [stat_begin:stat_int:stat_end]';
   if all_int(end) ~= stat_end
      all_int = [all_int ; stat_end];
   end

   Ivalid = find(all_int >= min(stat_ref(:,3)) & all_int <= max(stat_ref(:,3)));
   
   if ~isempty(Ivalid)
      
      %trim array of lookup distances to data range
      all_int = all_int(Ivalid);
      stat_coord = repmat(NaN,length(Ivalid),3);
      stat_labels = repmat({''},length(Ivalid),1);
      
      for n = 1:length(all_int)
         diff_dist = abs(stat_ref(:,3)-repmat(all_int(n),size(stat_ref,1),1));
         Iinrange = find(diff_dist <= tol);
         if ~isempty(Iinrange)
            [mindiff,Inearest] = min(diff_dist(Iinrange));
            stat_coord(n,:) = stat_ref(Iinrange(Inearest),1:3);
            stat_labels(n) = cellstr(sprintf(formatstr,stat_ref(Iinrange(Inearest),3)));
         end
      end
      
      Ivalid = find(~isnan(stat_coord(:,1)));
      
      if ~isempty(Ivalid)
         stat_coord = stat_coord(Ivalid,:);
         stat_labels = stat_labels(Ivalid);
         if ~isempty(code)
            sep = repmat({'+'},size(stat_coord,1),1);
            Ineg = find(stat_coord(:,3)<0);
            if ~isempty(Ineg)
               sep(Ineg) = {'-'};
            end
            diststr = repmat({''},size(stat_coord,1),1);
            for n = 1:size(stat_coord,1)
               diststr{n} = sprintf(formatstr2,stat_coord(n,3));
            end
            stat_codes = concatcellcols([repmat({code},length(Ivalid),1),diststr],'');
         else
            stat_codes = repmat({''},size(stat_coord,1),1);
         end
      else
         stat_coord = [];
         stat_labels = [];
         stat_codes = [];
      end
      
   end
   
end