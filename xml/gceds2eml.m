function [xml,s_eml,msg] = gceds2eml(s,packageid,fn,fileurl,entityname,fmt,datefmt,hdropt,flagopt,misschar,terminator,mapunits,s_access)
%Generates an Ecological Metadata Language 2.1.1 document and corresponding ASCII text file from a GCE Data Structure
%
%syntax: [xml,s_eml,msg] = gceds2eml(s,packageid,fn,fileurl,entityname,fmt,datefmt,hdropt,flagopt,misschar,terminator,mapunits,s_access)
%
%input:
%  s = GCE Data Structure (struct; required)
%  packageid = ID for the data package (string; optional; default = Dataset/Accession in the metadata)
%  fn = fully-qualified file name for the exported data set ('' for no file export)
%  fileurl = fully-qualified file URL for inclusion in the /dataset/physical/distribution element
%     (string; optional; default = fn)
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
%     and \n for McIntosh/Linux)
%  mapunits = option to map units to the EML unit dictionary list (integer; optional; 
%     0 = no, 1 = yes/default)
%  s_access = access control struct containing EML permissions to assign (struct; optional)
%     default = struct('attrib_authSystem','knb', ...
%                      'attrib_order','allowFirst', ...
%                      'attrib_scope','document', ...
%                      'allow',struct('principal','public','permission','read'));
%
%output:
%  xml = padded character array containing EML metadata file
%  s_eml = structure containing EML content
%  msg = text of any error message
%
%notes:
%  1) if 'fn' is specified, the generated EML will be saved using the same base
%     filename and path with a .xml extension
%  2) get_studydates.m will be called to determine actual temporal coverage of the data set
%  3) get_metadata_bbox.m will be called to determine the overall bounding box of the data set
%  4) if mapunits = 1, units of numeric columns will be matched to names or abbreviations in the
%     EML Unit Dictionary (EMLUnitDictionary.mat), and documented as standard or custom units, resp. 
%     The STMML metadata will automatically be generated for additionalMetadata
%  5) if mapunits = 0, all existing units will be retained and documented as custom units, and 
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
%last modified: 21-Oct-2014

%init outoupt
xml = '';
msg = '';

%check for required input
if nargin >= 1 && gce_valid(s,'data')
   
   %validate packageid
   if exist('packageid','var') ~= 1
      packageid = '';
   end
   
   %validate fmt, default to CSV
   if exist('fmt','var') ~= 1 || ~ischar(fmt) || ~inlist(fmt,'tab,comma,space')
      fmt = 'csv';
   end
   
   %default to yyyy-mm-dd HH:MM:SS if datefmt omitted
   if exist('datefmt','var') ~= 1
      datefmt = 'yyyy-mm-dd HH:MM:SS';
   end
   
   %default to NaN as missing character
   if exist('misschar','var') ~= 1
      misschar = 'NaN';
   end
   if isempty(misschar)
      %force empty character array if empty numeric or string
      misschar = '';
   elseif ~ischar(misschar)
      %convert numeric missing value codes to string
      misschar = num2str(misschar);
   end
   
   %default to standard system line terminator if not specified or unsupported option
   if exist('terminator','var') ~= 1
      terminator = '';
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
         %convert file path to valid url format
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
   
   %call external function to generate file, dataTable and STMML markup
   [s_table,s_stmml,s_meta,msg0] = gceds2eml_table(s,fn,fileurl,entityname, ...
      fmt,datefmt,hdropt,flagopt,misschar,terminator,mapunits);
   
   %check for file export errors
   if ~isempty(s_table)
            
      %init outer EML structure
      s_eml = struct('access','', ...
         'dataset','');
      
      %generate default access element if required
      if exist('s_access','var') ~= 1 || ~isstruct(s_access) || ~isfield(s_access,'attrib_authSystem')
         s_access = struct('attrib_authSystem','knb', ...
            'attrib_order','allowFirst', ...
            'attrib_scope','document', ...
            'allow',struct('principal','public','permission','read'));
      end
      
      %generate creator element
      s_creator = sub_personnel([s_meta.Dataset.Investigator.ContactInformation]);
      
      %generate associatedParty elements
      if ~isempty(s_meta.Study.Personnel)
         s_associated = sub_personnel([s_meta.Study.Personnel.Person],'co-author');
      else
         s_associated = [];
      end
      
      %generate contact elements
      if ~isempty(s_meta.Status.Contact)
         s_contact = sub_personnel([s_meta.Status.Contact.ContactInformation]);
      else
         s_contact = [];
      end
      
      %generate project leader elements
      if ~isempty(s_meta.Project.Leaders)
         s_projectleaders = sub_personnel([s_meta.Project.Leaders.ContactInformation],'project leader');
      else
         s_projectleaders = [];
      end
      
      %build top-level dataset struct
      s_dataset = struct('title',s_meta.Dataset.Title);
      s_dataset.creator = s_creator;
      s_dataset.associatedParty = s_associated;
      s_dataset.pubDate = datestr(now,10);  %add current year
      s_dataset.abstract = struct('para',s_meta.Dataset.Abstract);
      
      %check for no keywords, add 1 to prevent errors
      if isempty(s_meta.Dataset.Keywords)
         s_meta.Dataset.Keywords.Keyword = 'data';
      end
      s_dataset.keywordSet = struct('keyword',{s_meta.Dataset.Keywords.Keyword})';
      
      s_dataset.intellectualRights = struct('para',s_meta.Status.Restrictions);
      
      %add geographic coverage
      [wboundlon,eboundlon,sboundlat,nboundlat] = get_metadata_bbox(s);
      if ~isempty(wboundlon) && ~isnan(wboundlon)
         s_dataset.coverage.geographicCoverage.geographicDescription = 'Overall bounding box describing the study region';
         s_dataset.coverage.geographicCoverage.boundingCoordinates.westBoundingCoordinate = sprintf('%0.6f',wboundlon);
         s_dataset.coverage.geographicCoverage.boundingCoordinates.eastBoundingCoordinate = sprintf('%0.6f',eboundlon);
         s_dataset.coverage.geographicCoverage.boundingCoordinates.northBoundingCoordinate = sprintf('%0.6f',nboundlat);
         s_dataset.coverage.geographicCoverage.boundingCoordinates.southBoundingCoordinate = sprintf('%0.6f',sboundlat);
      end
      
      %look up temporal coverage from metadata
      begindate = lookupmeta(s,'Study','BeginDate');
      enddate = lookupmeta(s,'Study','EndDate');
      
      %calculate numeric dates
      try
         dt_min = datenum(begindate);
         dt_max = datenum(enddate);
      catch
         dt_min = NaN;
         dt_max = NaN;
      end
      
      %generate dataset/coverage/temporalCoverage in ISO format
      if ~isnan(dt_min) && ~isnan(dt_max)
         s_dataset.coverage.temporalCoverage.rangeOfDates.beginDate.calendarDate = datestr(dt_min,29);
         s_dataset.coverage.temporalCoverage.rangeOfDates.endDate.calendarDate = datestr(dt_max,29);
      end
      
      %generate dataset/coverage/taxonomicCoverage
      if isfield(s_meta.Study,'Species') && ~isempty(s_meta.Study.Species)
         s_taxa = struct('taxonomicClassification',struct('taxonRankName','','taxonRankValue','','commonName',''));
         taxa = {s_meta.Study.Species.Taxa};
         for n = 1:length(taxa)
            ar = splitstr(strrep(taxa{n},')',''),'(');
            str_spp = '';
            str_common = '';
            if length(ar) >= 1
               str_spp = ar{1};
            end
            if length(ar) >= 2
               str_common = ar{2};
            end            
            s_taxa.taxonomicClassification(n).taxonRankName = 'Species';
            s_taxa.taxonomicClassification(n).taxonRankValue = str_spp;
            s_taxa.taxonomicClassification(n).commonName = str_common;
         end
         s_dataset.coverage.taxonomicCoverage = s_taxa;
      end
      
      %add contact
      s_dataset.contact = s_contact;
      
      %add publisher
      s_dataset.publisher.organizationName = s_meta.Project.Name;
      
      %add methods
      methods = [s_meta.Study.Methods.Method];
      for n = 1:length(methods)
         s_dataset.methods.methodStep(n).description.section.para = methods(n).Description;
         s_dataset.methods.methodStep(n).instrumentation = methods(n).Instrumentation;
      end
      
      %add sampling temporal coverage
      if ~isnan(dt_min) && ~isnan(dt_max)
         s_dataset.methods.sampling.studyExtent.coverage(1).temporalCoverage.rangeOfDates.beginDate.calendarDate = datestr(dt_min,29);
         s_dataset.methods.sampling.studyExtent.coverage(1).temporalCoverage.rangeOfDates.endDate.calendarDate = datestr(dt_max,29);
      end
      
      %add sampling geographic coverage
      sites = [s_meta.Site.Location];
      if ~isempty(sites)
         s_tmp = repmat(struct('geographicDescription','','boundingCoordinates',''),1,length(sites));
         for n = 1:length(sites)
            s_tmp(n).geographicDescription = sites(n).LocationName;
            wbound = [];
            ebound = [];
            nbound = [];
            sbound = [];
            if isfield(sites(n).Coordinates,'BoundingBox') && isfield(sites(n).Coordinates.BoundingBox,'NorthWest') 
               ar = splitstr(sites(n).Coordinates.BoundingBox.NorthWest,',');
               wbound = ar{1};
               nbound = ar{2};
               ar = splitstr(sites(n).Coordinates.BoundingBox.SouthEast,',');
               ebound = ar{1};
               sbound = ar{2};
            elseif isfield(sites(n).Coordinates,'Point') && ~isempty(sites(n).Coordinates.Point)
               ar = splitstr(sites(n).Coordinates.Point,',');
               wbound = ar{1};
               ebound = ar{1};
               nbound = ar{2};
               sbound = ar{2};
            end
            if ~isempty(wbound)
               s_tmp(n).boundingCoordinates.westBoundingCoordinate = wbound;
               s_tmp(n).boundingCoordinates.eastBoundingCoordinate = ebound;
               s_tmp(n).boundingCoordinates.northBoundingCoordinate = nbound;
               s_tmp(n).boundingCoordinates.southBoundingCoordinate = sbound;
            end
         end
         s_dataset.methods.sampling.studyExtent.coverage(2).geographicCoverage = s_tmp;
      end
      
      %get study descriptors
      studydesign = {s_meta.Study.Description.StudyElement.Design};
      studysampling = s_meta.Study.Description.StudyElement.Sampling;
      studyplots = s_meta.Study.Description.StudyElement.Plots;
      
      %init sampling paragraph counter
      n_sampling = 0;

      %add study descriptors, checking for multiple samplingDescription sections
      if ~isempty(studydesign)
         for cnt = 1:length(studydesign)
            s_dataset.methods.sampling.samplingDescription.section(cnt,1).para = char(studydesign{cnt});
            n_sampling = n_sampling + 1;
         end
      end      
      
      %add sampling
      if ~isempty(studysampling) && ~strcmpi(studysampling,'none') && ~strcmpi(studysampling,'null')
         s_dataset.methods.sampling.samplingDescription.section(n_sampling,1).para = studysampling;
         n_sampling = n_sampling + 1;
      end
      
      %add plots
      if ~isempty(studyplots) && ~strcmpi(studyplots,'none') && ~strcmpi(studyplots,'null')
         s_dataset.methods.sampling.samplingDescription.section(n_sampling,1).para = studyplots;
      end
      
      %add project description
      if ~isempty(s_meta.Project.Name)
         s_dataset.project.title = s_meta.Project.Name;
         s_dataset.project.personnel = s_projectleaders;
         if ~isempty(s_meta.Project.Abstract)
            s_dataset.project.abstract.para = s_meta.Project.Abstract;
         end
         if ~isempty(s_meta.Project.Funding)
            s_dataset.project.funding.para = s_meta.Project.Funding;
         end
      end      
      
      %add datatable to dataset
      s_dataset.dataTable = s_table;
      
      %package EML
      s_eml.access = s_access;
      s_eml.dataset = s_dataset;      
      
      %generate main doc without root element
      xml_doc = struct2xml_attrib(s_eml,'',0,100,3,3,'');
      
      %generate additionalMetadata
      if ~isempty(s_stmml)
         
         %generate xml for stmml
         xml_stmml = struct2xml_attrib(s_stmml,'',0,100,3,12,'');
         
         %generate additional metadata elements
         xml_additional = char('   <additionalMetadata>', ...
            '      <metadata>', ...
            '         <stmml:unitList xsi:schemaLocation="http://www.xml-cml.org/schema/stmml-1.1 http://gce-lter.marsci.uga.edu/public/files/schemas/eml-210/stmml.xsd">', ...
            xml_stmml, ...
            '         </stmml:unitList>', ...
            '      </metadata>', ...
            '   </additionalMetadata>');
         
      else
         xml_additional = '';
      end
      
      %generate root-level attributes
      if isempty(packageid)
         packageid = s_meta.Dataset.Accession;
      end
      attr = ['packageId="',packageid,'" ', ...
         'system="gce-lter" ', ...
         'xmlns:ds="eml://ecoinformatics.org/dataset-2.1.0" ', ...
         'xmlns:eml="eml://ecoinformatics.org/eml-2.1.0" ', ...
         'xmlns:stmml="http://www.xml-cml.org/schema/stmml-1.1" ', ...
         'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ', ...
         'xsi:schemaLocation="eml://ecoinformatics.org/eml-2.1.0 http://gce-lter.marsci.uga.edu/public/files/schemas/eml-210/eml.xsd"'];
      
      %generate complete doc
      xml = char(['<eml:eml ',attr,'>'], ...
         xml_doc, ...
         xml_additional, ...
         '</eml:eml>');
      
      %write eml
      if ~isempty(fn) && exist(fn,'file') == 2
         [pn,fn_base] = fileparts(fn);
         xml2file(xml,'','',[fn_base,'.xml'],pn);
      end
      
   else
      msg = ['an error occurred generating the ASCII file (',msg0,')'];
   end
   
else
   msg = 'a valid GCE Data Structure is required';
end
return


%subfunction for generating EML personnel structure
function s_xml = sub_personnel(pers,role)
%pers = personnel contact info struct optionally containing fields:
%  'Name'
%  'Organization'
%  'Position'
%  'Address'
%  'City'
%  'State'
%  'PostalCode
%  'Phone'
%  'ElectronicMail'
%  'UserID'
%role = person role (default = '')
%
%note: one of Name, Position or Organization is required or s_xml will be empty

%init output
s_xml = [];

%set default role
if exist('role','var') ~= 1
   role = '';
end

%check for a required name/position/org field
if isstruct(pers) && (isfield(pers,'Name') || isfield(pers,'Position') || isfield(pers,'Organization'))
   
   %dimension struct for names
   s_xml = repmat(struct('individualName',''),1,length(pers));
   
   for n = 1:length(pers)      
      
      %normalize name and parse into surname, givenname
      if isfield(pers,'Name') && ~isempty(pers(n).Name)
         
         %convert commas to spaces
         str = strrep(pers(n).Name,',',' '); 
         
         %parse name elements
         ar = splitstr(str,' ');
         if inlist(ar(end),{'Jr.','II','III','IV','Sr.'})
            givenname = char(concatcellcols(ar(setdiff(1:length(ar),length(ar)-1))',' '));
            surname = ar{end-1};
         else
            givenname = char(concatcellcols(ar(1:end-1)',' '));
            surname = ar{end};
         end
         
         %add elements
         s_xml(n).individualName.givenName = givenname;
         s_xml(n).individualName.surName = surname;
      
      end
      
      %check for org
      if isfield(pers(n),'Organization')
         s_xml(n).organizationName = pers(n).Organization;
      end
      
      %check for position
      if isfield(pers(n),'Position')
         s_xml(n).positionName = pers(n).Position;
      end
      
      %check for address
      if isfield(pers(n),'Address')
         s_xml(n).address.deliveryPoint = pers(n).Address;
      end
      
      %check for city
      if isfield(pers(n),'City')
         s_xml(n).address.city = pers(n).City;
      end
      
      %check for state
      if isfield(pers(n),'State')
         s_xml(n).address.administrativeArea = pers(n).State;
      end
      
      %check for zip
      if isfield(pers(n),'PostalCode')
         s_xml(n).address.postalCode = pers(n).PostalCode;
      end
      
      %check for phone
      if isfield(pers(n),'Phone')
         s_xml(n).phone = pers(n).Phone;
      end
      
      %check for email
      if isfield(pers(n),'ElectronicMail')
         s_xml(n).electronicMailAddress = pers(n).ElectronicMail;
      end
      
      %check for role
      if ~isempty(role)
         s_xml(n).role = role;
      end
      
   end
   
end
return
