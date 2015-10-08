function [msg,status] = cenmet_233_data_harvester_sql(source,template,sitecode,profile,profile_hrly,profile_dly,pn_dest,pn_plots,html,email,fn_dest,fn_dest_hrly,fn_dest_dly,reprocess)
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
%last updated: 04-Mar-2013

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
            
            if ~isempty(data)
                
                col = name2col(data,'PPT_SA_INST');
                %convert PPT_INST from in to mm
                if ~isempty(col)
                    [data,msg] = add_calcexpr(data, ...
                        '[NaN ; diff(PPT_SA_INST)]', ...                %calculate precip using 0.05mm/tip correction factor
                        'PPT_SA_DIFF', ...                              %new column name
                        'mm', ...                                       %new column units
                        'Difference in precipitation', ...              %description
                        col+1, ...                                      %position
                        0, ...                                          %replicate scalar values (no)
                        'x<0=''I'';x>5=''I''', ...                      %Q/C flag criteria for the new column
                        'calculation');                                 %variable type of the new column
                end
                
                col = name2col(data,{'PPT_SA_INST'});
                if ~isempty(col)
                    [data,msg] = num_replace(data, ...
                        'PPT_SA_DIFF', ...                  %columns to update
                        'PPT_SA_DIFF < 0.5', ...            %criteria to match
                        0, ...                              %new value to assign
                        0, ...                              %change log option
                        '' ...                              %flag to assign for revised values ('' for none)
                        );
                end
                
                col = name2col(data,'PPT_SH_INST');
                %convert PPT_INST from in to mm
                if ~isempty(col)
                    [data,msg] = add_calcexpr(data, ...
                        '[NaN ; diff(PPT_SH_INST)]', ...                %calculate precip using 0.05mm/tip correction factor
                        'PPT_SH_DIFF', ...                              %new column name
                        'mm', ...                                       %new column units
                        'Difference in precipitation', ...              %description
                        col+1, ...                                      %position
                        0, ...                                          %replicate scalar values (no)
                        'x<0=''I'';x>5=''I''', ...                      %Q/C flag criteria for the new column
                        'calculation');                                 %variable type of the new column
                end
                
                col = name2col(data,{'PPT_SH_INST'});
                if ~isempty(col)
                    [data,msg] = num_replace(data, ...
                        'PPT_SH_DIFF', ...              %columns to update
                        'PPT_SH_DIFF < 0.45', ...       %criteria to match
                        0, ...                          %new value to assign
                        0, ...                          %change log option
                        '' ...                          %flag to assign for revised values ('' for none)
                        );
                end
                
                col = name2col(data,'SNODEP_INST');
                if ~isempty(col)
                    %Null out any snodep values flagged as 'I'
                    [data,msg] = nullflags( ...
                        data, ...                       %data
                        'I', ...                        %flagchars
                        'SNODEP_INST', ...              %cols
                        1, ...                          %metaopt
                        0, ...                          %clearflags
                        '', ...                         %newflag
                        0 ...                           %logsize
                        );
                end
                
                col = name2col(data,'SNODEP_INST');
                if ~isempty(col)
                    md = running_median(extract(data,'SNODEP_INST'),12,1,'back');
                    
                    % add new column for running median snow depth
                    [data,msg] = addcol( ...
                        data, ...                                           % original data structure (required)
                        md, ...                                             % an array of calculated values (required)
                        'SNODEP_MED', ...                                   % the name of the new column (required)
                        'm', ...                                            % the units string for the new column (required)
                        '12 point running median of SNODEP_INST', ...       % the description for the new column (optional - default = name)
                        'f', ...                                            % the data type of the new column (optional - default = 'f' or 's')
                        'data', ...                                         % the variable type of the new column (optional - default = 'calculation')
                        'continuous', ...                                   % the numerical type of the new column (optional)
                        2, ...                                              % the number of decimal places to use for text output
                        '', ...                                             % the flagging criteria for the new column (optional - default = '')
                        col+1 ...                                           % the column position (1 = beginning, [] = last)
                        );
                end
            end
            
            if ~isempty(data)
                
                col = name2col(data,'SNODEP_INST');
                %convert SNODEP_INST from m to mm
                if ~isempty(col)
                    [data,msg] = unit_convert(data,'SNODEP_INST','mm');
                end
                
                col = name2col(data,'SNODEP_MED');
                %convert SNODEP_MED from m to mm
                if ~isempty(col)
                    [data,msg] = unit_convert(data,'SNODEP_MED','mm');
                end
                
                col = name2col(data,'LYS_TB_TOT');
                %convert LYS_TB_TOT from tip to mm
                if ~isempty(col)
                    [data,msg] = unit_convert(data,'LYS_TB_TOT','mm','x*1');
                end
                
                %Revise values for Solar radiation sensor (upward facing sensor that
                %measures down-welling solar radation)
                col = name2col(data,{'SOLAR_AVG'});
                if ~isempty(col)
                    [data,msg] = num_replace(data, ...
                        {'SOLAR_AVG'}, ...                     %columns to update
                        'SOLAR_AVG < 10', ...                  %criteria to match
                        0, ...                                 %new value to assign
                        1, ...                                 %change log option
                        '' ...                                 %flag to assign for revised values ('' for none)
                        );
                end
                
                %delete uncorrected columns from radiation table
                col = name2col(data,{'LW_OUT_AVG','LW_IN_AVG'});
                if ~isempty(col)
                    [data,msg] = deletecols(data,{'LW_OUT_AVG', 'LW_IN_AVG'});
                end
                
                %Revise values for radiation sensor (upward facing sensor that
                %measures down-welling solar radation)
                col = name2col(data,{'SW_IN_AVG','SW_OUT_AVG'});
                if ~isempty(col)
                    [data,msg] = num_replace(data, ...
                        {'SW_IN_AVG','SW_OUT_AVG'}, ...                     %columns to update
                        'SW_IN_AVG < 10', ...                               %criteria to match
                        0, ...                                              %new value to assign
                        1, ...                                              %change log option
                        '' ...                                              %flag to assign for revised values ('' for none)
                        );
                end
                
                col = name2col(data,{'SW_IN_AVG','SW_OUT_AVG'});
                if ~isempty(col)
                    [data,msg] = num_replace(data, ...
                        'ALBEDO_AVG', ...               %columns to update
                        'SW_IN_AVG < 10', ...           %criteria to match
                        NaN, ...                        %new value to assign
                        1, ...                          %change log option
                        '' ...                          %flag to assign for revised values ('' for none)
                        );
                end
                
                %AIR_150 and associated to flag sensor removal
                col = name2col(data,{'AIRTEMP_MEAN_150_0_04'});
                if ~isempty(col)
                    [data,msg] = num_replace(data, ...
                        {'AIRTEMP_MEAN_150_0_04','DEWPT_MEAN_150_0_04','RELHUM_MEAN_150_0_04','VPD_MEAN_150_0_04','VPD_MEAN_150_0_04','VAP_MEAN_150_0_04'}, ...     %columns to update
                        'AIRTEMP_150_DIAG = 0', ...                                                                                                                 %criteria to match
                        NaN, ...                                                                                                                                    %new value to assign
                        1, ...                                                                                                                                      %change log option
                        'G' ...                                                                                                                                     %flag to assign for revised values ('' for none)
                        );
                end
                
                %AIR_250 and associated to flag sensor removal
                col = name2col(data,{'AIRTEMP_MEAN_450_0_01'});
                if ~isempty(col)
                    [data,msg] = num_replace(data, ...
                        {'AIRTEMP_MEAN_250_0_03'}, ...                                          %columns to update
                        'AIRTEMP_250_DIAG = 0', ...                                             %criteria to match
                        NaN, ...                                                                %new value to assign
                        1, ...                                                                  %change log option
                        'G' ...                                                                 %flag to assign for revised values ('' for none)
                        );
                end
                
                %Set snow to zero when manual inspection confirms no snow.
                col = name2col(data,{'SNODEP_INST','SWE_INST'});
                if ~isempty(col)
                    [data,msg] = num_replace(data, ...
                        {'SNODEP_INST','SWE_INST','SNODEP_MED'}, ...                                                            %columns to update
                        'SNOW_DIAG = 0', ...                                                                                    %criteria to match
                        0, ...                                                                                                  %new value to assign
                        1, ...                                                                                                  %change log option
                        '' ...                                                                                                  %flag to assign for revised values ('' for none)
                        );
                end
            end
            
            if ~isempty(data)
                
                %check new records for duplicate records
                [data,msg] = cleardupes( ...
                    data, ...                   %data structure
                    {'Date'}, ...               %{data.name{2}}, ...        %date column
                    'verbose' ...               %logging option
                    );
                
                %delete uneeded columns
                col = name2col(data,{'AIRTEMP_150_DIAG','AIRTEMP_250_DIAG','SATVP_150_Avg','SATVP_450_Avg'});
                if ~isempty(col)
                    [data,msg] = deletecols(data,{'AIRTEMP_150_DIAG','AIRTEMP_250_DIAG','SATVP_150_Avg','SATVP_450_Avg'});
                end
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
                interpcols = {'AIRTEMP_MEAN_150_0_04','AIRTEMP_MEAN_250_0_03','AIRTEMP_MEAN_350_0_02','AIRTEMP_MEAN_350A_0_05','AIRTEMP_MEAN_450_0_01', ...
                    'SOILTEMP_MEAN_0_100_04','SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_50_03', ...
                    'RELHUM_MEAN_150_0_04','RELHUM_MEAN_450_0_01','SOLAR_MEAN_625_0_01', ...
                    'SOILWC_MEAN_0_100_04','SOILWC_MEAN_0_10_01','SOILWC_MEAN_0_20_02','SOILWC_MEAN_0_50_03'};
                
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
                    if reprocess == 0
                        data = [];  %clear data unless reprocess flag is set
                    end
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
            
            %create hourly summaries
            if ~isempty(data)
                s = data;
                interval = 'hour';
                dtcols = [];
                aggrcols = [];
                statcols = [];
                statopt = 4;
                flagopt = 0;
                qcrules = [];
                missing_anom = 1;
                
                [s2,msg] = aggr_datetime(s,interval,dtcols,aggrcols,statcols,statopt,flagopt,qcrules,missing_anom);
            end
            
            %create daily summaries
            if ~isempty(data)
                s = data;
                interval = 'day';
                dtcols = [];
                aggrcols = [];
                statcols = [];
                statopt = 4;
                flagopt = 0;
                qcrules = [];
                missing_anom = 1;
                
                [s3,msg] = aggr_datetime(s,interval,dtcols,aggrcols,statcols,statopt,flagopt,qcrules,missing_anom);
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
            end
            
            %code for saving hourly data file and generating export formats goes here
            %users must define unique file name in process file.
            %
            
            if ~isempty(s2)
                
                %save .mat file to destination
                save([pn_data,filesep,fn_dest_hrly],'s2')
                
                %generate name for csv file
                [~,fn_base] = fileparts(fn_dest_hrly);
                fn_csv = [fn_base,'.csv'];
                
                %export .csv file with separate metadata in FLED style with q/c flag columns for all
                %data/calc columns (see 'help exp_ascii' for all options)
                exp_ascii( ...
                    s2, ...     %data structure to export
                    'csv', ...    %file format to export
                    fn_csv, ...   %filename for CSV file
                    pn_data, ...  %file path for CSV file
                    'Displayed data are statistics over hourly time periods', ...       %title string ('' = use data set title)
                    'SB', ...     %header format ('SB' = brief header with separate metadata file -meta.txt)
                    'MD', ...     %flag display format ('MD' = flag columns for all data/calc columns)
                    'FLED' ...    %metadata style
                    );
            end
            
            if ~isempty(s3)
                
                %save .mat file to destination
                save([pn_data,filesep,fn_dest_dly],'s3')
                
                %generate name for csv file
                [~,fn_base] = fileparts(fn_dest_dly);
                fn_csv = [fn_base,'.csv'];
                
                %export .csv file with separate metadata in FLED style with q/c flag columns for all
                %data/calc columns (see 'help exp_ascii' for all options)
                exp_ascii( ...
                    s3, ...     %data structure to export
                    'csv', ...    %file format to export
                    fn_csv, ...   %filename for CSV file
                    pn_data, ...  %file path for CSV file
                    'Displayed data are statistics over daily time periods', ...       %title string ('' = use data set title)
                    'SB', ...     %header format ('SB' = brief header with separate metadata file -meta.txt)
                    'MD', ...     %flag display format ('MD' = flag columns for all data/calc columns)
                    'FLED' ...    %metadata style
                    );
            end
            
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
                    'year', ...    %plot interval
                    html ...       %set HTML format option to transform XML to HTML
                    );
                
            end
            
            %index the destination directory to create/update XML index and data set summary pages
            harvest_datapages_xml( ...
                pn_dest, ...     %base pathname containing files to index
                '', ...          %subdirectories in pn_dest to index
                profile_hrly, ...     %profile name in harvest_info.m
                html, ...        %set HTML format option to transform XML to HTML
                '', ...          %set interval to automatic
                'MD' ...         %flag display format ('MD' = flag columns for all data/calc columns)
                );
            
            %generate plots using stored configuration info in demo/harvest_plot_info.m if pn_plots provided
            if ~isempty(s2) && ~isempty(pn_plots)
                
                msg = harvest_webplots_xml( ...
                    fn_dest_hrly, ...   %filename of data structure to plot
                    pn_data, ...   %pathname containing fn_dest
                    pn_plots, ...  %pathname for plot files
                    profile_hrly, ...   %profile name in harvest_plot_info.m
                    'year', ...    %plot interval
                    html ...       %set HTML format option to transform XML to HTML
                    );
                
            end
            %index the destination directory to create/update XML index and data set summary pages
            harvest_datapages_xml( ...
                pn_dest, ...     %base pathname containing files to index
                '', ...          %subdirectories in pn_dest to index
                profile_dly, ...     %profile name in harvest_info.m
                html, ...        %set HTML format option to transform XML to HTML
                '', ...          %set interval to automatic
                'MD' ...         %flag display format ('MD' = flag columns for all data/calc columns)
                );
            
            %generate plots using stored configuration info in demo/harvest_plot_info.m if pn_plots provided
            if ~isempty(s3) && ~isempty(pn_plots)
                
                msg = harvest_webplots_xml( ...
                    fn_dest_dly, ...   %filename of data structure to plot
                    pn_data, ...   %pathname containing fn_dest
                    pn_plots, ...  %pathname for plot files
                    profile_dly, ...   %profile name in harvest_plot_info.m
                    'year', ...    %plot interval
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
