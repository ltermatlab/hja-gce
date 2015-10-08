function [s2,msg] = parse_cruise_log(s,castcol,logfile,logfields,template,overwrite,pos)
%Parses information for a specified cast in a cruise log file to supplement information in a CTD data set
%
%syntax: [s2,msg] = parse_cruise_log(s,castcol,logfile,logfields,template,pos)
%
%input:
%  s = CTD data set to augment (GCE Data Structure)
%  castcol = name or position of column to use for looking up cast files that match 'CastFile' in the log
%  logfile = fully-qualified filename of the text log file to parse (default = '[Cruise]_log.txt' in the current directory,
%    based on 'Cruise' variable in dataset)
%      format: tab or comma-delimited text file with the following default header fields and column data types
%         CastFile    (string) -- required field
%         Station     (string)
%         Latitude    (floating-point; decimal degrees)
%         Longitude   (floating-point; decimal degrees)
%         Transect    (string; GCE-AL, GCE-SP, GCE-DB, GCE-DP, GCE-IC, GCE-IM)
%         Tide        (string; LW, Ebb, HW, Fld, NR for low water, ebb, high water, flood, not recorded, resp.)
%         SeaState    (string; VC, C, M, R, VR for very calm, calm, moderate, rough, very rough, resp.)
%         Depth_Total (numeric; meters)
%         SurveyName  (string; e.g. Altamaha HW)
%         Survey      (integer; ordinal number)
%         Cast        (integer; ordinal number)
%  logfields = cell array of fields to parse from the log file
%     default = {'Station','Latitude','Longitude','Transect','Tide','SeaState','Depth_Total','SurveyName','Survey','Cast'}
%  template = metadata template to apply to log file (default = 'SeaBird_CTD')
%  overwrite = option to overwrite any existing log file fields in the data set
%     0 = no
%     1 = yes (default)
%  pos = column position to insert log fields before (default = 0 for beginning of data set)
%
%output
%  s2 = updated CTD data set
%  msg = error message
%
%(c)2002-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 20-Feb-2013

s2 = [];
msg = '';

if nargin >= 1
   
   if gce_valid(s,'data')
      
      %supply defaults for omitted parameters
      if exist('overwrite','var') ~= 1
         overwrite = 1;
      end
      
      %supply default logfile if omitted
      if exist('logfile','var') ~= 1
         logfile = '';
      end
      if isempty(logfile)
         Icruise = name2col(s,'Cruise','s');
         if ~isempty(Icruise)
            cruise = extract(s,Icruise,1);
            logfile = [pwd,filesep,char(cruise),'_log.txt'];
         end
      end
      
      if exist('logfields','var') ~= 1
         logfields = [];
      end
      if ~iscell(logfields)  %use default list of all fields
         logfields = {'Station','Latitude','Longitude','Transect','Tide','SeaState','Depth_Total','SurveyName','Survey','Cast'};
      end
      
      %remove existing logfields from data or skip existing fields
      if overwrite == 1  %remove existing data columns
         s = deletecols(s,logfields);
      else  %skip existing data columns by removing logfields from list
         for n = 1:length(logfields)
            c = name2col(s,logfields{n});
            if ~isempty(c)
               logfields{n} = '';
            end
         end
         logfields = logfields(~cellfun('isempty',logfields));
      end
      
      if exist('castcol','var') ~= 1
         castcol = 'CastFile';
      end
      if ~isnumeric(castcol)
         castcol = name2col(s,castcol,0,'s');
      end
      
      if exist('template','var') ~= 1
         template = 'SeaBird_CTD_Minicruise';
      end
      
      if exist('pos','var') ~= 1
         pos = 0;
      end

      %extract cast
      cast = '';
      if ~isempty(castcol)
         castval = extract(s,castcol,1);
         if iscell(castval)
            cast = char(castval);
         end
      end

      %load logfile, add supplementary info fields
      if ~isempty(logfields) && ~isempty(cast) && exist(logfile,'file') == 2
         
         %parse path and filename from fully-qualified filename
         [pn,fn_base,fn_ext] = fileparts(logfile);
         fn = [fn_base,fn_ext];
         if isempty(pn)
            pn = pwd;
         end
         
         %load log file as data structure (using automatic parsing of 1-line header and log data)
         [s_log,msg0] = imp_ascii(fn,pn,'CTD Log',template);
         
         if ~isempty(s_log)
            
            %search for cast in logfile data set
            str_query = ['strcmpi(Filename,''',cast,''')'];
            [s_log,rows] = querydata(s_log,str_query);
            
            if ~isempty(s_log) && rows == 1
               
               %init output structure
               s2 = s;
               
               %init bad column array
               badcols = [];
               
               %create history entry for log parsing
               str = ['parsed information from cruise log ''',fn,''' for cast ',cast, ...
                     ' to augment the CTD data set (''parse_cruise_log'')'];
               s2.history = [s2.history ; {datestr(now)},{str}];
               
               %loop through log fields
               for n = length(logfields):-1:1
                  
                  col = name2col(s_log,logfields{n});  %look up index position of column to add
                  
                  %extract values and metadata, add to CTD data set (replicating scalar values)
                  if ~isempty(col)
                     vals = extract(s_log,col);
                     if iscell(vals)
                        vals = trimstr(vals);  %remove and leading or trailing blanks from text fields
                     end
                     if strcmpi(logfields{n},'Depth_Total')  %check for missing total depth
                        if isnumeric(vals) && isnan(vals)
                           s_tmp2 = querydata(s2,str_query);
                           if ~isempty(s_tmp2)
                              dep = extract(s_tmp2,'Depth');
                              if ~isempty(dep)
                                 vals = max(dep(~isnan(dep))) + .1;  %add max measured depth + 0.1m
                              end
                           end
                        end
                     end
                     colname = s_log.name{col};
                     units = s_log.units{col};
                     desc = s_log.description{col};
                     dtype = s_log.datatype{col};
                     vtype = s_log.variabletype{col};
                     ntype = s_log.numbertype{col};
                     prec = s_log.precision(col);
                     crit = s_log.criteria{col};
                     [s_temp,msg] = addcol(s2,vals,colname,units,desc,dtype,vtype,ntype,prec,crit,pos);
                     if ~isempty(s_temp)
                        s2 = s_temp;  %copy temp structure to output if addition successful
                     else
                        clear s_temp
                        badcols = [badcols,logfields(n)];
                     end
                  end
                  
               end
               
               %extract survey name, add to title and abstract if present
               survey = extract(s_log,'SurveyName');               
               
               if ~isempty(survey)
               
                  %update title
                  surveytext = [' ',survey{1},' survey'];
                  titlestr = s2.title;
                  titlestr = [titlestr,surveytext];  %add survey name to title
                  
                  %update abstract
                  abstract = lookupmeta(s,'Dataset','Abstract');
                  Ipos = strfind(abstract,' cruise.');  %get position of cruise description
                  if ~isempty(Ipos)
                     abstract = [abstract(1:Ipos+6),surveytext,abstract(Ipos+7:end)];  %add survey name to abstract after cruise desc
                  end

                  %check for missing transect - parse from survey name
                  transect = extract(s_log,'Transect');
                  if isempty(transect)
                     str = strtok(char(survey),' ');
                     switch str
                        case 'Altamaha'
                           transect = 'GCE-AL';
                        case 'Sapelo'
                           transect = 'GCE-SP';
                        case 'Duplin'
                           transect = 'GCE-DP';
                        case 'Doboy'
                           transect = 'GCE-DB';
                        case 'Inner Marsh'
                           transect = 'GCE-IM';
                        case 'Intracoastal'
                           transect = 'GCE-IC';
                        otherwise
                           transect = '';
                     end
                     if ~isempty(transect)
                        Icol = name2col(s2,'Tide');
                        if isempty(Icol)
                           Icol = name2col(s2,'SurveyName');
                        end
                        crit = 'flag_notinlist(x,''GCE-SP,GCE-IC,GCE-DB,GCE-DP,GCE-IM,GCE-AL'')=''Q''';
                        s_temp = addcol(s2,transect,'Transect','none','GCE cruise transect','s','code','none',0,crit,Icol);
                        if ~isempty(s2)
                           s2 = s_temp;
                        end
                     end   
                  end
                  
                  %update title, abstract
                  s2 = newtitle(s2,titlestr);
                  s2 = addmeta(s2,{'Dataset','Abstract',abstract},0,'parse_cruise_log');
                  
               end
               
               %generate missing log field error message
               if ~isempty(badcols)
                  msg = ['the following fields were not present in the log file: ',cell2commas(badcols,1)];
               end

            else
               msg = ['no entry for ',cast,' was found in the log file ',logfile];
            end
            
         else
            msg = ['an error occurred loading the log file: ',msg0];
         end
         
      else
         if isempty(logfields)
            msg = 'all log fields already exist in the data structure';
         else
            msg = 'log file not found or is invalid';
         end
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient input arguments for function';
end