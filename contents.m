%GCE Data Toolbox for MATLAB (version 3.9.4, 27-Aug-2015)
%
%(c)2002-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                                       Core GCE Data Toolbox Functions                                        
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%add_anomalies             Summarizes flagged and missing values for specified parameters and stores the report in the Data/Anomalies
%add_calcexpr              Evaluates a text expression as a MATLAB statement and adds the resultant values to a GCE Data Structure
%add_datecol               Generates a column of formatted date values from date component columns or an existing date column in a GCE Data Structure
%add_datepartcols          Adds numerical date part columns to a GCE Data Structure, based on a single serial date column
%add_flagdef               Adds a Q/C flag definition to a GCE Data Structure if not already defined
%add_harvest_log           Logs results of a harvest operation initiated by start_harvesters to a GCE Data Structure
%add_history               Adds an entry to the data structure processing history
%add_itis_tsn              Looks up ITIS taxonomic serial numbers for a column of taxonomic names or codes in a GCE Data Structure
%add_latloncoords          Adds latitude and longitude coordinates (deg) to a GCE Data Structure containing geographic coordinates in UTM (m)
%add_locations             Adds a column of location names to a dataset based on geographic lookups of reference station coordinates
%add_ncdc_metadata         Adds metadata to a NOAA NCDC data set based on station information in ''ncdc_ghcnd_stations.mat''
%add_riverdist_gps         Adds geographic coordinate columns to a GCE Data Structure based on river distances
%add_sitemetadata          Adds or updates site and location metadata based on site, station or location codes or geographic coordinates
%add_sitenames             Adds a column of site names to a data structure by matching location names to sites in 'geo_locations.mat'
%add_stationcoords         Adds geographic coordinate columns to a data structure by matching station or location codes to entries
%add_studydates            Adds study date metadata descriptors to a GCE Data Structure, based on the range of date values in
%add_studysites            Adds a column of GCE site codes to a data structure by matching values in geographic coordinate columns
%add_tide_stage            Generates text or numeric tide stage columns from a selected depth or pressure column in a GCE data structure
%add_title_dates           Adds or updates a formatted date range to the title of a GCE Data Structure based the dates of observations
%add_transect_dist         Adds trandsect and distance columns to a GCE Data Structure by matching GPS coordinates to transect coordinates
%add_unit_mappings         Adds units to the GCE Data Toolbox unit conversion database by mapping to existing units
%add_utmcoords             Adds geographic coordinates in UTM units to a GCE Data Structure containing coordinates in lat/lon (decimal degrees)
%add_year_yearday_hours    Adds Year, YearDay and Hours columns to a GCE Data Structure, calculated from existing date/time columns
%add_yeardaycol            Adds a numerical year day column to a GCE Data Structure, based on serial date or formatted date and time columns
%addcol                    Adds a column array as a new calculated column to a GCE-LTER data structure
%addflags                  Adds manual qualifier flags to all or selected records in one or more columns of a GCE Data Structure
%addmeta                   Appends or updates metadata fields in a GCE-LTER data structure or metadata array
%aggr_bindata              Bins data by values in the specified numerical column after aggregation by one or more grouping columns
%aggr_datetime             Performs statistical aggregation on selected data columns at the specified date/time interval
%aggr_index                Returns a sorted data structure and grouping index for use in aggregation operations
%aggr_movingdatewindow     Generates a smoothed time series data set by statistically summarizing values along a sliding date window
%aggr_stats                Statistical aggregation function for summarizing or re-sampling GCE Data Structures
%aggr_stats_text           Statistical aggregation function for summarizing both numeric and text columns in a GCE Data Structure
%aggr_sums                 Sorts and aggregates data in a GCE-LTER data structure by one or more columns,
%aggr_topbottom            Returns top and bottom values for data columns in a data structure based on values in a depth or pressure column,
%append_data               Appends a GCE Data Structure to an existing data structure on disk using a specified merge type
%apply_template            Applies a metadata template to a data structure, matching parameters by name
%assign_numtype            Automatically assigns numerical types and precisions to columns in a GCE Data Structure
%batch_exp_ascii           Exports a batch of files containing GCE Data Structures to delimimited text format
%bbox2sites                Returns a list of GCE study sites with bounding polygons intersecting a specified bounding box
%calc_date_cr10            Adds a serial date column calculated from year, yearday and integer time columns from a Campbell CR10x logger file
%calc_missing_vals         Fills in missing values in one or more columns of a GCE Data Structure using a calculated expression
%calc_yearday_stats        Summarizes variables in a time series data set by year day (1-365) for plotting or use in date-based limit checks
%cleardupes                Removes rows in a GCE Data Structure in which the contents of all specified columns are duplicated,
%clearflags                Clears specified flags from a GCE Data Structure for display or export purposes
%clearreps                 Replaces repeated values in the selected columns of a GCE-LTER data structure
%coalesce_cols             Coalesces values in two or more compatible data columns by filling in null/NaN records
%codes2criteria            Generates QA/QC criteria for coded columns in a GCE Data Structure based on code definitions
%codes2dataset             Generates a code definition data structure for coded columns in a GCE Data Structure
%cols2flags                Converts values in specified text columns of a GCE Data Structure to QA/QC flags for the corresponding data columns
%cols2flags_mapped         Converts data set columns to QA/QC flags after mapping multi-character flags to single character equivalents
%colstats                  Calculates basic descriptive statistics for columns in a standard GCE-LTER data structure
%compactcols               Deletes columns in a data structure in which all values are null/empty
%compactrows               Compacts a GCE Data Structure by eliminating rows in the structure in which all indicated data columns contain NaN or ''
%concat_cols               Concatenates text columns in a GCE data structure to create a single text column
%convert_csi_time          Converts Campbell Scientific max/min times in hhmm integer or h:m string format to a standard time format
%convert_datatype          Converts specified columns in a GCE Data Structure to a new data type, transforming values as necessary
%convert_date_format       Converts the format of specified date/time columns in a GCE Data Structure to a new format
%convert_num2str           Converts values in a numeric data column of a GCE Data Structure to string values using 'int2str'
%copy_attribute_meta       Copies attribute metadata between specified columns in two data structures
%copycol                   Copies and renames a single column in a GCE Data Structure
%copycols                  Copies data from one or more columns in a GCE Data Structure to form a new data structure or array
%copyflags                 Copies composite flags from one or more columns and adds to or replaces the existing flag arrays
%copyrows                  Copies data from one or more rows in a GCE-LTER data structure to form a new data structure or array
%correct_drift             Corrects sensor drift by applying a constant, linearly-varying or custom weighted offset for a range of dates
%ctd_bin_avg               Generates a bin-averaged and interpolated data set from a CTD profile
%cullflags                 Deletes all records from a GCE Data Structure containing any values assigned specified flags
%dataflag                  Evaluates Q/C criteria or assigns user-specified flags to generate or update Q/C flag arrays
%datamerge                 Merges (concatenates) two GCE Data Structures to create a combined structure
%daterange2flags           Assigns Q/C flags by date range and locks flags to prevent automatic recalculation
%daterange2str             Generates textual descriptions of ranges of serial dates based on a selection index
%decodecols                Converts coded columns in a GCE Data Structure to text columns based on code definitions in the metadata
%deletecols                Deletes specified columns from a GCE Data Structure, ignoring any unmatched column names or indices
%deleterows                Deletes data from one or more rows in a GCE-LTER data structure to form a new data structure or array.
%dupe_index                Returns an index of records in a GCE Data Structure with duplicate values in all or specified columns
%edit_importfilters        Opens the list of GCE Data Toolbox import filter definitions stored in 'imp_filters.mat' into a grid for editing
%encodestrings             Encodes text columns in a GCE data structure as series of unique integers
%extract                   Extracts columns from a GCE-LTER data structure and returns standard numeric or cell arrays of strings
%extract_rows              Extracts selected rows from columns in a GCE-LTER data structure as numeric or cell arrays of strings
%fill_date_gaps            Fills in missing date/time records in a time-series data set to create uniform time intervals
%fill_meta_tokens          Replaces tokens in metadata templates with text from the corresponding metadata fields
%filter_by_daterange       Filters a GCE data structure to include one or more specified date ranges
%filter_by_dates           Filters a dataset to only include records for a specified set of dates
%fixprec                   Sets numerical precision of specified columns in a GCE Data Structure equal to the display precision
%gce_valid                 Identifies and validates a GCE-LTER Data or Stat Structure by checking for required fields and verifying
%gceds2cell                Converts a GCE Data Structure to a standard MATLAB cell array
%gceds2struct              Converts columns of a GCE Data Structure to a standard structure variable with fields named based on columns
%gceds2table               Converts data, qualifier flags and metadata from a GCE Data Structure to a MATLAB table object
%get_flagdefs              Retrieves definitions for selected QA/QC flags from GCE Data Structure metadata
%get_importfilters         Returns a database of GCE Data Toolbox import filter definitions stored in 'imp_filters.mat'
%get_metadata_bbox         Parses geographic coordinates in GCE Data Structure metadata to return bounding box coordinates
%get_open_dataset          Retrieves a data structure from an open editor window selected via listbox
%get_studydates            Retrieves serial dates for records in a GCE Data Structure based on analysis of datetime columns
%get_templates             Retrieves a structure containing GCE Data Toolbox metadata templates
%get_type                  Returns the specified attribute descriptor for specified columns in a GCE Data Structure
%getpath                   Retrieves path cache information from the active GCE Data Toolbox editor window
%harvest_check             Generates a harvest check email based on user-specified thresholds for missing and flagged values
%help_flagfnc              Opens a GUI dialog containing help text for all QA/QC flagging functions named 'flag_*'
%import_metadata           Imports metadata fields from one GCE Data Toolbox metadata array to update another metadata array
%import_templates          Imports metadata templates to add to or update a GCE Data Toolbox templates database
%index2httpindex           Replaces specified file paths in a search index structure with urls for indexing web-hosted data sets
%insertrows                Inserts rows of new data into specified columns of an existing GCE Data Structure,
%interp_missing            Performs 1D interpolation to fill in missing values in a single data series using a specified method
%interp_missing2           Performs 1D interpolation to fill in missing values in a compound data series using a specified method
%interp_missing_diurnal    Performs 1D interpolation to fill in missing values in time-series data based on time of day
%interp_missing_stepwise   Performs interpolation to fill in missing values, proceeding step-wise for each unique value in a stepping column
%joindata                  Joins two data structures together by finding matching data rows in one or more common (key) columns
%list_harvesters           Lists active MATLAB timer objects created by start_harvesters.m
%listcols                  Lists names and units of all columns in a GCE-LTER data or stat structure
%listdatacols              Returns an index of data and/or calculation columns (dependent variables) in a GCE Data Structure
%listhist                  Lists the contents of the history field from a GCE-LTER Data Structure
%listmeta                  Generates formatted metadata from values stored in a GCE Data or Stat structure
%log_metachanges           Documents changes to attribute metadata fields in a GCE Data Structure after application of a template
%lookup_coords             Looks up geographic coordinates in a GCE Data structure and returns arrays on longitude and latitude in decimal degrees
%lookup_location           Returns details for a specific geographic location registered in 'geo_locations.mat'
%lookup_sitemetadata       Returns formatted site descriptor metadata for a list of GCE-LTER sampling sites
%lookup_stationmeta        Returns formatted site descriptor metadata for a list of GCE-LTER sampling locations
%lookupmeta                Looks up metadata in a GCE Data or Stat Structure by category and fieldname
%make_template             Parses a text file to create a metadata template and opens it in the Template Editor application
%match_sites               Matches GPS coordinates given by longitude and latitude to site polygons in 'geo_polygons.mat'
%maxrows                   Returns a maximum of 'maxrownum' rows from a GCE-LTER data structure 'data'
%merge_by_date             Merges (i.e. concatenates) two GCE data structures to produce a single time series without duplicate date/time records.
%merge_dateplots           Generates an HTML table of date plot thumbnails based on multiple sets of existing plots in a specified directory
%mergemeta                 Merges metadata from two GCE Data structures following a data merge or join operation
%meta2struct               Converts an n x 3 cell array containing GCE-LTER metadata into a nested structure
%meta_fields               Returns an array of metadata categories and fields for a named metadata style
%meta_subfields            Adds supported sub-fields to a GCE Data Toolbox metadata array for improved parsing by meta2struct()
%meta_template             Generates data descriptor metadata for a GCE Data Structure by matching supplied variable names
%minvalue2zero             Converts values in specified columns of a GCE Data Structure below a minimum threshold to zero
%multi_templates           Applies multiple, date-dependent metadata templates to a data set to accomodate parameter metadata changes
%multimerge                Merges (concatenates) multiple GCE Data Structures specified by filename and structure name
%name2col                  Returns an array of column index numbers matching the specified list of column names in a GCE-LTER data structure
%nan2zero                  Converts NaN values in the specified columns of a GCE Data Structure to zeros
%negative2zero             Converts negative values in the specified columns of a GCE Data Structure to zeros
%newstruct                 Creates an empty GCE data or stat (statistical summary) structure, containing all default fields
%newtitle                  Updates the title of a GCE Data or Stat Structure with the specified string
%normalize_cols            Normalizes a data set by merging multiple columns to form combined parameter name and parameter value columns
%nullflags                 Converts values in a GCE Data Structure assigned specified flags to NaN/empty
%num_records               Returns the number of records in a GCE Data Structure
%num_replace               Search and replace numeric values in specified columns of a GCE Data Structure with a new value
%pad_date_gaps             Fills in missing date/time records in a time-series data set to create uniform time intervals
%previewdata               Displays a preview of formatted data in a scrolling text box control.
%query_index               Returns an index of rows in a GCE Data Structure matching a query statement
%querydata                 Queries values in a GCE Data Structure to return a new data structure containing only rows meeting the criteria
%querystats                Calculates descriptive statistics for values in a GCE-LTER data structure
%readheader                Parses documentation and attribute descriptor metadata using 'imp_ascii.m' to update a GCE Data Structure
%readmeta                  Reads a text file containing delimited metadata fields ([category_field]:[value])
%rename_column             Updates the name of a column in a GCE Data Structure, propagating the change
%search_data               Identifies GCE Data Structures in one or more directories matching specified search criteria
%search_index              Generates a search index for 'search_data' by inspecting all MATLAB files in the specified directories
%set_type                  Sets attribute descriptor values for specified columns in a GCE Data Structure
%sortdata                  Performs multi-column, bidirectional sorting on rows in a GCE Data Structure
%split_cols                Splits a text column in a GCE data structure on a delimiter character to create multiple columns
%split_dataseries          Splits a compound data series based on values in a specified column and serially joins subsets to form a standard table
%start_harvesters          Creates timer objects based on information stored in 'harvest_timers.mat'
%stop_harvesters           Stops all or specified harvest timers and deletes the timer object(s) from memory
%string_replace            Performs string replacement on one or more text columns in a GCE Data Structure
%syncpath                  Synchronizes path cache information between GCE Data Toolbox editor windows
%trim_metadata             Trims excess characters from metadata fields in a GCE Data Structure
%trim_textcols             Trims leading and trailing blanks from all or specified text columns in a GCE Data Structure
%unit_convert              Performs unit conversions on a column in a GCE Data Structure using the specified multiplier or expression.
%update_attributes         Updates attribute metadata for a column in a GCE Data Structure
%update_codes              Updates value codes defined in the metadata for a column in a GCE Data Structure
%update_data               Updates values in a GCE Data Structure column, optionally logging all value changes
%update_dataset            Updates data column values and adds new columns from a second GCE Data Structure and logs all changes in the metadata
%update_query              Updates values in a GCE Data Structure column for rows matching specified query criteria
%update_values             Updates selected values in a GCE Data Structure column based on a row index
%viewhelp                  Displays help text for a specified function in a scrollable text viewer
%viewstats                 Displays ungrouped column statistics for a GCE data structure in a scrollable text box
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                                 Graphical User Interface Applications (GUI)                                  
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%close_gdt                 Closes all GCE Data Tools and optionally exits MATLAB
%edit_unitconv             Dialog for editing unit conversion tables used by the GCE Data Toolbox.
%guihelp                   Opens MATLAB help text for a specified function in a scrollable GUI dialog
%lookup_template           Opens a GUI list dialog for selecting a metadata template defined in imp_templates.mat
%ui_aboutgce               GCE Data Toolbox startup splash screen with links to the structure editor and documentation
%ui_aggrdatetime           GCE Data Toolbox date/time aggregated statistics dialog
%ui_aggrmovingdate         GCE Data Toolbox moving window date/time aggregated statistics dialog
%ui_aggrstats              GCE Data Toolbox aggregated statistics dialog
%ui_axislimits             Axis limits dialog box for 2D and 3D plots
%ui_batch_import           GUI dialog for batch processing data files to import them as GCE Data Structures
%ui_bindata                GCE Data Toolbox dialog for calculating statistics on aggregated data binned by values in a specified column.
%ui_calc_missing           GCE Data Toolbox dialog for filling in missing values in a data column using calculated values
%ui_calculator             Dialog for adding calculated columns to a GCE Data Structure by evaluating a user-specified MATLAB expression
%ui_clearflags             GCE Data Toolbox dialog for selective deletion of QA/QC flags or flagged values, or selective conversion of flags to columns
%ui_copyflags              GCE Data Toolbox dialog for copying composite flags from one or more data columns
%ui_correct_drift          GCE Data Toolbox dialog for correcting data set columns for sensor drift using 'correct_drift.m'
%ui_datagrid               Opens a GCE Data Structure into a metadata-aware grid to allow data values to be viewed and edited
%ui_dateplots              GUI dialog for generating multiple date plots at various intervals from a time-series plot
%ui_dateplots_html         GUI dialog for generating multiple date plots at various intervals from a time-series plot
%ui_dateplots_template     GUI dialog for generating multiple date plots at various intervals from a time-series plot
%ui_edit_filters           GUI dialog for editing custom import filter entries for the GCE Data Toolbox
%ui_edit_geodatabase       Open the geographic locations database 'geo_locations.mat' into a GUI grid for editing
%ui_editcodes              GUI dialog for editing value codes for a specified column in a GCE Data Structure
%ui_editmetadata           Dialog for editing metadata stored in a GCE Data Structure (called by 'ui_editor')
%ui_editor                 GCE Data Toolbox data structure editor for managing and analyzing data stored in GCE Data Structures
%ui_expclimdb              Dialog for exporting data in LTER ClimDB/HydroDB format
%ui_export_eml             Dialog for generating EML metadata and associated text data distribution files
%ui_exportasc              GUI dialog for exporting data and metadata from a GCE Data Structure in ASCII text format
%ui_fetch_climdb           GUI dialog for retrieving data from the LTER ClimDB/HydroDB web server
%ui_fetch_dataturbine      Opens a dialog box to retrieve data from a Data Turbine server
%ui_fetch_eml_data         Opens a dialog box to retrieve EML-described data tables into the GCE Data Toolbox
%ui_fetch_ncdc_ghcnd       GUI dialog for retrieving data from the NOAA NCDC Global Historic Climate Network FTP site
%ui_fetch_usgs             GUI dialog for retrieving data from the USGS WWW server
%ui_flagdefs               QA/QC flag definition and data anomalies editor dialog called by 'ui_editor'.
%ui_flagfunction           GUI dialog called by 'ui_qccriteria' for adding custom function calls to a Q/C criteria string
%ui_flagpicker             Adds a Q/C flag picker popupmenu and edit button to a GUI figure at a specified position
%ui_gce_register           GCE data download registration form dialog called by 'ui_search_data'
%ui_importfilter           Filtered ASCII import dialog used by the GCE Data Toolbox.
%ui_interp_missing         GCE Data Toolbox dialog for filling in gaps in a data set using one-dimensional interpolation
%ui_joindata               GUI dialog for joining columns in two GCE Data Structures together based on common values in one or more key columns
%ui_manual_qc              Opens a GCE Data Structure in a data grid to allow data values and Q/C flags to be viewed and edited
%ui_mapdata                Data mapping dialog for the GCE Data Toolbox
%ui_metastyle              GUI dialog for editing metadata styles used by the GCE Data Toolbox
%ui_multimerge             Dialog for merging multiple GCE Data Structures into a single structure
%ui_normalizecols          GUI dialog for normalizing a data set by merging multiple related columns into parameter name/value columns
%ui_num_replace            Dialog called by 'ui_editor' for searching and replacing numeric values in a GCE Data Structure
%ui_plotdata               GCE Data Toolbox data structure plotting dialog
%ui_plotgroups             Dialog for creating a series of line/scatter plots from a single data set split by values in a grouping column
%ui_plotvertprofile        Dialog for generating a 3D contour plot of parameter vs distance and depth
%ui_progressbar            Creates a graphical progress bar to illustrate the status of long-running processes
%ui_qccriteria             QA/QC criteria editor dialog called by 'ui_editor' and 'ui_template'
%ui_querybuilder           GUI dialog for building row restriction queries to subselect data from a GCE Data Structure
%ui_search_data            GCE Search Engine dialog for building and querying metadata search indices to identify and retrieve data sets
%ui_sortcolumns            GUI dialog for sorting data columns in a GCE Data Structure
%ui_splitseries            GCE Data Toolbox dialog for splitting a compound data series based on values in a specified column
%ui_statreport             GCE Data Toolbox statistical report generator dialog
%ui_string_replace         Dialog called by 'ui_editor' for searching and replace text values or flags in a GCE Data Structure
%ui_template               GUI dialog for editing metadata templates used by the GCE Data Toolbox
%ui_text_prompt            Opens a dialog box to prompt for a character array
%ui_title                  Dialog called by 'ui_editor' to update the title of a GCE Data Structure or editor window
%ui_topbottom              GCE Data Toolbox dialog for extracting top and bottom data records from a vertical profile data set
%ui_unitconv               Unit conversion dialog called by 'ui_editor' (requires data file ui_editor.mat)
%ui_viewdocs               Displays documentation for the GCE Data Toolbox in a scrolling text box with selectable sections
%ui_viewmeta               Displays various metadata components of a GCE Data Structure in a scrolling list box viewer
%ui_viewtext               Displays a string or cell array of strings in a scrolling list box viewer
%ui_visualqc               Dialog for assigning and clearing QC/QA flags visually by clicking on data points with the mouse.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                                      Database Toolbox Support Functions                                      
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%gce_fastinsert            Executes the MATLAB Database Toolbox 'fastinsert' function for selected columns of a GCE Data Structure
%gce_insert                Executes the MATLAB Database Toolbox 'insert' function for selected columns of a GCE Data Structure
%null2emptystr             Replaces empty cells in a cell array with empty strings
%null2nan                  Replaces empty cells in a cell array with NaN
%sql2gceds                 Executes an SQL query on the specified data source and returns the results as a GCE Data Structure
%sql2struct                Executes an SQL statement on the specified data source and returns a multidimensional structure with field names
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                                       Plotting and Graphics Functions                                        
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%addnote                   Adds an annotation to a plot and assigns the 'ButtonDownFcn' to 'editnote' for text editing and repositioning
%dateplot2html             Generates an HTML page and image files, with optional hyperlinked thumbnails, to represent
%dateplot2template         Generates an HTML page and image files, with optional hyperlinked thumbnails, to represent
%dateplot2xml              Generates an XML page and image files to represent time series data plots for a specified interval
%dateplots                 Generates individual date plots at the specified interval from a standard date plot and saves
%exportfig                 Exports the current figure in the specified format with uicontrol printing suppressed, prompting for filename and path
%get_plot_xrange           Adds controls to a data plot for interactively selecting an X-axis range and returning data to a calling function
%get_plot_yrange           Adds controls to a data plot for interactively selecting an X-axis range and returning data to a calling function
%merge_dateplots_xml       Generates an HTML table of date plot thumbnails based on multiple sets of existing plots in a specified directory
%monthplots                Generates monthly date plots for a multiple parameters in a GCE data structure,
%monthplotsfig             Generates individual monthly date plots from a standard date plot and saves each plot as a .png file
%monthticks                Sets X-axis limits and ticks to even month intervals in a specified date label format for a time-series plot
%multi_dateplots           Generates individual plot files for selected columns in a GCE Data Structure
%openfigfile               Opens a MATLAB .fig file, prompting for the filename if omitted
%plot_vertprofile          Creates a vertical profile plot (i.e. filled contours on a depth vs distance plot)
%plotbuttons               Adds a custom toolbar to the bottom of the current plot, providing constrained zoom, pan and date axis
%plotdata                  Generates 2D symbol/line plots of values in a GCE-LTER data structure
%plotgroups                Creates multiple line/scatter plots for values in two columns of a GCE Data Structure,
%plothistogram             Plots a frequency histogram for the indicated column in a GCE Data Structure
%plotlabels                Adds the specified title and axis label strings to the current plot
%plotmenu                  Adds a menu item to a MATLAB figure containing commands for exporting figures in
%plotresize                Toggles plot select/move/resize for plot axes on a figure
%plotwidgets               Creates or removes standard GCE plot menus and toolbars from a MATLAB figure
%plotwind                  Generates a standard 2-axis wind plot from a GCE Data Structure, with wind speed
%textedit                  Text editing dialog box, to be used as a callback function associated with text objects.
%yearplotsfig              Generates individual annual date plots from a standard date plot and saves each plot as a .png file
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                                      Data Import and Parsing Functions                                       
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%parse_gce_syntax          Parses syntax and parameter information from GCE Data Toolbox function help text
%parse_template_qcrules    Parses Q/C rules in the GCE Data Toolbox metadata templates library and lists rules by variable
%fetch_climdb_data         Fetches data for a specified site and station from the ClimDB/HydroDB web site (requires networking features in MATLAB 6.5/R13 or higher)
%fetch_climdb_info         Retrieves updated status information on sites, stations and variables from the LTER ClimDB/HyroDB web site
%fetch_data_turbine        Retrieves channel data from a Data Turbine source to create a GCE Data Structure
%fetch_ncdc_ghcnd          Retrieves historic climate data from the NOAA NCDC GHCN FTP site for a specified station
%fetch_noaa_hads           Retrieves data arrays from the NOAA HADS NESDIS data server and returns a GCE data structure
%fetch_usgs                Fetches data from the USGS NWIS web site for the specified station and time period
%fetch_usgs_dates          Fetches data from the USGS NWIS web site for the specified station and time period
%fetch_usgs_inventory      Fetches a USGS monitoring site inventory report and generates a USGS stations dataset
%fetch_usgs_stats          Fetches long-term discharge statistics for a list of USGS gauging stations
%imp_aquatroll             Imports data from a GCE Aqua TROLL 200 groundwater data logger
%imp_ascii                 Parses data from a delimitted text file to create a GCE Data Structure
%imp_campbell_toa5         Imports data from a Campbell Scientific Instruments TOA5 ASCII file to create a GCE Data Structure
%imp_castaway_ctd          Parses and concatenates cast records from an OSIL Castaway CTD instrument
%imp_csi_array             Imports an array from a Campbell Scientific Instruments array-based data logger file
%imp_datastruct            Retrieves a GCE Data Structure from a MATLAB binary file
%imp_filter                Imports data from a delimited ASCII file using a specified format string and list of
%imp_hobo_tidbit           Imports data from a Hobo Tidbit temperature logger exported in ASCII boxcar format
%imp_hydrolab              Import filter for GCE Hydrolab groundwater data logger files
%imp_matlab                Reads selected variables in a MATLAB binary file or the base worskspace to form a GCE Data Structure.
%imp_minitroll             Import filter for GCE In-Situ MiniTroll water level loggers
%imp_ncdc_ghcnd            Imports climate data from a NCDC Global Historic Climate Network daily summary file to create a GCE Data Structure
%imp_ncdc_psdi             Parses NCDC Palmer Drought Severity Index from http://www1.ncdc.noaa.gov/pub/data/cirs/climdiv/
%imp_nerr_cdmo             Imports CSV files downloaded from the National Estuarine Research Reserve CDMO web site
%imp_schlumberger          Import filter for GCE Schlumberger CTD-Diver or Cera-Diver groundwater data logger files
%imp_seaphox               Import filter for SeapHOx logger files
%imp_struct                Imports a MATLAB structure containing matching arrays or scalar values to a GCE Data Structure
%imp_usgs_stations         Imports a USGS NWIS station description file generated by 'fetch_usgs_inventory'
%parse_37sm                Parses a processed data file (.asc) from a Seabird Electronics 37-SM Microcat
%parse_climdb_data         Parses tab-delimited data retrieved from the LTER ClimDB/HydroDB web application to create a data structure
%parse_noaa_hads           Parses data arrays from a NOAA HADS NESDIS file to generate a GCE Data Structure
%parse_seabird             Parses data and header metadata from processed Sea-Bird CTD data files and returns a GCE data structure
%parse_usgs                Parses tab-delimited real-time or daily data obtained from the USGS National Water Information System
%fetch_itis                Retrieves taxonomic information from ITIS for a scientific name, common name or TSN record
%parse_endnote             Parses bibliographic information from an EndNote export file to create a structure
%parse_gps                 Parses latitude and longitude from formatted GPS data strings
%parse_cruise_log          Parses information for a specified cast in a cruise log file to supplement information in a CTD data set
%fetch_eml_data            Retrieves text data tables described in an EML metadata document and returns a structure containing parsed data
%fetch_eml_entities        Retrieves a list of dataTable entities described in an EML metadata document as a cell array
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                                            Data Export Functions                                             
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%exp_ascii                 Exports the contents of a GCE Data Structure or GCE Stats Structure as a delimited text file
%exp_climdb                Exports climate and/or hydrographic monitoring data in LTER ClimDB harvester format.
%exp_header                Generates an ASCII import file header from a GCE Data Structure
%exp_matlab                Exports the contents of a GCE Data Structure as a standard MATLAB data file containing data and metadata as variables
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                                        Data Parsing Support Functions                                        
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%batch_import              Batch processes raw data files in a directory using a specified GCE Data Toolbox import filter function
%csi2struct                Parses mixed data arrays from a Campbell Scientific Instruments array-based datalogger file
%parseheader               Parses documentation and attribute descriptor metadata from a specifically-formatted text file header
%split_csi                 Splits Campbell Scientific datalogger files into separate files for each
%split_csi_arrays          Splits processed arrays from a Campbell Scientific Instruments array-based data logger file
%update_usgs_stations      Updates the USGS station list by querying the NWIS site inventory
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                                        Quality Control Flag Functions                                        
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%flag_locks                Locks or unlocks Q/C flag criteria for specified columns in a GCE-LTER data structure
%flag_replace              Performs string replacement for flags of one or more columns in a GCE Data Structure
%flags2cols                Converts Q/C flags in a GCE Data Structure to coded string or integer columns in the data set
%flags2cols_selected       Converts selected Q/C flag information in specified columns of a GCE Data Structure to coded string columns
%flag_ctd_soak_period      Returns an index indicating records collected during the pre-deployment soaking period of a CTD cast
%flag_daterange            Returns an index of date/time values that are within a specified time of day for time-based QA/QC flagging
%flag_inarray              Returns an index of numeric values that are present in a specified array
%flag_inlist               Returns an index of string values that are present in a specified list array or file-based list
%flag_locationcoords       Returns an index of location codes with coordinates that differ by more the specified tolerance from reference coordinates
%flag_locationnames        Returns an index of location code values that are not present in the geographic database 'geo_locations.mat'
%flag_notinarray           Returns an index of numeric values that are not present in a specified array
%flag_notinlist            Returns an index of string values that are not present in a specified list array or file-based list
%flag_novaluechange        Returns an index of values that do not differ from the mean of preceeding values by the specified limits
%flag_nsigma               Returns an index of values above or below the mean of preceeding values by the specified number of standard deviations
%flag_o2saturation         Returns an index of dissolved oxygen concentration values that are above or below specified saturation limits
%flag_percentchange        Returns an index of values above or below the mean of preceeding values by the specified percentages
%flag_sitenames            Returns an index of site code values that are not present in the geographic database 'geo_polygons.mat'
%flag_timeofday            Returns an index of date/time values that are within a specified time of day for time-based QA/QC flagging
%flag_total                Returns an index of values that exceed a limit when totalled with a specified number of preceding values
%flag_valuechange          Returns an index of values above or below the mean of preceeding values by the specified limits
%flag_well_pumping         Returns an index indicating records collected during and following well pumping events based on negative spikes in pressure
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                    Supporting Command-line Toolbox Functions and Miscellaneous Utilities                     
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%documentation.pdf         Miscellaneous support file
%documentation.rtf         Miscellaneous support file
%gce_datatools             Displays the list of functions comprising the GCE Data Toolbox for Matlab
%gce_homepath              Returns the base pathname of the current GCE Toolbox instance, optionally changing the working directory
%license.txt               Miscellaneous support file
%localpaths.txt            Miscellaneous support file
%restart                   Opens the GCE Data Toolbox startup screen without modifying the MATLAB search path
%angleavg                  Calculates an average for angular data using a unit vector approach based on the formula:
%batch_transform_xml       Performs batch XSL tranformation of xml documents in a directory
%cell2commas               Concatenates elements in a cell array of strings to form a single comma-separated character array.
%cell2pipes                Concatenates elements in a cell array of strings to form a single character array separated with padding spaces
%cell2textfile             Exports contents of a cell array of scalar character or numeric values to a text file
%centerstr                 Centers two character arrays with respect to eachother
%clean_endnote             Cleans up author lists and keywords with hard returns and missing identifiers in an Endnote Export file
%clean_path                Removes a terminal file separator from a path string when present for generating fully-qualified file paths
%clean_str                 Converts a single or multi-line character array to a string with all insignificant whitespace removed
%clipplottext              Clips text on a 2D plot by toggling the visibility on or off based on axis position
%compress_str              Removes all blanks from a character array or cell array of strings
%concatcellcols            Concatenates individual cells on each row in a cell array of strings to form a single column array
%cond2salinity             Calculates salinity and sigma-t from water depth, temperature and conductivity measurements
%cond2spcond               Calculates specific conductance at 25C from conductivity and temperature
%conf_limits               Calculates lower and upper confidence limits for an array of means and standard deviations
%confirmdlg                Confirmation dialog that executes a 'callback' statement if the 'OK' button is pressed
%contains                  Returns a logical index of strings in an array that contain the specified substring
%csi_integer2time          Converts Campbell Scientific Instruments min/max times in hhmm integer format to hh:mm string format
%csi_time2integer          Converts Campbell Scientific Instruments min/max times in h:m format to hhmm integer format
%date2monthyear            Converts a MATLAB serial date to Month-Year format (e.g. January 2004)
%date2weekday              Calculates numerical week day for any date, based on a specified first day of the week
%date2weeknumber           Calculates week numbers for an array of serial dates according to various calendar standards
%date2yearday              Calculates year day from a vector of MATLAB serial dates or cell array of valid date strings
%dateaxis                  Refreshes date ticks on the x-axis of the current plot
%datecnv                   Converts numerical dates between various software conventions
%datenum_iso               Generates MATLAB serial dates from ISO date strings in the form 'yyyy-mm-dd HH:MM:SS' or 'yyyymmddTHHMMSS'
%datestr2num               Efficiently converts a cell array of date strings to MATLAB serial dates checking for empty strings and duplicates
%ddeg2dms                  Converts geographic coordinates from decimal degrees format to degrees, minutes, seconds
%dec_places                Determines the maximum number of used decimal places in a floating-point array
%deg2utm                   Converts geographic coordinates from lat/lon degrees to UTM using the specified ellipsoid datum
%deg2utmzone               Converts geographic coordinates from lat/lon degrees to UTM using the specified ellipsoid datum
%depth2tidestage           Determines tide stage and sequential tide bin from a time series of depth or pressure data using tide_high_low()
%editnote                  Dialog for adding or editing text annotations on figures. Can be called without arguments to
%endnote2fastlane          Parses an Endnote export file to produce a tab-delimited file for entering pubs into Fastlane
%file2listbox              Loads an ASCII file and displays it in a uicontrol listbox
%fill_date_tokens          Replaces date/time field tokens in square brackets with current date/time information
%geo_simplify              Simplifies a geographic polygon by reducing the number of lon/lat vertices
%get_file                  Downloads a file from an HTTP, HTTPS, FTP or file system url and returns a fully qualified local filename
%get_polygon               Builds an array of positions defining a closed polygon of specified shape
%get_utc_offset            Calculates the offset of the computer clock from UTC due to time zone settings
%htmltable2cell            Parses table structures from HTML text to return a cell array of contents
%inarray                   Matches values in an array to elements in a specified list of values and returns a logical index
%inlist                    Matches strings in an array to elements in a specified list and returns a logical index
%isnull                    Returns a logical index of null values in any array type (numeric, character, cell array)
%list_pasta_package_dois   Lists DOIs for specified data packages in the LTER data portal
%list_pasta_packages       Lists package identifiers and latest revisions for data packages in the LTER data portal
%listbox2file              Saves the string contents of a listbox uicontrol as an ASCII text file
%listdialog                Customized variant of the MATLAB 'listdlg' function
%messagebox                Generates a multi-line message box with a user-specified callback and optional cancel button
%mfilecatalog              Generates a catalog of mfiles in the specified directory as an ASCII file.
%mlversion                 Returns the version of MATLAB running in numerical form ([majorversion].[minorversion])
%neststruct                Nests a child structure in a specified field of a parent structure based on matching values in a shared key field
%no_nan                    Returns a numeric array stripped of NaN and other specified values plus an index of valid values
%o2_airsat                 Calculates dissolved oxygen saturation as a function of temperature and salinity at sea-level
%o2_saturation             Calculates dissolved oxygen saturation as a function of temperature and salinity at sea-level
%parent_figure             Determines the parent figure for any uicontrol handle (returns empty matrix
%pressure2depth            Calculates water depth based on water pressure and latitude using a UNESCO algorithm
%recurse_files             Recursively builds a list of all files in a directory and subdirectories matching a filename pattern
%rename_struct_field       Renames a structure field without re-ordering the existing fields
%roundsig                  Rounds numbers to the indicated significant digits using the method specified
%running_mean              Calculates the running mean and other statistics of an array over the specified number of points
%salinity2spcond           Calculates specific conductance at 25C from salinity measurements
%setpath                   Adds the current directory to the Matlab path
%spcond2salinity           Calculates salinity from specific conductance at 25C
%splitcodes                Parses a delimited string containing code name, code value pairs and returns matching name and value arrays
%splitstr                  Splits a character array into elements based on positions of a specified delimiter,
%splitstr_fast             Speed-optimized version of the 'splitstr' function for deblanked, single-line character arrays
%splitstr_multi            Splits strings in a cell array into sub-arrays based on a delimiter character
%t_value_onetail           Returns the area under the Student t distribution (single side) for a given alpha and degrees of freedom
%textfile2cell             Reads the specified text file, and returns a cell array of strings with lines optionally word-wrapped
%textfile2str              Reads the specified text file, and returns a string (i.e. 1-row character array)
%tide_high_low             Returns interpolated times and amplitudes of high and low tides based on a time-series of depth measurements
%trimstr                   Trims leading and trailing blanks from a single string or cell array of strings
%urlread2                  URLREAD Returns the contents of a URL as a string.
%urlwrite2                 URLWRITE Save the contents of a URL to a file.
%utm2deg                   Converts geographic coordinates from UTM to decimal degrees (lon,lat)
%viewtext                  Displays the contents of a character array or cell array of strings in a GUI text viewer using 'ui_viewtext'
%wordwrap                  Wraps lines of text at word breaks with optional indentation
%yearday2date              Converts Julian Day/Year Day to a MATLAB serial date
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                                         XML Functions and Utilities                                          
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%dataset_schema.xsd        Miscellaneous support file
%eml2gce                   Converts EML-described data retrieved using 'fetch_eml_data' to an array of GCE Data Structures
%escape_chars              Escapes specified characters in a string to prevent XML/HTML validation errors
%evalXpath                 Evaluates xpath expressions on an XML document nodeset and returns an array of text contents
%gceds2eml                 Generates an Ecological Metadata Language 2.1.1 document and corresponding ASCII text file from a GCE Data Structure
%gceds2eml_attributes      Generates Ecological Metadata Language 2.1.1 attributeList metadata from a GCE Data Structure
%gceds2eml_table           Generates an Ecological Metadata Language 2.1.1 dataTable tree, STMML tree and corresponding ASCII text file
%gceds2html                Generates HTML markup to display selected columns of a GCE Data Structure in a web table
%gceds2kml                 Creates a Google Earth KML file from a GCE Data Structure containing latitude and longitude columns
%gceds2kml_polylines       Creates a Google Earth KML file with polylines and placemarks from a GCE Data Structure containing latitude and longitude columns
%gceds2xml                 Generates HTML markup to display selected columns of a GCE Data Structure in a web table
%get_eml_file              Fetches an EML document from an HTTP, HTTPS, FTP or file system url and returns a fully qualified local filename
%parseXML                  PARSEXML Convert XML file to a MATLAB structure.
%struct2xml                Generates an xml fragment from a uni- or multi-dimensional structure
%struct2xml_attrib         Generates an xml fragment with attributes from a uni- or multi-dimensional structure
%thumbnail_index_xml       Generates an XML index of images and thumbnails for web display
%xml2file                  Writes an xml file to disk using an xml string generated by 'struct2xml'
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                                Mapping and Geographic Functions and Utilities                                
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%addmap                    Adds a map to the current figure and generates a continuous line plot of the coordinates in 'map'.
%addnote                   Adds an annotation to a plot and assigns the 'ButtonDownFcn' to 'editnote' for text editing and repositioning
%addsites                  Adds site boundary polygon data to a map plot for use with 'poly_mgr'
%axes2pixels               Returns the positions of a figure and its current axis object in pixels and data units
%center_fig                Centers the specified figure on the computer screen
%centerpoly                Centers the polygon represented by handle 'h' over the coordinates
%circle                    Generates coordinates for closed circular polygons at specified x/y coorindates and radius
%compass_rose              Adds a standard 8-point compass rose to a MATLAB figure
%coordstr2ddeg             Converts an array of geographic coordinate strings to decimal degrees, stripping any non-numeric characters
%copylines                 Copies Matlab line objects from the current axis of one figure to another
%copypointlabels           Copies point labels on a GCE map figure to another map figure
%corner_coord              Returns an array of SW and NE corner coordinates for a set of axis limits in degrees and utm
%ctd2dataset               Generates a GCE Data Structure containing CTD station locations and labels for display or plotting
%ctd_stations              Dialog for plotting nominal LMER and GCE-LTER ctd station labels on a map,
%ddeg2dms                  Converts geographic coordinates from decimal degrees format to degrees, minutes, seconds
%deg2utm                   Converts geographic coordinates from lat/lon degrees to UTM using the specified ellipsoid datum
%deg2utmzone               Converts geographic coordinates from lat/lon degrees to UTM using the specified ellipsoid datum
%degmins                   Creates a degrees and minutes label for use in labeling map axes
%distbar                   Creates a checked distance bar with alternating checked ticks for a map plot.
%dms2ddeg                  Converts geographic coordinates from degrees, minutes, seconds to decimal degrees format
%edit_polygon              Interactive polygon editor application called by 'poly_mgr'
%editnote                  Dialog for adding or editing text annotations on figures. Can be called without arguments to
%errorbox                  Generates a simple message box to acknowledge error conditions.  The
%exportfig                 Exports the current figure in the specified format with uicontrol printing suppressed, prompting for filename and path
%fillseg                   Fills polygon line segments separated by [nan nan] (eg. Coastline data)
%find_stations             Generates arrays of locations and labels for a range of CTD stations in a reference transect
%gcepoly2kml               Creates a Google Earth KML file from a GCE geographic polygon structure with fields 'SiteCode' and 'Polygon'
%gen2mat                   Reads .GEN files created by Arcview's UNGENERATE command into a MATLAB array
%geoarea_mouse             Calculates geographic surface area of a rectangle selected with the mouse
%geocenter                 Returns the weighted geographic center of a polygon
%get_bbox                  Returns a bounding box based on dragging a rectangle on a map figure, optionally plotting the result
%gps2river                 Matches geographic coordinates to rivers based on bounding polygons in 'thalweg_bnd.mat'
%gps2riverdist             Computes transect distances along Thalweg lines from geographic coordinates
%gps2thalweg               Generates a high resolution Thalweg line from an array of GPS locations along a river channel
%gpsaxis                   Returns axis scaling array and aspect ratio to plot 'gps' on a map
%gpsdist                   Calculates great circle distance between geographic coordinates (longitude/latitude pairs)
%gpsdistk                  Computes distance (in km) between GPS coordinates 'gps1' and 'gps2'
%ins_coord                 Inserts gps coordinates into a map longitude/latitude array to replace a specified segment
%insetmap                  Opens a map figure window that displays the specified boundaries or the boundaries
%insidepoly                Determines if points are inside/outside of a polygon
%labeledit                 Text editing dialog box, to be used as a callback function associated with text objects.
%lasso                     Builds an array of positions defining a closed polygon of specified shape
%load_drg                  Loads a clipped USGS DRG map file in TIFF format, and uses the
%loadmap                   Loads a MATLAB map figure, centers it onscreen, and updates the title and axes labels
%locations2dataset         Generates a data set in GCE data structure format from a geographic location structure
%map_patch                 Plot data values on a map figure as colored patches
%mapaxis                   Axis limits dialog box for map plots
%mapbuttons                Creates map toggle buttons to enable zoom, pan and probe functions via
%mapclick                  function called by 'mapbuttons.m' to handle mouse clicks on maps
%mapcolor                  Dialog called by 'mapmenu' for selecting map colors
%mapimage                  plot a colormapped raster image on a map plot
%mapmenu                   Switchyard function to create custom map menu and handle callbacks
%mapscale                  Map scale dialog box function
%mapticks                  Formats plot tickmarks in decimal degrees format with degree symbols or degrees and minutes format
%merge_polygons            Merges polygons stored in GCE Maptools .ply files to form a new compbined database
%movepoly                  Moves a polygon (line object) to new center coordinates selected with the mouse.
%newpoly                   New polygon dialog called by 'surfintegrate'
%plot_locations            Plots sampling locations on a map and generates a figure legend
%plot_shapefile_polygons   plots polygons in an ArcGIS shapefile on a MATLAB figure
%plotmap                   Creates a new figure window and generates a continuous line plot of the coordinates in 'map'
%plotrect                  Plots a rectangular bounding box around an array of coordinates
%plotseg                   Plot a specific segment of a coastline data file using the 'fillseg' function
%plotstations              Plots station labels on a map, centered over the locations given by lon, lat
%pointlabels               Plots point labels for map coordinates (if 'str' is omitted,
%poly2thalweg_bnd          Updates Thalweg boundary data in 'thalweg_bnd.mat' by parsing polygons from a polygon manager (.ply) file
%poly_mgr                  Polygon management utility called by 'plotmap'
%poly_title                Dialog called by 'poly_mgr' to update the title of a polygon
%polyvert                  Polygon numerical vertices dialog called by 'createpoly'
%r12_axistitles            Updates axis titles in R11-saved figures to support zooming in R12
%radcalc                   Returns the radius of the circle with origin x(1),y(1) and peripheral point x(2),y(2)
%read_seg                  Reads the array of segments specified by 'segs' in 'mapdata'
%rec2paral                 Shifts the top of a rectangle or parallelogram represented by the line handle 'h' by the amount 'topoffset'
%repl_seg                  Replaces the contents of segment 'segnum' in 'mapdata' with 'coords'
%riverdist2gps             Returns geographic coordinates for transect distances along Thalweg lines for a specified river
%rotateyticks              Converts Y-axis tick labels to text strings rotated at a 90° angle
%roundsig                  Rounds numbers to the indicated significant digits using the method specified
%shapefile2gcepoly         Creates a GCE geographic coordinate structure for polygons stored in an ArcGIS shapefile
%sitearea                  Calculates the surface area entrained by a site polygon in lat/lon degrees or utm.
%split_seg                 Inserts NaN values to split a longitude/latitude array at specified positions
%textedit                  Text editing dialog box, to be used as a callback function associated with text objects.
%thalweg2stations          Generates a structure of CTD profiling station descriptions and coordinates from a Thalweg reference data set
%trandist                  Function for computing upriver distance of coordinates 'gps' relative to reference track 'ref'.
%update_ctd_stations       Updates CTD stations in 'ctd_stations.mat' based on Thalweg reference transects
%update_thalweg            Updates Thalweg reference data for a named transect in 'thalweg_ref.mat' and 'thalweg_bnd.mat'
%updateaxis                Updates map plot axis limits to a geographically-correct aspect ratio
%upgrade_maps              Upgrades maps figures to include the latest versions of the GCE polygon database, map menus and buttons
%utm2deg                   Converts geographic coordinates from UTM to decimal degrees (lon,lat)
%writepoly                 Writes full geographic information about map polygons to disk in tab-delimited
%writepoly2                Writes specific geographic information about map polygons to disk in tabular
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                               Data Harvesting and Processing Workflow Function                               
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%calc_well_waterlevel      Adds a calculated water level column to a well data set based on sensor elevation and sensor depth
%correct_well_pressure     Corrects groundwater well pressure for atmospheric pressure, optionally offset from pressure at time 0
%depth2waterlevel          calculates water level in meters from depth based on mooring elevation in m (NAVD88 datum)
%harvest_dashboard         Generates plots and an XML file describing status of each variable to support harvest dashboard web page development
%harvest_datapages_xml     Generates xml-based data distribution pages for harvested data files for a specified station
%harvest_usgs_general      Harvests USGS gauging station data for generates standard data sets, plots and index pages for the web
%harvest_usgs_general_xml  Harvests USGS gauging station data and generates standard data sets, plots and xml index pages for the web
%harvest_webplots_xml      Generates web plots for harvested data using stored plot configuration information for a station
%interp_parms_by_salinity  Generates a derived data set containing interpolated variable measurements for a target salinity
%lter_allsite_climate      Workflow that generates integrated daily and monthly climate description datasets for a list of LTER stations
%lter_climate_monthly      Workflow that generates integrated monthly LTER climate description datasets from integrated daily data
%split_toa5                Splits a Campbell Scientific Instruments TOA5 file into daily or hourly files
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                                              Toolbox Extensions                                              
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%DTchan2gce                Converts Data Turbine channel data returned from DTalign into a GCE Data Structure
%DTharvestStructGCE        Generates an options structure for use with DTharvest.m containing a workflow to generate a GCE Data Structure
%DTsource2gce              Imports data channels from a Data Turbine source to create a GCE Data Structure
%extensions                GCE Data Toolbox custom extension handler
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                                 Demonstration Functions for Toolbox Training                                 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%csi2struct.csv            Miscellaneous support file
%data_harvester            Data harvester function template for post-processing streaming sensor data cached on a file system
%data_harvester_sql        Data harvester function template for post-processing streaming sensor data retrieved from an SQL data source
%data_submission_template.xlsMiscellaneous support file
%data_submission_template_instructions.rtfMiscellaneous support file
%gap_fill_report           Generates or appends to a text report of dates gap-filled by pad_date_gaps.m
%gce2odm                   Converts a GCE Data Structure to an ODM-compatible data table
%harvest_dashboard.css     Miscellaneous support file
%harvest_dashboard_badvars.cssMiscellaneous support file
%harvest_dashboard_select.cssMiscellaneous support file
%harvest_details.css       Miscellaneous support file
%harvest_details.js        Miscellaneous support file
%harvest_info              Master harvest configuration information retrieval function for use with harvest_datapages_xml
%harvest_plot_info         Master plot configuration information retrieval function for use with harvest_plots_xml
%harvest_webpage.css       Miscellaneous support file
%list_utils_dashboard.js   Miscellaneous support file
%localpath                 Returns a localized path name stored as a variable in /userdata/localpaths.mat
%process_toa5              test processing script for sample Campbell data
%sample_data_toa5.dat      Miscellaneous support file
%
