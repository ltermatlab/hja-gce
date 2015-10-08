function taxa = fetch_itis(searchtype,searchtext,parsetaxa,pn)
%Retrieves taxonomic information from ITIS for a scientific name, common name or TSN record
%by querying the Integrate Taxonomic Information System website at http://www.itis.gov/
%
%syntax: taxa = fetch_itis(searchtype,searchtext,parsetaxa,pn)
%
%inputs:
%  searchtype = search type option
%    'tsn' = search on ITIS TSN field
%    'scientific' = search on scientific name
%    'common' = search on common name
%  searchtext = text to search for
%  parsetaxa = option to parse taxonomic information from ITIS report
%    0 = no (i.e. just return TSN for 'add_itis_tsn.m' or other function)
%    1 = yes (default)
%  pn = path for downloading temporary files (default = [gce_homepath,filesep,'search_webcache'])
%
%outputs:
%  taxa = structure returned from 'parse_itis'
%
%(c)2007-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 31-Aug-2012

%init output
taxa = [];

%check for required arguments
if nargin >= 2
   
   %assign default to parsetaxa if omitted
   if exist('parsetaxa','var') ~= 1      
      parsetaxa = 1;
   end
   
   %assign default temp path if omitted
   if exist('pn','var') ~= 1
      pn = '';
   else
      pn = clean_path(pn);
   end
   if ~isdir(pn)
      pn = [gce_homepath,filesep,'search_webcache'];
      if ~isdir(pn)
         pn = pwd;
      end
   end

   %assign search topic based on input
   search_topic = '';
   switch searchtype
      case 'tsn'
         search_topic = 'TSN';
      case 'scientific'
         search_topic = 'Scientific_Name';
      case 'common'
         search_topic = 'Common_Name';
   end

   %catch numeric TSN entries
   if isnumeric(searchtext) && strcmpi(searchtype,'tsn')
      searchtext = num2str(searchtext);
   end

   %url encode spaces in search text
   searchtext = strrep(searchtext,' ','%20');

   %check for valid option
   if ~isempty(search_topic)

      %retrieve TSN before requesting print version unless searchtype = 'tsn'
      tsn = '';
      if ~strcmpi(searchtype,'tsn')
         url = ['http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=',search_topic,'&search_value=', ...
               searchtext,'&search_kingdom=every&search_span=exactly_for&categories=All&source=html&search_credRating=All'];
         [html,status] = urlread(url);
         if ~isempty(html) && status == 1
            tkn = 'Taxonomic Serial No.:';
            Itsn = strfind(html,tkn);
            if ~isempty(Itsn)
               startpos = Itsn(1)+length(tkn)+1;
               tsn = strtok(html(startpos:startpos+30),'<');
            else  %check for list of alternative TSNs, return first TSN with status of accepted
               tkn = '<A HREF="SingleRpt\?search_topic=TSN&search_value=(\d+)".*&ndash; (accepted|valid).*(\/TD)';
               [Istart,Iend] = regexpi(html,tkn);  %use regex to search for TSN URL with status = accepted
               if ~isempty(Istart)
                  tsn = strtok(html(Istart(1)+49:Iend(1)),'"');  %parse first accepted TSN from URL
               end
            end
         end
      else
         tsn = searchtext;
      end

      %check for valid tsn
      if ~isempty(tsn)
         
         if parsetaxa == 1

            %generate url for printable html output
            url = ['http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=', ...
                  tsn,'&search_kingdom=every&search_span=exactly_for&print_version=PRT&source=to_print'];

            %execute url, save html to file
            [fn,status] = urlwrite(url,[pn,filesep,'tmp.htm']);

            if ~isempty(fn) && status == 1
               taxa = parse_itis('tmp.htm',pn);  %parse html
               if ~isempty(taxa)
                  taxa.TSN = fix(str2double(tsn));  %update TSN field
               end
               try
                  delete(fn)  %delete temp file
               catch
                  %fail silently if cannot delete temp file
               end
            end

         else  %TSN only            
            taxa = struct('TSN',str2double(tsn));            
         end

      end

   end

end


function taxa = parse_itis(fn,pn)
%parses html from an ITIS query to return taxonomic information in a structure array
%
%syntax: taxa = parse_itit(fn,pn)

if nargin >= 1

   if nargin == 1
      pn = pwd;
   end

   %init array of fields to parse and add to output structure
   taxanames = {'TSN','TSN'; ...
            'Kingdom','Kingdom'; ...
            'Subkingdom','Subkingdom'; ...
            'Infrakingdom','Infrakingdom'; ...
            'Superphylum','Superphylum'; ...
            'Phylum','Phylum'; ...
            'Subphylum','Subphylum'; ...
            'Infraphylum','Infraphylum'; ...
            'Superdivision','Superdivision'; ...
            'Division','Division'; ...            
            'Subdivision','Subdivision'; ...
            'Infradivision','Infradivision'; ...
            'Superclass','Superclass'; ...
            'Class','Class'; ...
            'Subclass','Subclass'; ...
            'Infraclass','Infraclass'; ...
            'Superorder','Superorder';...
            'Order','Order'; ...
            'Suborder','Suborder';...
            'Infraorder','Infraorder'; ...
            'Superfamily','Superfamily'; ...
            'Family','Family'; ...
            'Subfamily','Subfamily'; ...
            'Tribe','Tribe'; ...
            'Genus','Genus'; ...
            'Subgenus','Subgenus'; ...
            'Species','Species'; ...
            'Subspecies','Subspecies'; ...
            'Variety','Variety'; ...
            'Common Name(s):','CommonName'; ...
            'CurrentStanding:','Standing'};

   %init structure
   taxa = cell2struct(repmat({''},size(taxanames,1),1),taxanames(:,2));
   taxa.Authority = '';  %add authority field

   %convert html to trimmed string array
   ar = textfile2cell(fn,pn,0,0,0,1);

   %extract html table contents
   tblrows = htmltable2cell(ar,0);

   %parse info from table rows
   if ~isempty(tblrows)

      for n = 1:length(tblrows)

         row = tblrows{n};

         %check for 'Direct Children' table row indicating past taxon info
         if isempty(find(strncmpi(row,'Direct Children:',16)))

            %parse taxon fields
            for m = 1:length(row)-1
               I = find(strcmp(taxanames(:,1),row{m}));
               if ~isempty(I)
                  for cnt = 1:length(I)
                     val = row{m+1};  %grab next cell contents
                     fld = taxanames{I(cnt),2};
                     if strcmp(fld,'Species')
                        [tmp,rem] = strtok(val,' ');  %skip genus
                        [val,rem] = strtok(rem,' ');  %get species name
                        [auth,common] = strtok(rem,'-');  %split authority and common name
                        taxa.Authority = trimstr(auth);  %store authority
                        taxa.CommonName = trimstr(common(2:end));  %store common name
                     elseif ~strcmp(fld,'CommonName')
                        val = strtok(val,' ');
                     end
                     taxa.(fld) = trimstr(val);
                  end
               end
            end

         else
            break
         end

      end
   end

end

