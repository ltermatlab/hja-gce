function [s,msg] = DTchan2gce(data,template,titlestr,server,source)
%Converts Data Turbine channel data returned from DTalign into a GCE Data Structure
%
%syntax: [s,msg] = DTchan2gce(data,template,titlestr,server,source)
%
%inputs:
%   data = structure from DTalign containing a 'Date' field of MATLAB serial dates
%      and named fields containing Data Turbine channel data
%   template = metadata template to apply (string; optional; default = '' for none)
%   titlestr = data set title to use if not defined in the metadata template (string; optional;
%      default = '')
%   server = Data Turbine server, for logging data retrieval (string; optional; default = 'Data Turbine')
%   source = Data Turbine source, for logging data retrieval (string; optional; default = '')
%
%output:
%  s = GCE data structure containing a Date column and columns for each Data Turbine data channel
%  msg = text of any error messages
%
%
%(c)2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 24-Apr-2013

%init output
s = [];

%validate input
if nargin >= 1 && isstruct(data) && isfield(data,'Date')
   
   %set default template if omitted
   if exist('template','var') ~= 1
      template = '';
   end
   
   %set default title if omitted
   if exist('titlestr','var') ~= 1
      titlestr = '';
   end
   
   %set default server if omitted
   if exist('server','var') ~= 1
      server = '';
   end
   
   %set default source if omitted
   if exist('source','var') ~= 1
      source = '';
   end
   
   %convert standard struct to GCE Data Structure
   [s,msg] = imp_struct(data,'',template,'all');
   
   %populate datafile field
   if ~isempty(s)
      if ~isempty(server)
         str_server = ['Data Turbine ',server];
         if ~isempty(source)
            str_server = [str_server,'/',source];
         end
      else
         str_server = 'Data Turbine';
      end
      s.datafile =  {str_server length(data.Date)};
   end
   
   %add basic metadata if no template defined
   if isempty(template)
      
      %generate data set title
      if isempty(titlestr)
         if isempty(server) || isempty(source)
            titlestr = 'Data imported from Data Turbine';
         else
            titlestr = ['Data imported from Data Turbine source ''',source,''' on server ',server];
         end
      end
      
      %add title
      s = newtitle(s,titlestr);
      
      %get index of Date column
      col = name2col(s,'Date');
      
      if ~isempty(col)
         
         %update metadata for Date
         [s,msg] = update_attributes(s,col, ...
            {'units','description','variabletype','precision'}, ...
            {'serial day (base 1/1/0000)','Calendar date and time of observation','datetime',8});
         
         %add study date metadata
         s = add_studydates(s,col);
         
         %add date range to title
         s = add_title_dates(s,31);
         
      end
      
   else
      
      %apply metadata template
      s_temp = apply_template(s,template);     
      if ~isempty(s_temp)
         s = s_temp;
      else
         msg = 'an error occurred applying the metadata template';
      end
      
   end
   
else
   msg = 'invalid structure';
end
      
