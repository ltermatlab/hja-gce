function [s2,msg] = add_tide_stage(s,col_date,col_depth,stagecols,timestep,polyorder)
%Generates text or numeric tide stage columns from a selected depth or pressure column in a GCE data structure
%based on analysis of depth or pressure data using the 'tide_high_low' and 'depth2tidestage' functions
%
%syntax: [s2,msg] = add_tide_stage(s,col_date,col_depth,stagecols,timestep,polyorder)
%
%input:
%  s = GCE data structure to evaluate (struct; required)
%  col_date = name or index of serial date column (integer or string; optional; 
%     default = automatically determined from date/time columns)
%  col_depth = name or index of depth or pressure column (integer or string; optional; 
%     default = 'Depth' or 'Pressure')
%  stagecols = stage column types to add (string; optional; default = 'both')
%     'text' = TideStage column containing text tide stage codes ('Low','EarlyFlood','MidFlood',
%        'LateFlood','High','EarlyEbb','MidEbb','LateEbb')
%     'numeric' = TideBin column containing numeric tide stage codes (1 = low, 2 = early flood,
%        3 = mid flood, 4 = late flood, 5 = high, 6 = early ebb, 7 = mid ebb, 8 = late ebb)
%     'both' = both TideStage and TideBin columns (default)
%  timestep = time step interval in minutes for analyzing high/low tide peaks in interpolated 
%     depth/pressure data (integer; optional; default = 5)
%  polyorder = polynomial order for fitting high and low tide peaks (integer; optional; default = 3)
%
%output:
%  s2 = updated data structure containing 
%  msg = text of any error message
%
%(c)2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 20-Feb-2015

s2 = [];
msg = '';

if nargin >= 1 && gce_valid(s,'data') == 1

   %validate stagecols
   if exist('stagecols','var') ~= 1
      stagecols = 'both';
   elseif ~inlist(stagecols,{'text','numeric','both'},'insensitive')
      stagecols = 'both';
   end
   
   %check for timestep
   if exist('timestep','var') ~= 1
      timestep = 5;
   end
   
   %check for polyorder
   if exist('polyorder','var') ~= 1
      polyorder = 3;
   end

   %get date values
   if exist('col_date','var') ~= 1 || isempty(col_date)
      dt = get_studydates(s);
   else
      dt = get_studydates(s,col_date);      
   end
   
   %check for valid date array
   if ~isempty(dt)
      
      %look up depth/pressure column if omitted
      if exist('col_depth','var') ~= 1 || isempty(col_depth)
         col_depth = [];
         depcollist = {'Depth_Corrected','Depth','Pressure_Corrected','Pressure'};
         for n = 1:length(depcollist)
            col_depth = name2col(s,depcollist{n},0,'f');
            if ~isempty(col_depth)
               col_depth = col_depth(1);
               break
            end
         end
      end

      %get depth values
      if ~isempty(col_depth)
         depth = extract(s,col_depth);  %extract depth
      else
         depth = [];
      end
      
      %check for valid depth values
      if ~isempty(depth) && isnumeric(depth)
         
         %calculate tide stage using tide_high_low and depth2tidestage
         [stage,tidebin] = depth2tidestage(dt,depth,timestep,polyorder);
         
         if ~isempty(stage) && ~isempty(tidebin)
            
            %copy initial structure
            s2 = s;
            
            %set column position to right after depth/pressure column
            pos = col_depth + 1;
            
            %add text stage
            if strcmpi(stagecols,'both') || strcmpi(stagecols,'text')
               s2 = addcol(s2, ...
                  stage, ...
                  'TideStage', ...
                  'none', ...
                  'Nominal tide stage code indicating phase in an 8-part tidal cycle', ...
                  's', ...
                  'code', ...
                  'none', ...
                  0, ...
                  'flag_notinlist(x,''Low,EarlyFlood,MidFlood,LateFlood,High,EarlyEbb,MidEbb,LateEbb'')=''Q''', ...
                  pos);
               pos = pos + 1;
            end
            
            %add numeric stage
            if strcmpi(stagecols,'both') || strcmpi(stagecols,'numeric')
               s2 = addcol(s2, ...
                  tidebin, ...
                  'TideBin', ...
                  'none', ...
                  'Nominal tide stage bin indicating phase in an 8-part tidal cycle', ...
                  'd', ...
                  'code', ...
                  'discrete', ...
                  0, ...
                  'x<1=''I'';x>8=''I''', ...
                  pos);
            end

            %define code definition metadata
            newmeta_text = {'Data','ValueCodes', ...
               ['TideStage: Low = low tide, EarlyFlood = early flood tide, MidFlood = mid flood tide, ', ...
               'LateFlood = late flood tide, High = high tide, EarlyEbb = early ebb tide, MidEbb = mid ebb tide, ', ...
               'LateEbb = late ebb tide']};
            newmeta_numeric = {'Data','ValueCodes', ...
               ['TideBin: 1 = low tide, 2 = early flood tide, 3 = mid flood tide, ', ...
               '4 = late flood tide, 5 = high tide, 6 = early ebb tide, 7 = mid ebb tide, ', ...
               '8 = late ebb tide']};
            
            %add code definition metadata fragments to existing definitions
            if strcmpi(stagecols,'text')
               meta = newmeta_text;
            elseif strcmpi(stagecols,'numeric')
               meta = newmeta_numeric;
            else
               meta = [newmeta_text ; newmeta_numeric];
            end            
            s2 = addmeta(s2,meta,0,'add_tide_stage',1);

         else
            msg = 'an error occurred calculating tide stage (''tide_high_low'' did not return peak times)';
         end
         
      else
         msg = 'invalid depth or pressure column (or column could not be determined)';
      end      
      
   else
      msg = 'invalid serial date column (or serial date column could not be determined)';
   end
   
else
   if nargin == 0
      msg = 'insufficient arguments for function';
   else
      msg = 'invalid data structure';
   end
end