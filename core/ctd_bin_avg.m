function [s2,msg] = ctd_bin_avg(s,depcol,castcol,agcols,datacols,bin_top,bin_interval,emptybinopt,flagopt,qcrules,interp_method)
%Generates a bin-averaged and interpolated data set from a CTD profile
%
%syntax: [s2,msg] = ctd_bin_avg(s,depcol,castcol,agcols,datacols,bin_top,bin_interval,emptybinopt,flagopt,qcrules,interp_method)
%
%input:
%  s = combined ctd cast data set from 'minicruise_ctd_combine'
%  depcol = name or index of depth or pressure column to use for binning
%  castcol = name of numeric cast number column for grouping observations
%  agcols = other columns to group data by prior to binning (default = [] for none)
%  datacols = data columns to bin-average (default = all data columns other than depcol and agcols)
%  bin_top = top bin in meters (default = 1)
%  bin_interval = bin interval in meters (default = 0.25)
%  emptybinopt = option to include empty bins in the output structure
%     0 = no
%     1 = yes (default)
%  flagopt = option for clearing QA/QC flagged values prior to aggregation
%        0 = retain flagged values
%        1 = remove all flagged values (convert to NaN/'')
%        character array = selectively remove only values assigned any flag in the array
%        default = 'IX' - remove values flagged I or X
%  qcrules = 4-column cell array defining Q/C rules to add to the output structure to flag statistics
%       based on precence of missing and/or flagged values in each aggregate, as follows:
%         col 1: type of criteria ('flagged' or 'missing')
%         col 2: numerical criteria (character array containing a number >= 0)
%         col 3: units of criteria ('percent','count')
%         col 4: flag to assign (single character)
%       example:
%         {'flagged','0','count','Q'; 'missing','10','percent','Q'} --> 
%            rules: col_Flagged_[colname]>0='Q';col_Percent_Missing_[colname]>10='Q' 
%       default if omitted: 
%         {'missing','1','count','Q'}
%  interp_method = interpolation method (see 'interp1' help; default = 'spline'; no interpolation = 'none') 
%
%output:
%  s2 = bin-averaged data structure
%  msg = text of any error message
%
%(c)2009-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 20-May-2011

s2 = [];
msg = '';

if nargin >= 3

   if gce_valid(s,'data')
      
      %init column indices
      Idepcol = [];
      Iagcols = [];
      Idatacols = [];
      
      %validate depcol, look up name or index as appropriate
      if ~isnumeric(depcol)
         Idepcol = name2col(s,depcol);
      else
         depcol = s.name{Idepcol};
      end
      
      %supply defaults for missing input
      if exist('bin_top','var') ~= 1
         bin_top = 1;
      end
      
      if exist('agcols','var') ~= 1
         agcols = [];
      elseif ~isnumeric(agcols)
         Iagcols = name2col(s,agcols);
      else
         agcols = s.name(agcols);
      end
      
      if exist('datacols','var') ~= 1
         datacols = [];
      end
      if isempty(datacols)
         %get array of all data/calculation columns no in depcol and agcols
         types = get_type(s,'variabletype');  %get array of column variable types
         Idatacols = setdiff(find(strcmp(types,'data') | strcmp(types,'calculation')),[depcol,agcols(:)']);
         datacols = s.name(Idatacols);  %get column names
      elseif ~isnumeric(datacols)
         Idatacols = name2col(s,datacols);  %look up indices for column names
      else
         datacols = s.name(datacols);  %look up column names from indices
      end

      if exist('bin_interval','var') ~= 1
         bin_interval = [];
      end
      if isempty(bin_interval)
         bin_interval = 0.25;
      end
      
      if exist('emptybinopt','var') ~= 1
         emptybinopt = [];
      end
      if isempty(emptybinopt)
         emptybinopt = 1;
      end
      
      if exist('flagopt','var') ~= 1
         flagopt = [];
      end
      if isempty(flagopt)
         flagopt = 'IX';
      end
      
      if exist('qcrules','var') ~= 1
         qcrules = {'missing','1','count','Q'};
      end
      
      if exist('interp_method','var') ~= 1
         interp_method = '';
      end
      if isempty(interp_method)
         interp_method = 'spline';
      end
      
      if strcmp(interp_method,'none')
         interp = 0;
      else
         interp = 1;
      end
      
      %check for column matches in structure
      if length(Iagcols) == length(agcols) && length(Idatacols) == length(datacols) && ~isempty(Idepcol) ...
            && strcmp(get_type(s,'datatype',castcol),'d')
         
         %determine depth bin range
         dep = extract(s,Idepcol);
         dep_max = max(no_nan(dep));
         bintop = bin_top - bin_interval .* 0.5;  %center top bin relative to interval
         dep_range = [bintop:bin_interval:dep_max+bin_interval-.001];
         binbot = max(dep_range);
         
         %generate binned data set         
         [s_tmp,msg0] = aggr_bindata(s,depcol,[bintop,binbot,bin_interval], ...
            emptybinopt,flagopt,Iagcols,Idatacols,qcrules);

         %finalize data structure and bin-average within casts
         if ~isempty(s_tmp)
            
            %init array of original/final stat column names
            depcols = {[depcol,'_Bin_Middle'],[depcol,'_Bin_Mean'],['Num_',datacols{1}],['Missing_',datacols{1}]};
            statcols = [concatcellcols([repmat({'Mean_'},length(datacols),1),datacols(:)])' ; datacols(:)'];

            Idepcols = name2col(s_tmp,depcols);
            Istatcols = name2col(s_tmp,statcols(1,:));
            
            %lock flags for statcols
            s_tmp = flag_locks(s_tmp,'lock',statcols(1,:));
            
            %generate sorted array of columns for re-ordering back to original column positions
            [tmp,Isort] = sort(Iagcols);
            Icopycols = [Isort,Idepcols,Istatcols];
            
            %init output data set with re-sorted grouping columns
            s2 = copycols(s_tmp,Icopycols);

            if ~isempty(s2)
               
               s2 = rename_column(s2,[depcol,'_Bin_Middle'],depcol);  %rename depth_bin_middle to depth
               s2 = rename_column(s2,['Num_',datacols{1}],'Num_Averaged','Number of valid observations per bin included in the average');
               s2 = rename_column(s2,['Missing_',datacols{1}],'Num_Missing','Number of missing observations per bin');

               if interp == 1

                  %extract bin fields
                  bin_middle = extract(s2,depcol);
                  bin_mean = extract(s2,[depcol,'_Bin_Mean']);
                  
                  %check for cast column
                  cast = extract(s2,castcol);
                  casts = unique(cast);  %get unique list of casts for sub-setting
                  
                  %interpolate and rename stat columns
                  for n = 1:size(statcols,2)

                     %get column index, description, values
                     Icol = name2col(s2,statcols{1,n});
                     colname = s2.name{Icol};
                     desc = s2.description{Icol};
                     vals = extract(s2,Icol);

                     %init new value array
                     newvals = ones(length(vals),1) .* NaN;

                     %loop through casts to perform interpolation
                     for m = 1:length(casts)
                        Icast = find(cast == casts(m));      %get index of cast records
                        x = bin_mean(Icast);                 %subset depth_bin_mean values
                        y = vals(Icast);                     %subset data values
                        Ivalid = find(~isnan(x)&~isnan(y));  %get index of non-NaN values for interpolation
                        x0 = bin_middle(Icast);              %subset depth_bin_middle as x0
                        try
                           y0 = interp1(x(Ivalid),y(Ivalid),x0,interp_method);  %perform interpolation
                        catch
                           try
                              y0 = interp1(x(Ivalid),y(Ivalid),x0,'linear');  %fall back to linear interp on error
                           catch
                              y0 = repmat(NaN,length(x0),1);  %return NaN if interpolation fails
                           end
                        end
                        Inan = find(isnan(x));  %get index of original NaN positions
                        y0(Inan) = NaN;       %restore NaNs to data array to prevent extrapolation
                        newvals(Icast) = y0;  %update main data array
                     end

                     %rename column and revise description                  
                     s2 = rename_column(s2,statcols{1,n},statcols{2,n},[desc,' calculated by bin-averaging measured values from ', ...
                           num2str(bin_top),'m to ',num2str(binbot),'m in intervals of ',num2str(bin_interval),'m, using ', ...
                           interp_method,' interpolation of the mean depth per bin and mean measured value to center ', ...
                           'the values within respective bins']);  


                     %update q/c rules for missing, flagged
                     colname = statcols{2,n};
                     crit = s2.criteria{Icol};
                     crit = strrep(crit,['col_Num_',colname],'col_Num_Averaged');
                     crit = strrep(crit,['col_Missing_',colname],'col_Num_Missing');
                     s2.criteria{Icol} = crit;

                     %update column values
                     [s2,msg0] = update_data(s2,Icol,newvals,0); 

                     if isempty(s2)
                        msg = ['an error occurred bin-averaging the ',colname,' column'];
                        break  %stop processing
                     end

                  end

                  %delete depth_bin_mean from final structure
                  s2 = deletecols(s2,[depcol,'_Bin_Mean']);
               
               else
                  
                  %interpolate and rename stat columns
                  for n = 1:size(statcols,2)

                     %get column index, description, values
                     Icol = name2col(s2,statcols{1,n});
                     colname = s2.name{Icol};
                     desc = s2.description{Icol};
                     vals = extract(s2,Icol);

                     %rename column and revise description                  
                     s2 = rename_column(s2,statcols{1,n},statcols{2,n},[desc,' calculated by bin-averaging measured values from ', ...
                           num2str(bintop),'m to ',num2str(binbot),'m in intervals of ',num2str(bin_interval),'m']);

                     %update q/c rules for missing, flagged
                     colname = statcols{2,n};
                     crit = s2.criteria{Icol};
                     crit = strrep(crit,['col_Num_',colname],'col_Num_Averaged');
                     crit = strrep(crit,['col_Missing_',colname],'col_Num_Missing');
                     s2.criteria{Icol} = crit;

                  end
                  
                  s2 = rename_column(s2,[depcol,'_Bin_Mean'],[depcol,'_Mean']);  %rename depth_bin_mean to depth

               end
                              
            else
               msg = 'an error occurred finalizing the bin-averaged structure';
            end            
            
         else
            msg = ['an error occurred running aggr_bindata: ',msg0];
         end
         
      else
         msg = 'one or more expected columns are missing from the data structure';
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments';
end