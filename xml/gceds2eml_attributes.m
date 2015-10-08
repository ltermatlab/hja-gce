function [s_attr,s_stmml,msg] = gceds2eml_attributes(s_meta,misschar,mapunits,emlunits)
%Generates Ecological Metadata Language 2.1.1 attributeList metadata from a GCE Data Structure
%
%syntax: [s_attr,s_stmml,msg] = gceds2eml_attributes(s_meta,misschar,mapunits,emlunits)
%
%input:
%  s_meta = GCE Data Structure or xml metadata structure from listmeta.m (struct; required)
%  misschar = string to use to represent missing values when exporting to ASCII 
%     (string; optional; default = 'NaN')
%  mapunits = option to map units to the EML unit dictionary list (integer; optional; 
%     1 = yes/default, 0 = no)
%  emlunits = data structure containing an EML unit dictionary list when mapunits = 1
%     (struct; optional; default = data in EMLUnitDictionary.mat)
%
%output:
%  s_attr = structure containing EML attributeList content
%  s_stmml = structure containing STMML descriptions of custom units for additionalMetadata
%  msg = text of any error message
%
%notes:
%  1) 'misschar' must match the option specified when calling exp_ascii.m or the EML attributeList
%     will not be congruent with the data file
%  2) flag conversions (e.g. nullflags, cullflags, flags2cols) should be performed before calling
%     gceds2eml_attributes.m to ensure that flag columns are properly represented in EML and match the
%     ASCII file output (this is handled automatically when called from gceds2eml.m)
%  3) if mapunits = 1, units of numeric columns will be matched to names or abbreviations in the
%     EML Unit Dictionary (emlunits or EMLUnitDictionary.mat), and documented as standard or custom 
%     units, resp. The STMML metadata will automatically be generated 
%  4) if mapunits = 0, all existing units will be retained and documented as custom units, and 
%     minimal STMML metadata descriptions will be generated for additionalMetadata
%
%(c)2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 30-Jul-2014

%init output
s_stmml = [];
msg = '';

if nargin >= 1 && isstruct(s_meta)
   
   %default to NaN as missing character
   if exist('misschar','var') ~= 1
      misschar = 'NaN';
   elseif isempty(misschar)
      misschar = '';  %force empty character array
   end
   
   %default to mapping units
   if exist('mapunits','var') ~= 1 || mapunits ~= 0
      mapunits = 1;
   end
   
   %default to base EML unit dictionary
   if exist('emlunits','var') ~= 1 || ~gce_valid(emlunits,'data')
      emlunits = [];
      if exist('EMLUnitDictionary.mat','file') == 2
         try
            v = load('EMLUnitDictionary.mat');
         catch
            v = struct('null','');
         end
         if isfield(v,'data') && gce_valid(v.data,'data')
            emlunits = v.data;
         end
      end
   end
   
   %define date format mapping table between MATLAB and EML
   date_formats = {0,'dd-mmm-yyyy HH:MM:SS','DD-WWW-YYYY hh:mm:ss'; ...
      1,'dd-mmm-yyyy','DD-WWW-YYYY'; ...
      2,'mm/dd/yy','MM/DD/YY'; ...
      3,'mmm','WWW'; ...
      4,'m','M'; ...
      5,'mm','MM'; ...
      6,'mm/dd','MM/DD'; ...
      7,'dd','DD'; ...
      8,'ddd','DDD'; ...
      9,'d','D'; ...
      10,'yyyy','YYYY'; ...
      11,'yy','YY'; ...
      12,'mmmyy','WWWYY'; ...
      13,'HH:MM:SS','hh:mm:ss'; ...
      14,'HH:MM:SS PM','hh:mm:ss A/P'; ...
      15,'HH:MM','hh:mm'; ...
      16,'HH:MM PM','hh:mm A/P'; ...
      17,'QQ-YY','QQ-YY'; ...
      18,'QQ','QQ'; ...
      19,'dd/mm','DD/MM'; ...
      20,'dd/mm/yy','DD/MM/YY'; ...
      21,'mmm.dd,yyyy HH:MM:SS','WWW.DD.YYYY hh:mm:ss'; ...
      22,'mmm.dd,yyyy','WWW.DD.YYYY'; ...
      23,'mm/dd/yyyy','MM/DD/YYYY'; ...
      24,'dd/mm/yyyy','DD/MM/YYYY'; ...
      25,'yy/mm/dd','YY/MM/DD'; ...
      26,'yyyy/mm/dd','YYYY/MM/DD'; ...
      27,'QQ-YYYY','QQ-YYYY'; ...
      28,'mmmyyyy','WWWYYYY'; ...
      29,'yyyy-mm-dd','YYYY-MM-DD'; ...
      30,'yyyymmddTHHMMSS','YYYYMMDDThhmmss'; ...
      31,'yyyy-mm-dd HH:MM:SS','YYYY-MM-DD hh:mm:ss'};
   
   %validate s_meta structure
   if ~isfield(s_meta,'Dataset') && isfield(s_meta,'metadata')
      [~,s_meta] = listmeta(s_meta,'xml');
   end
   
   if ~isempty(s_meta)
      
      cols = [s_meta.Data.Columns.Column];
      numcols = length(cols);
      s_attr = repmat(struct('attribute',''),1,numcols);
      
      %generate missing value fragment for numeric columns
      s_missing = struct( ...
         'code',misschar, ...
         'codeExplanation','value not recorded or censored based on quality control analysis (see methods)');
      
      %init stmml struct
      s_stmml = [];
      
      for c = 1:numcols
         
         cname = cols(c).Name;
         units = cols(c).Units;
         desc = cols(c).Description;
         dtype = cols(c).DataType;
         vtype = cols(c).VariableType;
         ntype = cols(c).NumberType;
         
         %generate EML precision
         prec = fix(str2double(cols(c).Precision));
         if prec > 0
            emlprec = sprintf(['%0.',int2str(prec),'f'],10^(-1*prec));
         else
            emlprec = '1';
         end
         
         %parse Q/C rules
         qc = cols(c).QC_Criteria;
         [min_exclusive,min_inclusive,max_exclusive,max_inclusive] = sub_parse_qc(qc);
         
         %parse codes
         codes = cols(c).ValueCodes;
         if ~isempty(codes)
            [codes,codedefs] = splitcodes(codes,',');
         end
         
         %determine measurementscale based on variable type
         switch vtype
            
            case 'datetime'
               
               %document based on data type
               if strcmp(dtype,'string')
                  
                  %set measurement scale
                  storageType = 'string';
                  mscale = 'dateTime';

                  %try to resolve date formats to EML standard date field tokens
                  Idash = strfind(units,'- ');
                  if ~isempty(Idash)
                     units = deblank(units(1:Idash-1));  %remove time zone appended to date format
                  end
                  Iunits = find(strcmp(units,date_formats(:,2)));
                  if ~isempty(Iunits)
                     units = date_formats{Iunits(1),3};
                  end                  
                  
               elseif ~strcmp(dtype,'integer')  %float/exp
                  
                  storageType = 'float';
                  mscale = 'interval';

                  if mapunits == 1
                     %override units to ensure match to matlab serial date custom unit
                     units = 'serialDateNumberYear0000';  
                  end

               else
                  
                  storageType = 'integer';
                  mscale = 'interval';
                  
                  %remove time zone appended to date part format
                  if strfind(units,'- ') > 0
                     units = deblank(strtok(units,'-'));  
                  end
                  
                  %try to match column name or units to standard date parts
                  if mapunits == 1
                     if strncmpi(cname,'Year',4) || strcmpi(units,'YYYY') || strcmpi(units,'YY')
                        units = 'nominalYear';
                     elseif strncmpi(cname,'Month',5) || strcmpi(units,'MM') || strcmpi(units,'M') || strncmpi(units,'mon',3)
                        units = 'nominalMonth';
                     elseif strncmpi(cname,'Day',3) || strcmpi(units,'DD') || strcmpi(units,'D') || strncmpi(units,'day',3)
                        units = 'nominalDay';
                     elseif strncmpi(cname,'Hour',4) || strcmpi(units,'HH') || strcmpi(units,'H') || strncmpi(units,'hour',4) || strncmpi(units,'hr',2)
                        units = 'nominalHour';
                     elseif strncmpi(cname,'Min',3) || strcmpi(units,'mm') || strncmpi(units,'min',3)
                        units = 'nominalMinute';
                     elseif strncmpi(cname,'Sec',3) || strcmpi(units,'ss') || strcmpi(units,'sec')
                        units = 'second';
                     else
                        %keep user-defined units for use as format string
                     end
                  end
                     
               end
               
            case 'geographic coordinate'
               
               storageType = dtype;

               if strcmp(dtype,'s')
                  mscale = 'nominal';
               else
                  mscale = 'interval';
               end
               
            case 'coded value'
               
               storageType = dtype;
               
               if strcmp(dtype,'s')
                  mscale = 'nominal';
               else
                  mscale = 'ordinal';
               end
               
            case 'free text'
               
               storageType = dtype;
               mscale = 'nominal';               
               
            case 'ordinal'
               
               storageType = dtype;
               mscale = 'ordinal';
               
            case 'nominal'
               
               storageType = dtype;
               mscale = 'nominal';
               
            case 'logical'
               
               storageType = dtype;
               mscale = 'nominal';
               
            otherwise  %data, calculation
               
               storageType = dtype;
               
               if strcmp(dtype,'s')
                  mscale = 'nominal';
               elseif strcmp(dtype,'d')
                  mscale = 'interval';
               elseif strcmp(ntype,'angular')
                  mscale = 'interval';  %check for angular data
               else
                  mscale = 'ratio';
               end
               
         end
         
         %generate numberType based on data type
         switch dtype
            case 's'
               numberType = '';
            case 'd'
               numberType = 'whole';
            otherwise  %'f' or 'e'
               numberType = 'real';
         end
         
         %look up EML units
         if strcmp(mscale,'interval') || strcmp(mscale,'ratio')
            [emlunit,custom,stmml] = sub_emlunits(units,mapunits,emlunits);
            if ~isempty(stmml)
               s_stmml = [s_stmml , stmml];
            end
         end
         
         %generate attribute struct
         s_attr(c).attribute.attributeName = cname;
         s_attr(c).attribute.attributeDefinition = desc;
         s_attr(c).attribute.storageType = storageType;         

         %generate measurementScale
         if strcmp(mscale,'dateTime')
            
            %just add formatString for dateTime
            s_attr(c).attribute.measurementScale = struct('dateTime',struct('formatString',units));
            
         elseif strcmp(mscale,'interval') || strcmp(mscale,'ratio')
            
            %init fragment
            if custom == 1
               s_attr(c).attribute.measurementScale = struct(mscale,struct('unit',struct('customUnit',emlunit)));
            else
               s_attr(c).attribute.measurementScale = struct(mscale,struct('unit',struct('standardUnit',emlunit)));
            end
            
            %add precision
            s_attr(c).attribute.measurementScale.(mscale).precision = emlprec;
            
            %add numberType
            s_attr(c).attribute.measurementScale.(mscale).numericDomain.numberType = numberType;
            
            %check for bounds
            if ~isempty(min_exclusive)
               s_attr(c).attribute.measurementScale.(mscale).numericDomain.bounds.minimum = {'exclusive="true"',min_exclusive};
            end
            if ~isempty(min_inclusive)
               s_attr(c).attribute.measurementScale.(mscale).numericDomain.bounds.minimum = {'exclusive="false"',min_inclusive};
            end
            if ~isempty(max_exclusive)
               s_attr(c).attribute.measurementScale.(mscale).numericDomain.bounds.maximum = {'exclusive="true"',max_exclusive};
            end
            if ~isempty(max_inclusive)
               s_attr(c).attribute.measurementScale.(mscale).numericDomain.bounds.maximum = {'exclusive="false"',max_inclusive};
            end
            
            %add missing value code
            s_attr(c).attribute.missingValueCode = s_missing;
            
         else  %nominal or ordinal
            
            %check for coded column
            if ~isempty(codes)
               
               %generate code sub-structure
               s_codes = repmat(struct('code','','definition',''),1,length(codes));
               for n = 1:length(codes)
                  s_codes(n).code = codes{n};
                  s_codes(n).definition = codedefs{n};
               end
               
               %generate enumeratedDomain node
               s_attr(c).attribute.measurementScale.(mscale).nonNumericDomain.enumeratedDomain.codeDefinition = s_codes;
               
            else
               
               %generate textDomain node using column descriptino for description
               s_attr(c).attribute.measurementScale.(mscale).nonNumericDomain.textDomain.definition = desc;
               
            end
            
         end
         
      end
      
   else
      msg = 'failed to generate metadata structure from GCE Data Structure';
   end
   
else
   msg = 'a metadata structure or valid GCE Data Structure is required';
end
return


%sub-function to look up units in the EML Unit Dictionary and return the unit name, standard/custom flag and STMML fragment
function [unit,custom,stmml] = sub_emlunits(unitstr,mapunits,emlunits)
%unitstr = unit to document
%mapunits = option to map units to the EML unit dictionary
%emlunits = EML unit dictionary data structure

%query unit dictionary by name or abbreviation
if mapunits == 1
   s = querydata(emlunits,['strcmp(name,''',unitstr,''')']);
   if isempty(s)
      s = querydata(emlunits,['strcmp(abbreviation,''',unitstr,''')']);
   end
else
   s = [];
end

%check for match to query
if ~isempty(s) && num_records(s) >= 1
   
   %just take first match
   s = copyrows(s,1);
   
   %extract unit name, custom flag
   unit = extract(s,'name');
   custom = extract(s,'custom');
   
   %generate stmml struct for custom unit
   if custom == 1
      
      %get custom unit description fields
      unitType = char(extract(s,'unitType'));
      abbrev = char(extract(s,'abbreviation'));
      parentSI = char(extract(s,'parentSI'));
      mult = char(extract(s,'multiplierToSI'));
      const = char(extract(s,'constantToSI'));
      desc = char(extract(s,'description'));
      if isempty(desc)
         desc = 'user-defined unit';
      end
      
      %generate stmml struct with required fields
      stmml = struct('stmml__unit',struct( ...
         'attrib_id',unit, ...
         'attrib_name',unit));
      
      %add optional fields
      if ~isempty(unitType)
         stmml.stmml__unit.attrib_unitType = unitType;
      end
      if ~isempty(abbrev)
         stmml.stmml__unit.attrib_abbreviation = abbrev;
      end
      if ~isempty(parentSI)
         stmml.stmml__unit.attrib_parentSI = parentSI;
      end
      if ~isempty(mult)
         stmml.stmml__unit.attrib_multiplierToSI = mult;
      end
      if ~isempty(const)
         stmml.stmml__unit.attrib_constantToSI = const;
      end
     
      %add description
      stmml.stmml__unit.stmml__description = desc;
      
   else
      stmml = [];
   end
   
else
   
   %no match - return original units and generate custom unit stmml
   unit = unitstr;
   custom = 1;
   stmml.stmml__unit = struct('attrib_id',unitstr,'attrib_name',unitstr,'stmml__description',['user defined unit ',unitstr]);

end
return


%sub-function for parsing Q/C rules to generate bounds for EML attributes
function [min_exclusive,min_inclusive,max_exclusive,max_inclusive] = sub_parse_qc(str)

min_exclusive = '';
min_inclusive = '';
max_exclusive = '';
max_inclusive = '';

%parse criteria using semicolon delimiters
ar = splitstr(str,';');

%evaluate each criteria rule checking for supported patterns
for m = 1:length(ar)
   c = ar{m};  %extract criteria string
   if strncmp(c,'x<=',3)
      Imatch = strfind(c,'="I"');  %test for min valid flag
      if ~isempty(Imatch)
         min_inclusive = c(4:Imatch(1)-1);
      end
   elseif strncmp(c,'x<',2)
      Imatch = strfind(c,'="I"');  %test for min valid flag
      if ~isempty(Imatch)
         min_exclusive = c(3:Imatch(1)-1);
      end
   elseif strncmp(c,'x>=',3)
      Imatch = strfind(c,'="I"');  %test for min valid flag
      if ~isempty(Imatch)
         max_inclusive = c(4:Imatch(1)-1);
      end
   elseif strncmp(c,'x>',2)
      Imatch = strfind(c,'="I"');  %test for min valid flag
      if ~isempty(Imatch)
         max_exclusive = c(3:Imatch(1)-1);
      end
   end
end
