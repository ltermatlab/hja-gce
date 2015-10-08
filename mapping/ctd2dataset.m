function [s,msg] = ctd2dataset(interval,station_start,station_end,rivers,transects)
%Generates a GCE Data Structure containing CTD station locations and labels for display or plotting
%(requires the GCE Data Toolbox)
%
%syntax: [s,msg] = ctd2dataset(interval,rivers,transects)
%
%input:
%  interval = station interval to look up in km (minimum 0.1, default = 1)
%  station_start = starting station (default = -40)
%  station_end = ending station (default = 100)
%  rivers = rivers to include (default = all)
%  transects = transect structure (default = transects in 'ctd_stations.mat')
%
%output:
%  s = data structure
%  msg = text of any error message
%
%
%(c)2005-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%
%contact:
%  Wade Sheldon
%  GCE-LTER Project
%  Department of Marine Sciences
%  University of Georgia
%  Athens, GA 30602-3636
%  sheldon@uga.edu
%
%last modified: 04-May-2015

s = [];
msg = '';

%check for data editor function in GCE Data Toolbox
gce_ed = exist('ui_editor','file');

if gce_ed == 2 || gce_ed == 6

   %validate interval
   if exist('interval','var') ~= 1
      interval = 1;
   elseif ~isnumeric(interval)
      interval = 1;
   elseif interval < 0.1
      interval = 0.1;
   end

   %validate transects
   if exist('transects','var') ~= 1
      transects = [];
   elseif ~isstruct(transects)
      transects = [];
   elseif ~isfield(transects,'river') || ~isfield(transects,'transect')
      transects = [];
   end

   %validate rivers
   if exist('rivers','var') ~= 1
      rivers = [];
   elseif ischar(rivers)
      rivers = cellstr(rivers);
   elseif ~iscell(rivers)
      rivers = [];
   end

   %validate station_start
   if exist('station_start','var') ~= 1
      station_start = -40;
   end

   %validate station_end
   if exist('station_end','var') ~= 1
      station_end = 100;
   end

   %check for ctd stations file
   if isempty(transects) && exist('ctd_stations.mat','file') == 2
      try
         v = load('ctd_stations.mat');
      catch
         v = struct('null','');
      end
      if isfield(v,'transects')
         transects = v.transects;
      end
   end

   %check for valid transects
   if ~isempty(transects)

      all_riv = [];
      all_ctd = [];
      all_lbl = [];
      all_codes = [];

      if ~isempty(rivers)
         Iriv = zeros(length(transects),1);
         for n = 1:length(rivers)
            Imatch = find(strcmp({transects.rivers},rivers{n}));
            if ~isempty(Imatch)
               Iriv(Imatch(1)) = 1;
            end
         end
         Iriv = find(Iriv);
      else
         Iriv = (1:length(transects))';
      end

      for n = 1:length(Iriv)
         riv = transects(Iriv(n)).river;
         [ctd,lbl,codes] = find_stations(transects(Iriv(n)).transect,station_start,station_end,interval,transects(Iriv(n)).code);
         if ~isempty(ctd)
            all_riv = [all_riv ; repmat({riv},size(ctd,1),1)];
            all_ctd = [all_ctd ; ctd];
            all_lbl = [all_lbl ; lbl];
            all_codes = [all_codes ; codes];
         end
      end

      if ~isempty(Iriv)

         s = newstruct;

         rivs = {transects.river};
         if length(Iriv) > 1
            rivstr = [cell2commas(rivs(Iriv),1),' Rivers'];
         else
            rivstr = [rivs(Iriv),' River'];
         end
         s = newtitle(s,['CTD stations for the ',rivstr]);

         s = addcol(s,all_riv,'Transect','none','Transect name','s','nominal','none',0,'',1);
         s = addcol(s,all_ctd(:,1),'Longitude','degrees','Geographic longitude','f','coord','continuous',5,'x<-180=''I'';x>180=''I''',2);
         s = addcol(s,all_ctd(:,2),'Latitude','degrees','Geographic latitude','f','coord','continuous',5,'x<-90=''I'';x>90=''I''',3);
         s = addcol(s,all_ctd(:,3),'Transect_Distance','km','Transect distance','f','calculation','continuous',2,'',4);
         s = addcol(s,all_lbl,'Distance_Label','none','Transect distance label','s','nominal','none',0,'',5);
         s = addcol(s,all_codes,'Station_Code','none','Station code','s','code','none',0,'',6);

         if isempty(s)
            msg = 'data structure could not be created';
         end

      else
         msg = 'no matching rivers found in the transects structure';
      end

   else
      msg = 'invalid transects structure';
   end

else
   msg = 'GCE Data Toolbox not found';
end
