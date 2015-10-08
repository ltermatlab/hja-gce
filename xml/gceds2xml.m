function [xml,msg] = gceds2xml(s,cols,headings,xsl_url,fn)
%Generates HTML markup to display selected columns of a GCE Data Structure in a web table
%
%syntax: [xml,msg] = gceds2xml(s,cols,headings,xsl_url,fn)
%
%inputs:
%   s = data structure to export
%   cols = array of column names or index numbers to include (cell or integer array; optional; default = all)
%   headings = array of table headings (cell array; optional; default = column names)
%   xsl_url = XSL stylesheet link to include in the preamble (string; optional; default = '' for none)
%   fn = filename for saving the xml file (string; optional; default = '' for none)
%
%outputs:
%   xml = XML document (cell array of strings)
%   msg = text of any error message
%
%notes:
%  1) if headings are specified, the array must match the length of cols or they will be ignored
%  2) the xml schema is as follows:
%     <?xml version="1.0" encoding="ISO-8859-1"?>
%     <dataset>
%     <metadata>
%       <title>Real-time climate data from the ...</title>
%       <abstract>Air temperature, relative humidity, barometric pressure, precipitation, ...</abstract>
%       <author>
%          Name: Joe Scientist
%          Position: xxxxxxxxxxx
%          Address: xxxxxxxxxxxx
%          Postal Code: xxxxxxxx
%          Phone: (xxx) xxx-xxxx
%          Email: xxx@xxx.xxx.xxx
%       </author>
%       <units>
%         <col name="NESDIS_ID">none</col>
%         <col name="NWSLID">none</col>
%         <col name="Date">DD-MMM-YYYY HH:MM:SS - GMT</col>
%         <col name="Temp_Air">°C</col>
%         <col name="Max_Temp_Air">°C</col>
%       </units>
%       <descriptions>
%         <col name="NESDIS_ID">NOAA National Environmental Satellite, Data and Information Service Platform ID</col>
%         <col name="NWSLID">National Weather Service Location ID</col>
%         <col name="Date">Calendar date and time of observation</col>
%         <col name="Temp_Air">Air temperature, 15 minute mean</col>
%         <col name="Max_Temp_Air">Maximum air temperature, 15 minute</col>
%       </descriptions>
%       <datatypes>
%         <col name="NESDIS_ID">string</col>
%         <col name="NWSLID">string</col>
%         <col name="Date">string</col>
%         <col name="Temp_Air">floating-point</col>
%         <col name="Max_Temp_Air">floating-point</col>
%       </datatypes>
%       <codes>
%         <col name="NESDIS_ID"></col>
%         <col name="NWSLID">SAXG1 = Sapelo Island NERR Marsh Landing</col>
%         <col name="Date"></col>
%         <col name="Temp_Air"></col>
%         <col name="Max_Temp_Air"></col>
%       </codes>
%     </metadata>
%     <data>
%       <row number="1">
%         <col name="NESDIS_ID">3B036592</col>
%         <col name="NWSLID">SAXG1</col>
%         <col name="Date">10-May-2013 01:45:00</col>
%         <col name="Temp_Air">22.072</col>
%         <col name="Max_Temp_Air">22.150</col>
%       </row>
%       <row number="2">
%         <col name="NESDIS_ID">3B036592</col>
%         <col name="NWSLID">SAXG1</col>
%         <col name="Date">10-May-2013 02:00:00</col>
%         <col name="Temp_Air" qualifier="Q">42.011</col>
%         <col name="Max_Temp_Air">22.078</col>
%       </row>
%     </data>
%     </dataset>
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

xml = '';
msg = '';

if nargin >= 1 && gce_valid(s,'data')
   
   %default to all columns
   if exist('cols','var') ~= 1 || isempty(cols)
      cols = 1:length(s.name);
   elseif ~isnumeric(cols)
      cols = name2col(s,cols);
   else
      cols = cols(cols > 0 & cols <= length(s.name));
   end
   
   %check for valid column selection
   if ~isempty(cols)
      
      %subset data
      s = copycols(s,cols,'Y');
      cols = 1:length(s.name); %update column selection
      
      %set default headings
      if exist('headings','var') ~= 1 || length(headings) ~= length(cols)
         headings = s.name;
      end
      
      %get attribute metadata before transformation
      units = s.units;
      desc = s.description;
      codes = parse_codes(s);
      dtypes = s.datatype;
      vtypes = s.variabletype;
      
      %convert all columns to string
      s = convert_datatype(s,cols,'s');
      
      if ~isempty(s)
         
         %get number of records
         numrecs = num_records(s);
         numcols = length(cols);
         
         %get data arrays
         [data,flags] = extract(s,cols);
         
         %generate datatype labels, changing floating-point datetime fields to string to reflect convert_datatype transform
         Idt = strcmp('f',dtypes) & strcmp('datetime',vtypes);
         dtypes(Idt) = {'s'};
         Istring = strcmp('s',dtypes);
         Ifloat = strcmp('f',dtypes);
         Iexp = strcmp('e',dtypes);
         Iint = strcmp('d',dtypes);
         dtypes(Istring) = {'string'};
         dtypes(Ifloat) = {'floating-point'};
         dtypes(Iexp) = {'exponential'};
         dtypes(Iint) = {'integer'};
         
         %expand empty flag columns
         nullflags = repmat(' ',numrecs,1);
         Inullflags = cellfun('isempty',flags);
         flags(Inullflags) = {nullflags};
         
         %define characters to escape
         badchars = {'&','&amp;'; ...
            '<','&lt;'; ...
            '>','&gt;'};
         
         %loop through columns escaping invalid markup
         for n = 1:length(data)
            col_data = escape_chars(data{n},badchars);
            data{n} = col_data;
         end
         
         %escape markup in headings
         headings = escape_chars(headings,badchars);
         
         %escape markup in metadata
         units = escape_chars(units,badchars);
         desc = escape_chars(desc,badchars);
         codes = escape_chars(codes,badchars);
         
         %get title and investigator
         titlestr = escape_chars(s.title,badchars);
         abstract = escape_chars(lookupmeta(s,'Dataset','Abstract'));
         author = escape_chars(splitstr(lookupmeta(s,'Dataset','Investigator'),'|'),badchars);
         if ~cellfun('isempty',author)
            author = concatcellcols([repmat({'      '},length(author),1) author],'');
         end
         
         %generate xml fragments for metadata
         units_xml = cell2xml('units','col','name',headings,units);
         desc_xml = cell2xml('descriptions','col','name',headings,desc);
         dtypes_xml = cell2xml('datatypes','col','name',headings,dtypes);
         codes_xml = cell2xml('codes','col','name',headings,codes);
         
         %calculate number of total rows for dimensioning cell array
         numrows = 2 + (numcols + 2) * numrecs;
         
         %init output
         str = repmat({''},numrows,1);
         
         %init xml fragment
         str{1} = '<data>';
         str{numrows} = '</data>';
         ptr = 1;
         
         %loop through data rows
         for r = 1:numrecs
            
            %open row
            ptr = ptr + 1;
            str{ptr} = ['  <row number="',int2str(r),'">'];
            
            %add data values
            for c = 1:numcols
               ptr = ptr + 1;
               val = data{c}{r};
               flag = deblank(flags{c}(r,1:end));
               qual = '';
               if ~isempty(flag)
                  qual = [' qualifier="',unique(flag),'"'];
               end
               str{ptr} = ['    <col name="',headings{c},'"',qual,'>',val,'</col>'];
            end
            
            %close row
            ptr = ptr + 1;
            str{ptr} = '  </row>';
            
         end
         
         %close table
         ptr = ptr + 1;
         str{ptr} = '</data>';
         
         %generate xml preamble
         if exist('xsl_url','var') == 1 && ~isempty(xsl_url)
            preamble = {'<?xml version="1.0" encoding="ISO-8859-1"?>'; xsl_url};
         else
            preamble = {'<?xml version="1.0" encoding="ISO-8859-1"?>'};
         end
         
         %add preamble to output
         xml = [preamble ; ...
            {'<dataset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://gce-lter.marsci.uga.edu/public/xsl/toolbox/dataset_schema.xsd">'}; ...
            {'<metadata>'}; ...
            {['  <title>',titlestr,'</title>']}; ...
            {['  <abstract>',abstract,'</abstract>']}; ...
            {'  <author>'}; ...
            author; ...
            {'  </author>'}; ...
            units_xml; ...
            desc_xml; ...
            dtypes_xml; ...
            codes_xml; ...
            {'</metadata>'}; ...
            str ; ...
            {'</dataset>'}];
         
         %save file
         if exist('fn','var') == 1 && ~isempty(fn)
            try
               fid = fopen(fn,'w');
               fprintf(fid,'%s\r\n',xml{:});
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
return


function codes = parse_codes(s)
%parses codes in metadata of a GCE Data Structure and returns an array of codes for each column
%
%input:
%  s = data structure containing codes to parse
%
%output:
%  codes = cell array of codes for each column (even if empty)
%
%last modified: 17-May-2013

codes = repmat({''},1,length(s.name));

str_codes = lookupmeta(s,'Data','ValueCodes');

if ~isempty(str_codes)
   
   %split code assignments for multiple columns
   if ~isempty(strfind(str_codes,'|'))
      delim = '|';
   else
      delim = ';';
   end
   ar = splitstr(str_codes,delim);
   
   %parse codes for specified column
   for col = 1:length(s.name)
      
      %get column name
      colname = s.name{col};
      
      %look up cell starting with column name and colon
      Icol = find(strncmp(ar,[colname,':'],length(colname)+1));
      
      %extract code definitions
      for n = 1:length(Icol)
         ar2 = splitstr(ar{Icol(n)},':');
         if length(ar2) == 2
            if isempty(codes{col})
               codes{col} = ar2{2};
            else
               codes{col} = [codes{col},', ',ar2{2}];
            end
         end
      end
      
   end
   
end
return


function xml = cell2xml(root,element,attribute,attributes,str)
%generates an xml fragment from a cell array of stringts
%
%input:
%  root = root element of fragment
%  element = element name
%  attribute = attribute name
%  attributes = attribute values
%  str = element values
%
%output:
%  xms = cell array containing xml fragment
%
%last modified: 17-May-2013

%dimension output array
xml = repmat({''},2+length(str),1);

%add open and close tags for root element
xml{1} = ['  <',root,'>'];
xml{end} = ['  </',root,'>'];

%generate elements/attributes
for n = 1:length(str)
   ptr = n + 1;
   xml{ptr} = ['    <',element,' ',attribute,'="',attributes{n},'">',str{n},'</',element,'>'];
end