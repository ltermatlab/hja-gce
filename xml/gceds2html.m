function [str,msg] = gceds2html(s,cols,headings,orientation,css_id,html,css_url,fn)
%Generates HTML markup to display selected columns of a GCE Data Structure in a web table
%
%syntax: [str,msg] = gceds2html(s,cols,headings,orientation,css_id,html,css_url,fn)
%
%inputs:
%   s = data structure to export
%   cols = array of column names or index numbers to include (cell or integer array; optional; default = all)
%   headings = array of table headings (cell array; optional; default = column names)
%   orientation = table orientation (string; optional):
%      'column' = column-major with variables as columns and headers in the first row (default)
%      'row' = row major with variables as rows and headers in the first column
%   css_id = string to include in the table element as the CSS ID (default = 'data-table')
%   html = option to add html tags to the output
%      0 = no (default)
%      1 = yes
%   css_url = CSS stylesheet link to include in the header if html = 1 (string; default = '')
%   fn = filename for saving the table markup (string; optional; default = '' for none)
%
%outputs:
%   str = HTML markup (cell array of strings)
%   msg = text of any error message
%
%notes:
%   1) table cells containing flagged values will be assigned css class = 'flagged' and include
%      the assigned flags in a title attribute for display when hovered over with the mouse
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
%last modified: 23-May-2013

str = '';
msg = '';

if nargin >= 1 && gce_valid(s,'data')
   
   %default to all columns
   if exist('cols','var') ~= 1 || isempty(cols)
      cols = (1:length(s.name));
   elseif ~isnumeric(cols)
      cols = name2col(s,cols);
   else
      cols = cols(cols > 0 & cols <= length(s.name));
   end
   
   %set default orientation
   if exist('orientation','var') ~= 1 || ~strcmpi(orientation,'row')
      orientation = 'column';
   end
   
   %set default css_url
   if exist('css_url','var') ~= 1
      css_url = '';
   end
   
   %set default css_id if css_url is empty
   if exist('css_id','var') ~= 1 || (isempty(css_url) && isempty(css_id))
      css_id = 'data-table';
   end
   if ~isempty(css_id)
      %generate id attribute
      css_id = [' id="',css_id,'"'];
   end
   
   %check for valid column selections
   if ~isempty(cols)
      
      %subset data
      s = copycols(s,cols,'Y');
      cols = 1:length(s.name);
      
      %set default headings
      if exist('headings','var') ~= 1 || length(headings) ~= length(cols)
         headings = s.name;
      end
      
      %convert all columns to string
      s = convert_datatype(s,cols,'s');
      
      if ~isempty(s)
         
         %get number of records
         numrecs = num_records(s);
         numcols = length(cols);
         
         %get data arrays
         [data,flags] = extract(s,cols);
         
         %get units and descriptions
         units = s.units(cols);
         desc = s.description(cols);
         
         %expand empty flag columns
         nullflags = repmat(' ',numrecs,1);
         Inullflags = cellfun('isempty',flags);
         flags(Inullflags) = {nullflags};
         
         %define characters to escape
         badchars = {'&','&amp;'; ...
            '<','&lt;'; ...
            '>','&gt;'};
         
         %replace empty cells with &nbsp; and escape invalid characters
         for n = 1:length(data)
            
            %extract column
            col_data = data{n};
            
            %escape markup characters
            col_data = escape_chars(col_data,badchars);
            
            %replace empty values with &nbsp;
            Iempty = cellfun('isempty',col_data);
            col_data(Iempty) = {'&nbsp;'};
            
            %update master array
            data{n} = col_data;
            
         end
         
         %escape markup in headings, units and descriptions
         headings = escape_chars(headings,badchars);
         units = escape_chars(units,badchars);
         desc = escape_chars(desc,badchars);
         titlestr = escape_chars(s.title,badchars);
         
         %generate table
         if strcmpi(orientation,'row')
            
            %calculate number of total rows for dimensioning cell array
            numrows = 2 + (numcols + 1) * (numrecs + 1);
            
            %init output
            str = repmat({''},numrows,1);
            
            %open table
            str{1} = ['<table',css_id,'>'];
            ptr = 1;
            
            %open row
            ptr = ptr + 1;
            str{ptr} = '  <tr>';
            
            %loop through data rows
            for c = 1:numcols
               
               %open row
               ptr = ptr + 1;
               str{ptr} = '  <tr>';
               
               %add heading
               ptr = ptr + 1;
               meta = [headings{c},' (',units{c},') - ',desc{c}];
               str{ptr} = ['    <th title="',meta,'">',headings{c},'</th>'];
               
               %add data values
               for r = 1:numrecs
                  ptr = ptr + 1;
                  val = data{c}{r};
                  flag = deblank(flags{c}(r,1:end));
                  att = '';
                  if ~isempty(flag)
                     att = [' class="flagged" title="',unique(flag),'"'];
                  end
                  str{ptr} = ['    <td',att,'>',val,'</td>'];
               end
               
               %close row
               ptr = ptr + 1;
               str{ptr} = '  </tr>';
               
            end
            
         else  %column-major
            
            %calculate number of total rows for dimensioning cell array
            numrows = 2 + (numcols + 2) * (numrecs + 1);
            
            %init output
            str = repmat({''},numrows,1);
            
            %open table
            str{1} = ['<table',css_id,'>'];
            ptr = 1;
            
            %open row
            ptr = ptr + 1;
            str{ptr} = '  <tr>';
            
            %add headings
            for c = 1:numcols
               ptr = ptr + 1;
               meta = [headings{c},' (',units{c},') - ',desc{c}];
               str{ptr} = ['    <th title="',meta,'">',headings{c},'</th>'];
            end
            
            %close row
            ptr = ptr + 1;
            str{ptr} = '  </tr>';
            
            %loop through data rows
            for r = 1:numrecs
               
               %open row
               ptr = ptr + 1;
               str{ptr} = '  <tr>';
               
               %add data values
               for c = 1:numcols
                  ptr = ptr + 1;
                  val = data{c}{r};
                  flag = deblank(flags{c}(r,1:end));
                  att = '';
                  if ~isempty(flag)
                     att = [' class="flagged" title="',unique(flag),'"'];
                  end
                  str{ptr} = ['    <td',att,'>',val,'</td>'];
               end
               
               %close row
               ptr = ptr + 1;
               str{ptr} = '  </tr>';
               
            end
            
         end
         
         %close table
         str{ptr+1} = '</table>';
         
         %add html tags
         if exist('html','var') == 1 && html == 1
            
            %add css link
            if ~isempty(css_url)
               head = {'<head>'; ...
                  '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'; ...
                  ['<title>',titlestr,'</title>']; ...
                  ['<link rel="stylesheet" media="all" type="text/css" href="',css_url,'" />']; ...
                  '</head>'};
            else
               head = {'<head>'; ...
                  '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'; ...
                  ['<title>',titlestr,'</title>']; ...
                  '<style type="text/css" media="all">'; ...
                  '#data-table { border-collapse: collapse; margin: 0.5em 5px 0.5em 5px; }'; ...
                  'th,td { white-space: nowrap; font-size: 11px; }'; ...
                  'td { padding: 1px 5px 1px 5px; border: 1px solid #DDD;}'; ...
                  'th { padding: 4px 5px 4px 5px; border: 1px solid #AAA; background-color: #DDD; color: #000;}'; ...
                  'td.flagged { background-color: #8B0000; color: #FFD700;}'; ...
                  '</style>'; ...
                  '</head>'};
            end
            
            %add html markup to str
            str = [{'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'} ; ...
               {'<html xmlns="http://www.w3.org/1999/xhtml">'}; ...
               head; ...
               {'<body>'}; ...
               str; ...
               {'</body>'}; ...
               {'</html>'}];
            
         end
         
         %save file
         if exist('fn','var') == 1 && ~isempty(fn)
            try
               fid = fopen(fn,'w');
               fprintf(fid,'%s\r\n',str{:});
               fclose(fid);
            catch e
               msg = ['an error occurred writing the file: ',e.message];
            end
         end
         
      else
         msg = 'an error occurred converting the specified column(s) to string format';
      end
      
   else
      msg = 'invalid column selection';
   end
   
else
   if nargin == 0
      msg = 'data structure is required';
   else
      msg = 'invalid data structure';
   end
end