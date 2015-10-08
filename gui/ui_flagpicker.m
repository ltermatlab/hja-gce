function ui_flagpicker(op,s,pos,h,cb,enable)
%Adds a Q/C flag picker popupmenu and edit button to a GUI figure at a specified position
%
%syntax: ui_flagpicker(op,s,pos,h,cb,enable)
%
%input:
%  op = operation to perform
%    'add' = add controls to figure
%  s = data structure containing flag definitions
%  pos = position for the uicontrols in pixels
%     2-element array of left and bottom position (with width 260px and height 25px)
%     4-element array of left bottom width height
%  h = handle of the figure window to place the controls (default = gcf)
%  cb = callback to execute upon flag selection changes (default = '')
%  enable = option to enable the uicontrols on startup
%     'no' = not enabled
%     'yes' = enabled (default)
%
%output:
%  none
%
%usage notes:
%  1) total uicontrol width = 260px and height = 25px
%  2) to retrieve the selected flag, use the following procedure as an example:
%        uih = findobj(gcf,'Tag','popFlagChoice');
%        Iflag = get(uih,'Value');
%        flagcodes = get(uih,'Userdata');
%        flag = flagcodes{Iflag};
%
%(c)2011-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 06-Feb-2012

if nargin >= 1

   switch op

      case 'add'  %add controls to figure

         if exist('s','var') == 1 && gce_valid(s,'data') == 1
            
            if exist('enable','var') ~= 1 || ~ischar(enable) || ~strcmp(enable,'off')
               enable = 'on';
            end

            %supply defaults for omitted arguments
            if exist('pos','var') ~= 1 || length(pos) < 2
               pos = [50 50 260 25];
            elseif length(pos) < 4
               pos = [pos(1:2) 260 25];
            end

            if exist('h','var') ~= 1
               h = gcf;
            end

            if exist('cb','var') ~= 1
               cb = '';
            end

            %look up flag definitions from structure if not provided as input
            flagdefs = lookupmeta(s,'Data','Codes');

            %parse flag list from definition strings
            flaglist = strrep(flagdefs,'Flags: ','');  %strip out legacy code leader
            if ~isempty(strfind(flaglist,'|'))
               flaglist = splitstr(flaglist,'|');
            elseif ~isempty(strfind(flaglist,','))
               flaglist = splitstr(flaglist,',');
            else
               flaglist = cellstr(flaglist);  %no delimiter - assume single entry
            end

            %format flags for listbox string, userdata
            if ~cellfun('isempty',flaglist)
               flaglist0 = flaglist;
               flaglist = [];
               flagcodes = [];
               for n = 1:length(flaglist0)
                  tmp = splitstr(flaglist0{n},'=');
                  if length(tmp) == 2
                     flaglist = [flaglist ; {[tmp{1},' -- ',tmp{2}]}];
                     flagcodes = [flagcodes ; tmp(1)];
                  end
               end
               flaglist = [{'< no flag assigned >'} ; flaglist];
               flagcodes = [{''} ; flagcodes];
            else
               flaglist = {'< no flag assigned >';'Q -- questionable value';'I -- invalid value (out of range)'};
               flagcodes = [{''};{'Q'};{'I'}];
            end

            %add uicontrols at specified position
            uicontrol(...
               'Parent',h,...
               'FontSize',9,...
               'BackgroundColor',[1 1 1], ...
               'Position',[pos(1) pos(2) pos(3)-60 pos(4)-2],...
               'String',char(flaglist),...
               'Style','popupmenu',...
               'Value',1,...
               'UserData',flagcodes, ...
               'Callback',cb, ...
               'Enable',enable, ...
               'Tag','popFlagChoice');

            uicontrol(...
               'Parent',h, ...
               'FontSize',9,...
               'Position',[pos(1)+pos(3)-50 pos(2) 50 pos(4)], ...
               'String','Flags', ...
               'Callback','ui_flagpicker(''flaglist'')', ...
               'Enable',enable, ...
               'TooltipString','Open a dialog to add or edit flag codes and definitions', ...
               'Tag','cmdFlagList');

         end

      case 'flaglist'  %open flag code editor dialog

         %get ui handle of flag popupmenu
         uih_flagchoice = findobj(gcf,'Tag','popFlagChoice');
         uih_flaglist = findobj(gcf,'Tag','cmdFlagList');

         %format flags and call ui_flagdefs function
         if ~isempty(uih_flagchoice) && ~isempty(uih_flaglist)
            defs = cellstr(get(uih_flagchoice,'String'));  %convert list to cell array
            flagdefs = cell2commas(strrep(defs(2:end),'--','='));  %generate flag def metadata, skipping no flag option
            flagmeta = [{'Data'},{'Codes'},{flagdefs}];  %format flag codes as metadata field for dialog
            ui_flagdefs('init',flagmeta,uih_flaglist,'ui_flagpicker(''flaglist2'')')  %call flag editing dialog
         end

      case 'flaglist2'  %handle return data from flag code editor dialog

         %get ui handle of Flags button
         uih = findobj(gcf,'Tag','cmdFlagList');

         if length(uih) == 1

            %get cached return data from control
            data = get(uih,'UserData');
            set(uih,'UserData',[]);

            if ~isempty(data)

               %parse and format return data
               flaglist = data{1};
               if ~isempty(flaglist)
                  flaglist0 = splitstr(flaglist,',');
                  flaglist = [];
                  flagcodes = [];
                  for n = 1:length(flaglist0)
                     tmp = splitstr(flaglist0{n},'=');
                     if length(tmp) == 2
                        flaglist = [flaglist ; {[tmp{1},' -- ',tmp{2}]}];
                        flagcodes = [flagcodes ; tmp(1)];
                     end
                  end
               else
                  flaglist = {' '};
                  flagcodes = {''};
               end

               %pre-pend null assignment
               flaglist = [{'< no flag assigned >'} ; flaglist];
               flagcodes = [{''} ; flagcodes];

               %look up prior selected code in revised code list for resetting popup menu
               uih_flagdefs = findobj(gcf,'Tag','popFlagChoice');
               oldlist = get(uih_flagdefs,'UserData');
               oldval = get(uih_flagdefs,'Value');

               if ~isempty(oldlist)
                  newval = find(strcmp(flaglist,oldlist{oldval}));
                  if isempty(newval)
                     newval = 1;
                  else
                     newval = newval(1);
                  end
               else
                  newval = 1;
               end

               %cache new data, update uicontrol
               set(uih_flagdefs,'String',char(flaglist),'Value',newval,'UserData',flagcodes)

               %execute callback if defined
               cb = get(uih_flagdefs,'Callback');
               if ~isempty(cb)
                  try
                     eval(cb)
                  catch
                     %do nothing on error
                  end
               end

            end

         end

   end

end
