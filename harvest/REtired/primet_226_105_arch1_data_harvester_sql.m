function [msg,status] = primet_226_105_arch1_data_harvester_sql(source,template,sitecode,profile,pn_dest,pn_plots,html,email,fn_dest)
%Data harvester function template for post-processing streaming sensor data retrieved from an SQL data source
%
%syntax: [msg,status] = data_harvester_sql(source,template,sitecode,profile,pn_dest,pn_plots,html,email,fn_dest)
%
%input:
%   source = data source (m-file function that accepts a 'template' argument and returns a 
%      GCE Data Structure and error message as output by running sql2gceds.m or equivalent)
%   template = metadata template to apply (string - optional; default = '')
%   sitecode = site code value to add to data set (string - optional; default = '' for none)
%   profile = profile identifier in harvest_info.m and harvest_plot_info.m to use
%      for generating data indices and plot pages (string - optional; default = 'demo')
%   pn_dest = local file system or network path for saving processed data files, containing a
%      'data' subdirectory (string - optional; default = 'data' subdirectory in current directory)
%   pn_plots = path name for plots (string - optional; default = '' for no plots)
%   html = option to render data and plot index files in HTML format (i.e. runs XSL transforms on XML)
%      0 = no
%      1 = yes (default)
%   email = email address or array of addresses to send post-harvest error 
%       reports to (string or cell array of strings - optional; default = '' for none)
%   fn_dest = processed data filename (string - optional; default = fn_source with .mat extension)
%
%output:
%   msg = status message
%   status = numeric status code (1 = success, 0 = error)
%
%notes:
%   1) this is a starter template for creating data harvesting workflows in the 
%      GCE Data Toolbox for MATLAB
%   2) after editing the template, rename the function from "data_harvester" to something
%      application-specific (e.g. 'harvest_campbell_met') by revising the header and saving
%      the m-file using the new function name with .m extension (e.g. 'harvest_campbell_met.m')
%   3) to run the new harvest workflow, type the function name with appropriate arguments from
%      the MATLAB command line or by including the function call in 'harvest_timers.mat' and 
%      and starting harvests by calling 'start_harvesters.m')
%   4) import filter and plot variables are based on sample data file 'sample_data_toa5.dat';
%      edit these sections to match your data format, template and column names
%
%by Wade Sheldon <sheldon@uga.edu>, GCE-LTER Project, University of Georgia
%
%last updated: 31-Jul-2013

%init output
status = 0;

%check for required arguments
if nargin >= 1
   
   %validate source
   if exist(source,'file') == 2
      
      %
      %validate input and supply defaults for omitted arguments
      %
      
      %check for sitecode argument
      if exist('sitecode','var') ~= 1
         sitecode = '';  %no site code
      end
      
      %check for template argument
      if exist('template','var') ~= 1
         template = '';  %blank template
      end
      
      %check for profile argument
      if exist('profile','var') ~= 1
         profile = '';
      end
      if isempty(profile)
         profile = 'demo';
      end
      
      %check for html argument
      if exist('html','var') ~= 1 || html ~= 0
         html = 1;
      end         
      
      %check for email
      if exist('email','var') ~= 1
         email = '';
      elseif ~isempty(email) && ischar(email)
         email = cellstr(email);  %convert to cell array
      end
      
      %validate destination path
      if exist('pn_dest','var') ~= 1
         pn_dest = '';
      end
      if isempty(pn_dest) || ~isdir(pn_dest)
         pn_dest = pwd;  %use working directory
      else
         pn_dest = clean_path(pn_dest);  %remove terminal path separator
      end
      
      %check for data subdirectory, create if not present
      if ~isdir([pn_dest,filesep,'data'])
         if strcmp([filesep,'data'],pn_dest(length(pn_dest)-4:end))
            %remove data subdirectory from pn_dest
            pn_dest = pn_dest(1:end-5);
         else
            %create data subdirectory
            status = mkdir(pn_dest,'data');
         end
      end
      
      %generate data path from pn_dest
      pn_data = [pn_dest,filesep,'data'];
      
      %check for destination file
      if exist('fn_dest','var') ~= 1
         [~,mfile] = fileparts(source);
         fn_dest = [mfile,'.mat'];  %append .mat suffix to source name
      end
      
      %validate plot path, check for 'plots' subdirectory and add if not present
      if exist('pn_plots','var') ~= 1
         pn_plots = '';
      elseif ~isdir(pn_plots)
         pn_plots = '';
      else
         pn_plots = clean_path(pn_plots);  %remove terminal path separator
         if ~strcmp([filesep,'plots'],pn_plots(length(pn_plots)-5:end))
            if ~isdir([pn_plots,filesep,'plots'])
               status = mkdir(pn_plots,'plots');
            end
            pn_plots = [pn_plots,filesep,'plots'];
         end
      end
      
      %
      %code for importing the source data - revise the import filter and syntax to suit data
      %
      
      %Example: imports CSI TOA5 data using specified template, calculating a serial date and
      %assigning the 'PST' timezone to date/time columns; note that QA/QC flags will be
      %assigned automatically based on criteria in the template
      % Add you import filter, in this case its sql2gceds() from LNDB
      
      %get data from database
      try
         [data,msg] = feval(source,template);
      catch e
         data = [];
         msg = ['an error occurred connecting to source ''',source,''' (',e.message,')'];
      end
      
      %check for valid data structure from import filter
      if gce_valid(data)
          
         %
         %code for basic data manipulation goes here
         %
         
         %check for optional sitecode, add to beginning of data set and document in metadata
         if ~isempty(sitecode)
            
            data = addcol( ...
               data, ...        %date structure to update
               sitecode, ...    %site code to add (will be replicated to all rows)
               'Site', ...      %column name to assign
               '', ...          %column units
               'Site code', ... %column description
               's', ...         %data type
               'nominal', ...   %variable type
               'none', ...      %numeric type
               0, ...           %numeric precision
               '', ...          %Q/C flagging criteria
               1 ...            %column position in data set
               );
            
            %update site metadata by looking up site in geo_polygons.mat
            data = add_sitemetadata( ...
               data, ...    %data structure to update
               'Site', ...  %site/location column name to match
               '', ...      %site prefix to add
               1 ...        %auto-polygons option for looking up polygons for matched points
               );            
            
         end
         
         %Perform conversions here
         if ~isempty(data)
             %add tipping buucket in inches column if PPT_TB_TOT_CNT is present
             tippingbucket = name2col(data,'PPT_TB_TOT_CNT');
             if ~isempty(tippingbucket)
                 pos = tippingbucket + 1;
                 data = add_calcexpr(data,'(PPT_TB_TOT_CNT .* 0.01)','PPT_TB_TOT','in', ...
                     'Precipitation calculated from the tipping bucket rain gauge)', ...
                     pos,0,'x<0=''I'';x>20=''Q''');
                 if ~isempty(data)
                     %override data type, numeric type in case data values generate integer types automatically
                     pos = name2col(data,'PPT_TB_TOT');
                     if ~isempty(pos)
                         data.datatype{pos} = 'f';
                         data.numbertype{pos} = 'continuous';
                     end
                 end
             end
             
             [data,msg] = unit_convert(data,'PPT_TB_TOT','mm');
             
             %delete uncorrected columns from primet table
             [data,msg] = deletecols(data,{'PPT_TB_TOT_CNT'});
            
             if ~isempty(data)
                 
                 s = gceds2struct(data);  %convert to scalar struct with data and flag arrays as fields ...
                 
                 pos = name2col(data,'SNODEP_INST');
                 if ~isempty(pos)
                     md = running_median(s.SNODEP_INST,12,1,'back'); %compute running median of SNODEP_INST
                     
                     % add new column for corrected sub wind dir
                     [data,msg] = addcol( ...
                         data, ...                                           % original data structure (required)
                         md, ...                                             % an array of calculated values (required)
                         'SNODEP_MED', ...                                   % the name of the new column (required)
                         'mm', ...                                           % the units string for the new column (required)
                         '12 point running median of SNODEP_INST', ...       % the description for the new column (optional - default = name)
                         'f', ...                                            % the data type of the new column (optional - default = 'f' or 's')
                         'data', ...                                         % the variable type of the new column (optional - default = 'calculation')
                         'continuous', ...                                   % the numerical type of the new column (optional)
                         2, ...                                              % the number of decimal places to use for text output
                         'x>4500=''I'';x>4000=''Q'';flag_percentchange(x,25,25,3,2)=''I''', ...                      % the flagging criteria for the new column (optional - default = '')
                         pos+1 ...                                           % the column position (1 = beginning, [] = last)
                         );
                 end
             end
            
            
            
                
%                 col = name2col(data,'SNODEP_INST');
%                 %convert SNODEP_INST from m to mm
%                 if ~isempty(col)
%                     [data,msg] = unit_convert(data,'SNODEP_INST','mm','x*1000');
%                 end
                
%                 col = name2col(data,'TB_PRECIP_TOT');
%                 %convert TB_PRECIP_TOT from tip to mm
%                 if ~isempty(col)
%                     [data,msg] = unit_convert(data,'TB_PRECIP_TOT','mm','x*0.00254');
%                 end
                
         end
         
         if ~isempty(data)
             
             %check new records for duplicate records
             [data,msg] = cleardupes( ...
                 data, ...                   %data structure
                 {'Date'}, ...               %{data.name{2}}, ...        %date column
                 'verbose' ...               %logging option
                 );
         end
         
         if ~isempty(data)
                %document anomalies (missing values and flags from QA/QC rules)
                [data,msg] = add_anomalies( ...
                    data, ...   %data structure to update
                    23, ...     %date format (see 'help datestr')
                    '-', ...    %date range separator
                    1, ...      %option to document missing values
                    [] ...      %column selection ([] = all)
                    );
         end
            
         if ~isempty(data)
                [data,msg] = pad_date_gaps( ...
                    data, ...  %data structure to update
                    [], ...    %date column ([] = auto)
                    1, ...     %remove duplicates option (1 = yes)
                    1 ...      %replicate non-data values option (1 = yes)
                    );
         end
         
         if ~isempty(data)
                    %master list of columns to interpolate
                    interpcols = {'AIR_150_AVG','AIR_250_AVG','AIR_350_AVG','AIR_450_AVG', ...
                        'AIR_150A_AVG','AIR_250A_AVG','AIR_350A_AVG','AIR_450A_AVG', ...
                        'SOIL_100_AVG','SOIL_10_AVG','SOIL_20_AVG','SOIL_50_AVG', ...
                        'RH_150_AVG','RH_450_AVG','PPT_SA_INST','PPT_SH_INST','SNODEP_INST','SWE_INST','SOLAR_AVG', ...
                        'WCR_100_AVG','WCR_10_AVG','WCR_20_AVG','WCR_50_AVG'};
                    
                    %check for columns in active data structure, case-insensitively,
                    %constraining to floating-point data columns
                    cols = name2col(data,interpcols,0,'f','data');
                    
                    %interpolate any matched columns
                    if ~isempty(cols)
                        [data,msg] = interp_missing(data, ...
                            'Date', ...
                            cols,...
                            'linear', ...
                            5, ...
                            inf ...
                            );
                        
                    end
         end
         
         col = name2col(data,'Date');
         if ~isempty(col)
             data = copycol(data,'Date','DateString'); %create a copy of the Date column
             data = convert_date_format(data,'DateString',31); %convert the copied dates to yyyy-mm-dd HH:MM:SS
         end

         %append data to existing file, if present, updating the title to include the overall date range
         if exist([pn_data,filesep,fn_dest],'file') == 2
         
            %append data - returning merged data structure
            [data,msg0] = append_data( ...
               data, ...                         %new data to append
               [pn_data,filesep,fn_dest], ...    %existing file to append to
               'data', ...                       %data structure variable name
               'date_append', ...                %merge option (append new records)
               'new_date', ...                   %title option (use title in data, but update dates)
               0, ...                            %fixflags option (do not lock)
               0 ...                             %save option (do not save - save handled later)
               );      
            
            %generate warning message if necessary
            if ~isempty(msg0)
               data = [];
               if isempty(msg)
                  msg = ['a warning occurred appending the data (',msg0,')'];
               else
                  msg = [msg,'; a warning occurred appending the data (',msg0,')'];
               end
            end
            
         end
         
         if ~isempty(data)
                %check new records for duplicate records
                [data,msg] = cleardupes( ...
                    data, ...                  %data structure
                    {'Date'}, ...              %date column
                    'verbose' ...              %logging option
                    );
         end
         
         if ~isempty(data)
                %check new records for duplicate records
                [data,msg] = nullflags( ...
                    data, ...                       %data
                    'I', ...                      %flagchars
                    [], ...                         %cols
                    1, ...                          %metaopt
                    0, ...                          %clearflags
                    '', ...                         %newflag
                    0 ...                           %logsize
                    );
         end
            
         %
            %code for saving data file and generating export formats goes here
            %
            
            if ~isempty(data)
                
                %save .mat file to destination
                save([pn_data,filesep,fn_dest],'data')
                
                %generate name for csv file
                [~,fn_base] = fileparts(fn_dest);
                fn_csv = [fn_base,'.csv'];
                
                %export .csv file with separate metadata in FLED style with q/c flag columns for all
                %data/calc columns (see 'help exp_ascii' for all options)
                exp_ascii( ...
                    data, ...     %data structure to export
                    'csv', ...    %file format to export
                    fn_csv, ...   %filename for CSV file
                    pn_data, ...  %file path for CSV file
                    '', ...       %title string ('' = use data set title)
                    'SB', ...     %header format ('SB' = brief header with separate metadata file -meta.txt)
                    'MD', ...     %flag display format ('MD' = flag columns for all data/calc columns)
                    'FLED' ...    %metadata style
                    );
                
                %generate name for html file
                fn_html = [pn_data,filesep,fn_base,'-data.html'];
                
                %export -data.html file for previewing the data
                gceds2html( ...
                    copyrows(sortdata(data,'Date',-1),(1:960)), ...        %data structure to export
                    [], ...                          %column list (default = all)
                    [], ...                          %headings (default = column names)
                    'column', ...                    %orientation (column or row)
                    'data-table', ...                %css id of table (default)
                    1, ...                           %html header option (generate complete html header)
                    '', ...                          %css url (none - generated embedded CSS styles)
                    fn_html ...                      %filename for html file
                    );
                
                %generate name for xml file
                fn_xml = [pn_data,filesep,fn_base,'-data.xml'];
                
                %export -data.xml file
                %syntax: [xml,msg] = gceds2xml(s,cols,headings,xsl_url,fn)
                gceds2xml( ...
                    data, ...                        %data structure to export
                    [], ...                          %column list (default = all)
                    [], ...                          %headings (default = column names)
                    '', ...                          %xsl url (none - generated embedded CSS styles)
                    fn_xml ...                       %filename for html file
                    );
                
            end
            
            %
            %code for plotting or other operations goes here
            %
            
            %index the destination directory to create/update XML index and data set summary pages
            harvest_datapages_xml( ...
                pn_dest, ...     %base pathname containing files to index
                '', ...          %subdirectories in pn_dest to index
                profile, ...     %profile name in harvest_info.m
                html, ...        %set HTML format option to transform XML to HTML
                '', ...          %set interval to automatic
                'MD' ...         %flag display format ('MD' = flag columns for all data/calc columns)
                );
            
            %generate plots using stored configuration info in demo/harvest_plot_info.m if pn_plots provided
            if ~isempty(data) && ~isempty(pn_plots)
                
                msg = harvest_webplots_xml( ...
                    fn_dest, ...   %filename of data structure to plot
                    pn_data, ...   %pathname containing fn_dest
                    pn_plots, ...  %pathname for plot files
                    profile, ...   %profile name in harvest_plot_info.m
                    'month', ...    %plot interval
                    html ...       %set HTML format option to transform XML to HTML
                    );
                
            end
            
        end
        
        %generate status output
        if isempty(msg)
            msg = ['successfully harvested data from ',source];
            status = 1;
        end
        
        %send post-harvest email if specified
        if ~isempty(email)
            
            %perform quality checks on harvested data
            msg_check = harvest_check( ...
                data, ...  %data structure to check
                3, ...     %number of days back to check from current date
                0, ...     %threshold for total missing values
                0, ...     %threshold for total flagged values
                0, ...     %threshold for missing values in any one day
                0, ...     %threshold for flagged values in any one day
                100 ...    %wordwrap column for text to email
                );
            
            %send email if any checks fail
            %(note: Internet preferences must be set in MATLAB before sendmail can be called -
            %see 'help sendmail' for information)
            if ~isempty(msg_check)
                try
                    sendmail(email,'Quality report from data_harvester.m',msg_check);
                catch e
                    msg = [msg,'; an error occurred sending a post-harvest email (',e.message,')'];
                end
            end
        end
        
    else
        msg = [source,' is not present in the MATLAB search path'];
    end
    
else
    msg = 'data source m-file is required';
end
