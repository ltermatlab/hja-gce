function [s_table,s_stmml,s_meta,msg] = gceds2eml_table(s,fn,fileurl,entityname,fmt,datefmt,hdropt,flagopt,misschar,terminator,mapunits)
%Generates an Ecological Metadata Language 2.1.1 dataTable tree, STMML tree and corresponding ASCII text file
%from a GCE Data Structure
%
%syntax: [s_table,s_stmml,s_meta,msg] = gceds2eml_table(s,fn,fileurl,entityname,fmt,datefmt,hdropt,flagopt,misschar,terminator,mapunits)
%
%input:
%  s = GCE Data Structure (struct; required)
%  fn = fully-qualified file name for the exported data set (string; optional; default = '' for no export)
%  fileurl = fully-qualified file URL for inclusion in the /dataset/physical/distribution element
%     (string; optional; default = fn converted to URL syntax)
%  entityname = name of the entity (string; optional; default = base filename or 'data' if fn = '')
%  fmt = ASCII export format (string; optional)
%     'csv' = comma-separated value format with quoted text (default)
%     'comma' = comma-spearated value fromat without quoted text
%     'tab' = tab-delimited text without quoted text
%     'space' = space-delimited text without quoted text
%  datefmt = export format for any floating-point serial date/time columns
%     (see datestr; default = 'yyyy-mm-dd HH:MM:SS'; '' for no conversion)
%  hdropt = file header option (see 'exp_ascii'; string; optional)
%     'B' = brief title (5 lines with title, column names, units, variable types) - default
%     'T' = column titles only
%     'N' = none
%  flagopt = flag handling option (see 'exp_ascii'; string; optional; default = 'MD')
%  misschar = string to substitute for missing values in the exported data file
%     (string; optional; default = 'NaN')
%  terminator = line terminator character (string; optional; default = '\r\n' for Windows
%     and '\n' for McIntosh/Linux)
%  mapunits = option to map units to the EML unit dictionary list in EMLUnitDictionary.mat
%     (integer; optional; 0 = no, 1 = yes/default)
%
%output:
%  s_table = structure containing EML content for the dataTable tree
%  s_stmml = structure containing STMML content for describing custom units in additionalMetadata
%  s_meta = metadata structure from listmeta.m (used when called from gceds2eml.m)
%  msg = text of any error message
%
%notes:
%  1) if 'fn' is specified, the generated EML will be save using the same base
%     filename with a .xml extension
%  2) get_studydates.m will be called to determine actual temporal coverage of the data set
%  3) get_metadata_bbox.m will be called to determine the overall bounding box of the data set
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
%last modified: 21-Oct-2014

%init outoupt
s_table = [];
s_stmml = [];
s_meta = [];
msg = '';

%check for required input
if nargin >= 1 && gce_valid(s,'data')
   
   %validate fmt, default to CSV
   if exist('fmt','var') ~= 1 || ~inlist(fmt,'tab,comma,space')
      fmt = 'csv';
   end
   
   %default to yyyy-mm-dd HH:MM:SS if datefmt omitted
   if exist('datefmt','var') ~= 1
      datefmt = 'yyyy-mm-dd HH:MM:SS';
   end
   
   %validate delimited text options, update delimiter token and add quote character
   fmt = lower(fmt);
   if strcmpi(fmt,'tab')
      del = '\t';
      quotechar = '';
   elseif strcmpi(fmt,'comma')
      del = ',';
      quotechar = '';
   else %csv
      del = ',';
      quotechar = '"';
   end
   
   %default to NaN as missing character
   if exist('misschar','var') ~= 1
      misschar = 'NaN';
   elseif isempty(misschar)
      misschar = '';  %force empty character array
   end
   
   %default to standard system line terminator if not specified or unsupported option
   if exist('terminator','var') ~= 1
      terminator = '';
   end
   if isempty(terminator) || ~inlist(terminator,{'\r','\n','\r\n'})
      if ispc
         terminator = '\r\n';
      else
         terminator = '\n';
      end
   end
   
   %default to mapping units
   if exist('mapunits','var') ~= 1 || mapunits ~= 0
      mapunits = 1;
   end
   
   %check for no flags assigned condition
   if sum(~cellfun('isempty',s.flags)) == 0
      noflags = 1;
   else
      noflags = 0;
   end
   
   %default to brief header
   if exist('hdropt','var') ~= 1 || isempty(hdropt)
      hdropt = 'B';
   elseif ~strcmp(hdropt,'T') || ~strcmp(hdropt,'N')
      hdropt = 'B';
   end
   
   %default to empty file url
   if exist('fileurl','var') ~= 1 || isempty(fileurl)
      if ~isempty(fn)
         fileurl = ['file://',strrep(fn,'\','/')];
      else
         fileurl = 'none';
      end
   end
   
   %default to base filename for entityname
   if exist('entityname','var') ~= 1 || isempty(entityname)
      if ~isempty(fn)
         [~,entityname] = fileparts(fn);
      else
         entityname = 'data';
      end
   end
   
   %default to flags for all data/calc columns if omitted
   if exist('flagopt','var') ~= 1 || isempty(flagopt)
      flagopt = 'MD';
   end
   
   %hangle flagged values based on flagopt prior to documenting structure
   switch upper(flagopt)
      case 'D'  %null all flagged values
         s = cullflags(s);
      case 'R'  %delete all rows with flagged values
         s = nullflags(s);
      case 'C'  %combined flag column
         s = flags2cols(s,'single',0,0,1,0);
      case 'M'  %multiple text flag cols next to data cols (only if defined)
         s = flags2cols(s,'mult',0,0,1,0);
      case 'MD' %multiple text flag cols next to data (all data/calc columns)
         s = flags2cols(s,'alldata',0,0,1,0);
      case 'MC' %multiple text flag cols next to data (all columns)
         s = flags2cols(s,'all',0,0,1,0);
      case 'MA' %multiple text flag cols appended at end (only if defined)
         s = flags2cols(s,'mult',0,0,0,0);
         if noflags == 1; flagopt = 'N'; end  %disable flag display
      case 'MAD' %multiple text flag cols appended at end (all data/calc)
         s = flags2cols(s,'alldata',0,0,0,0);
      case 'MAC' %multiple text flag cols appended at end (all columns)
         s = flags2cols(s,'all',0,0,0,0);
      case 'E' %multiple encoded flag cols next to data (only if defined)
         s = flags2cols(s,'mult',0,0,1,1);
         if noflags == 1; flagopt = 'N'; end  %disable flag display
      case 'ED' %multiple encoded flag cols next to data (all data/calc)
         s = flags2cols(s,'alldata',0,0,1,1);
      case 'EC' %multiple encoded flag cols next to data (all data/calc)
         s = flags2cols(s,'all',0,0,1,1);
      case 'EA' %multiple encoded flag cols appended at end (only if defined)
         s = flags2cols(s,'mult',0,0,0,1);
         if noflags == 1; flagopt = 'N'; end  %disable flag display
      case 'EAD' %multiple encoded flag cols appended at end (all data/calc)
         s = flags2cols(s,'alldata',0,0,0,1);
      case 'EAC' %multiple encoded flag cols appended at end (all data/calc)
         s = flags2cols(s,'all',0,0,0,1);
      case 'I' %inline flags
         %no action required
      otherwise  %unsupported option
         %no action required;
   end
   
   %update begin/end dates in metadata prior to any date conversion (for efficiency with numeric dates)
   s_tmp = add_studydates(s);
   if ~isempty(s_tmp)
      s = s_tmp;
   end
   
   %reformat serial dates
   if ~isempty(datefmt)
      Idt = find(strcmp(s.variabletype,'datetime') & (strcmp(s.datatype,'f') | strcmp(s.datatype,'e')));
      if ~isempty(Idt)
         s_tmp = convert_date_format(s,Idt,datefmt);
         if ~isempty(s_tmp)
            s = s_tmp;
         end
      end
   end
   
   %generate ASCII file
   if ~isempty(fn)
      
      %generate ascii file
      [pn,fn_base,fn_ext] = fileparts(fn);
      msg0 = exp_ascii(s,fmt,[fn_base,fn_ext],pn,'',hdropt,flagopt,'FLED','','no',misschar,del,'','Y',terminator);   
      
      %get filesystem listing of generated ASCII file
      d = dir(fn);
      
   else  %no export file
      
      fn_base = 'data';
      fn_ext = '';
      d = struct('bytes',0);  %generate dummy directory structure for file size lookup
      
   end
   
   %check for file export errors
   if ~isempty(d)
            
      %generate documentation metadata structure, including parsed attributes, calculatons and codes
      [~,s_meta] = listmeta(s,'xml');
           
      %generate data format tree
      switch hdropt
         case {'T','ST'}
            headerlines = 1;
         case {'N','SN'}
            headerlines = 0;
         otherwise %B or SB
            headerlines = 5;
      end
      
      %add data table
      s_table.entityName = entityname;
      s_table.entityDescription = ['Main data table from ',s_meta.Dataset.Title];
      
      %generate format tree
      s_format = struct('objectName',[fn_base,fn_ext]);
      s_format.size = {'unit="byte"',int2str(d.bytes)};
      s_format.characterEncoding = 'ASCII';
      s_format.dataFormat.textFormat = struct( ...
         'numHeaderLines',int2str(headerlines), ...
         'numFooterLines','0', ...
         'recordDelimiter',terminator, ...
         'numPhysicalLinesPerRecord','1', ...
         'attributeOrientation','column', ...
         'simpleDelimited',struct('fieldDelimiter',del,'quoteCharacter',quotechar));
      s_format.distribution.online.url = {'function="download"',fileurl};
      
      %add physical element with format info
      s_table.physical = s_format;
      
      %add toolbox info and processing history as dataTable/methods
      info = load('gce_datatools.mat');  %load toolbox info into structure
      s_methods = struct('methodStep','');
      s_methods.methodStep.description.para = 'Data processing using the GCE Data Toolbox for MATLAB';
      s_methods.methodStep.software.title = 'GCE Data Toolbox for MATLAB';
      s_methods.methodStep.software.creator.organizationName = 'Georgia Coastal Ecosystems LTER';
      s_methods.methodStep.software.creator.electronicMailAddress = 'gcelter@uga.edu';
      s_methods.methodStep.software.abstract.para = [ ...
         'The GCE Data Toolbox is a comprehensive library of functions for metadata-based analysis ', ...
         'quality control, transformation and management of ecological data sets. The toolbox is based on the GCE Data ', ...
         'Structure, a MATLAB specification for storing tabular data along with all information required to interpret ', ...
         'the data and generate formatted metadata (documentation). Metadata fields in the structure are queried ', ...
         'by toolbox functions for all operations, allowing functions to process and format values appropriately ', ...
         'based on the type of information they represent. This semantic processing approach supports highly ', ...
         'automated and intelligent data analysis and ensures data set validity throughout all processing steps.'];
      s_methods.methodStep.software.implementation.distribution.online.url = {'function="information"','https://gce-svn.marsci.uga.edu/trac/GCE_Toolbox'};
      s_methods.methodStep.software.version = info.toolboxversion;
      
      %generate processing history elements, add as substeps
      str_hist = listhist(s);
      s_hist = repmat(struct('description',''),1,size(str_hist,1));
      for h = 1:size(str_hist,1)
         s_hist(h).description.para = str_hist(h,:);
      end
      s_methods.methodStep.subStep = s_hist;
      
      %check for calcs
      calcs = s_meta.Data.Calculations;
      if ~isempty(calcs)
         calcs = cellstr(calcs);
         s_substep = repmat(struct('description',''),1,length(calcs));
         for n = 1:length(calcs)
            s_substep(n).description.para = calcs{n};
         end
         s_methods.methodStep(2).description = struct('para','Calculation of derived data columns and unit conversions');
         s_methods.methodStep(2).subStep = s_substep;
      end
      
      %generate default qualityControl paragraph
      s_methods.qualityControl.description.para = [ ...
         'Quality control analysis was performed using the GCE Data Toolbox for MATLAB software. Column data types are ', ...
         'validated upon importing the table into MATLAB, and qualifier flags are automatically generated for data ', ...
         'values based on QA/QC criteria for each data column pre-defined in metadata templates (e.g. value range ', ...
         'checks, sanity checks, pattern checks). Automatically-assigned qualifier flags are reviewed graphically and ', ...
         'revised or augmented as deemed appropriate by GCE information management staff, based on metadata information ', ...
         'from the contributor, values of other measured variables, or statistical tests. Qualifier flags are also ', ...
         'assigned to values that are imputed or derived, revised, or otherwise differ from values in the original data ', ...
         'submission. A column of coded qualifier flags is generated and included in the data table if flags are ', ...
         'assigned to any value in a data column.' ...
         ];
      
      %add anomalies paragraph to qualityControl
      anom = s_meta.Data.Anomalies;
      if ~isempty(anom)
         s_methods.qualityControl.description(2,1).para = ['Data anomalies: ',anom];
      end
      
      %add methods info to dataTable element
      s_table.methods = s_methods;
      
      %call external function to generate attribute metadata structure
      [s_attr,s_stmml] = gceds2eml_attributes(s_meta,misschar,mapunits);
      if ~isempty(s_attr)
         s_table.attributeList = s_attr';
      end
      
      %clean up stmml to remove redundant units
      if ~isempty(s_stmml)
         
         %get index of unique stmml units
         tmp = {s_stmml.stmml__unit};
         unitlist = cell(length(tmp),1);
         for u = 1:length(tmp)
            unitlist{u} = tmp{u}.attrib_id;
         end
         [~,Iunique] = unique(unitlist);
         
         s_stmml = s_stmml(Iunique)';
         
      end
           
   else
      msg = ['an error occurred generating the ASCII file (',msg0,')'];
   end
   
else
   msg = 'a valid GCE Data Structure is required';
end
return