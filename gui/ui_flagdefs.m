function ui_flagdefs(op,meta,h_cb,cb)
%QA/QC flag definition and data anomalies editor dialog called by 'ui_editor'.
%
%syntax: ui_flagdefs(op,meta,h_cb,cb)
%
%inputs:
%  op = operation ('init' to open dialog)
%  meta = metadata array
%  h_cb = handle to store output in prior to executing callback
%     (output = [{flagdef},{anomalies}])
%  cb = callback to execute if the metadata contents have been changed
%
%outputs:
%  none
%
%(c)2002-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 03-Jul-2014

if nargin == 0
   op = 'init';
end

if strcmp(op,'init')
   
   if nargin >= 2
      
      %set anomaly enable/disable state based on whether called from editor
      anomvis = 'on';
      if length(findobj) > 1
         if ~strcmp(get(gcf,'Tag'),'dlgDSEditor');
            anomvis = 'off';
         end
      end
      
      %set blank callback handles if not specified
      if exist('h_cb','var') ~= 1
         h_cb = [];
      end
      
      if exist('cb','var') ~= 1
         cb = '';
      end
      
      %look up q/c info in metadata
      flagstr = lookupmeta(meta,'Data','Codes');
      anom = lookupmeta(meta,'Data','Anomalies');

      %check for excessive anomalies size, truncate and warn
      errmsg = '';
      if length(anom) > 100000
         errmsg = ['Warning: anomalies text exceeding 100000 characters cannot be displayed (remaining ', ...
            int2str(length(anom)-100000),' characters truncated)'];
         anom = anom(1:100000);
      end
      
      %format flags for display in controls
      if ~isempty(flagstr)
         if ~isempty(strfind(flagstr,'|'))
            flaglist = splitstr(flagstr,'|');
         elseif ~isempty(strfind(flagstr,','))
            flaglist = splitstr(flagstr,',');
         else
            flaglist = cellstr(flagstr);  %assume single entry
         end
         flagdefs = [];
         for n = 1:length(flaglist)
            tmp = splitstr(flaglist{n},'=');
            if length(tmp) == 2
               if ~isempty(tmp{1})
                  flagcode = tmp{1};
               else
                  flagcode = '?';
               end
               flagdefs = [flagdefs ; {flagcode(1)}, tmp(2)];
            else
               flagcode = [flagdefs{n},' '];
               flagdefs = [flagdefs ; {flagcode(1)},{'unspecified'}];
            end
         end
      else
         flaglist = {''};
         flagdefs = [{''},{''}];
      end
      
      %set figure metrics
      bgcolor = [0.9 0.9 0.9];
      res = get(0,'ScreenSize');
      if strcmp(anomvis,'on')
         fig_ht = 550;
         voffset = 220;
      else
         fig_ht = 330;
         voffset = 0;
      end
      
      %define figure position array
      figpos = [max(5,(res(3)-500).*0.5) max(30,(res(4)-fig_ht).*0.5) 500 fig_ht];
      
      %initialize dialog figure
      h_dlg = figure('Visible','off', ...
         'Color',[.95 .95 .95], ...
         'KeyPressFcn','figure(gcf)', ...
         'MenuBar','none', ...
         'ToolBar','none', ...
         'Name','Edit Flag Definitions/Anomalies', ...
         'NumberTitle','off', ...
         'Position',figpos, ...
         'Resize','off', ...
         'Tag','dlgFlagDefs', ...
         'DefaultuicontrolUnits','pixels');
      
      if mlversion >= 7
         set(h_dlg,'WindowStyle','normal')
         set(h_dlg,'DockControls','off')
      end
      
      %add frames
      uicontrol(...
         'Parent',h_dlg, ...
         'Style','frame', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'Position',[1 1 figpos(3) figpos(4)]);
      
      uicontrol(...
         'Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'Position',[5 50+voffset 492 270], ...
         'String',{ '' }, ...
         'Style','frame', ...
         'Tag','frame2');
      
      %render frame for anomalies controls
      if strcmp(anomvis,'on')
         uicontrol(...
            'Parent',h_dlg, ...
            'BackgroundColor',bgcolor, ...
            'Position',[5 45 492 220], ...
            'String',{ '' }, ...
            'Style','frame', ...
            'Tag','frame2');
      end
      
      uicontrol(...
         'Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'Position',[383 107+voffset 103 186], ...
         'String',{ '' }, ...
         'Style','frame', ...
         'Tag','frame1');
      
      uicontrol(...
         'Parent',h_dlg, ...
         'Style','text', ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[11 296+voffset 360 20], ...
         'String','Quality Control Flag Code Definitions', ...
         'Tag','lblListFlags');
      
      h_listFlags = uicontrol(...
         'Parent',h_dlg, ...
         'FontSize',10, ...
         'Position',[11 105+voffset 362 190], ...
         'BackgroundColor',[1 1 1], ...
         'String',flaglist, ...
         'Style','listbox', ...
         'Value',1, ...
         'Callback','ui_flagdefs(''select'')', ...
         'Tag','listFlags');
      
      h_cmdMoveFirst = uicontrol(...
         'Parent',h_dlg, ...
         'FontSize',9, ...
         'Position',[391 260+voffset 88 25], ...
         'String','Move First', ...
         'Callback','ui_flagdefs(''movefirst'')', ...
         'TooltipString','Move the selected Q/C code to the top of the list (highest priority)', ...
         'Tag','cmdMoveFirst');
      
      h_cmdMoveUp = uicontrol(...
         'Parent',h_dlg, ...
         'FontSize',9, ...
         'Position',[391 231+voffset 88 25], ...
         'String','Move Up', ...
         'Callback','ui_flagdefs(''moveup'')', ...
         'TooltipString','Move the selected Q/C code up the list (raise priority)', ...
         'Tag','cmdMoveUp');
      
      h_cmdMoveDown = uicontrol(...
         'Parent',h_dlg, ...
         'FontSize',9, ...
         'Position',[391 202+voffset 88 25], ...
         'String','Move Down', ...
         'Callback','ui_flagdefs(''movedown'')', ...
         'TooltipString','Move the selected Q/C code down the list (lower priority)', ...
         'Tag','cmdMoveDown');
      
      h_cmdMoveLast = uicontrol(...
         'Parent',h_dlg, ...
         'FontSize',9, ...
         'Position',[391 173+voffset 88 25], ...
         'String','Move Last', ...
         'Callback','ui_flagdefs(''movelast'')', ...
         'TooltipString','Move the selected Q/C code down to the end of the list (lowest priority)', ...
         'Tag','cmdMoveLast');
      
      h_cmdAdd = uicontrol(...
         'Parent',h_dlg, ...
         'FontSize',9, ...
         'Position',[391 144+voffset 88 25], ...
         'String','Add New', ...
         'Callback','ui_flagdefs(''add'')', ...
         'TooltipString','Add a new Q/C code and definition (define using fields below list)', ...
         'Tag','cmdAdd');
      
      h_cmdDelete = uicontrol(...
         'Parent',h_dlg, ...
         'FontSize',9, ...
         'Position',[391 115+voffset 88 25], ...
         'String','Delete', ...
         'Callback','ui_flagdefs(''delete'')', ...
         'TooltipString','Delete the selected Q/C code and definition', ...
         'Tag','cmdDelete');
      
      uicontrol(...
         'Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 .8], ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'Position',[12 66+voffset 70 21], ...
         'String','Definition:', ...
         'Style','text', ...
         'Tag','text6');
      
      h_editFlagCode = uicontrol(...
         'Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[82 68+voffset 25 22], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'String',flagdefs{1,1}, ...
         'Tag','editFlagCode');
      
      uicontrol(...
         'Parent',h_dlg, ...
         'Style','text', ...
         'Position',[107 67+voffset 20 21], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'String','=');
      
      h_editFlagDef = uicontrol(...
         'Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[127 67+voffset 250 23], ...
         'FontSize',9, ...
         'BackgroundColor',[1 1 1], ...
         'HorizontalAlignment','left', ...
         'String',flagdefs{1,2}, ...
         'Callback','ui_flagdefs(''update'')', ...
         'Tag','editFlagDef');
      
      uicontrol(...
         'Parent',h_dlg, ...
         'FontSize',9, ...
         'Position',[391 67+voffset 90 25], ...
         'String','Update', ...
         'Callback','ui_flagdefs(''update'')', ...
         'TooltipString','Update the list to reflect code or definition changes', ...
         'Tag','cmdUpdate');
      
      %render anomalies field if necessary
      if strcmp(anomvis,'on')
         
         uicontrol(...
            'Parent',h_dlg, ...
            'Style','text', ...
            'HorizontalAlignment','left', ...
            'BackgroundColor',bgcolor, ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[15 234 150 21], ...
            'String','Data Anomalies Report', ...
            'Tag','lblAnom');
         
         uicontrol(...
            'Parent',h_dlg, ...
            'Style','pushbutton', ...
            'FontSize',9, ...
            'Position',[425 235 60 24], ...
            'String','Clear', ...
            'Callback','ui_flagdefs(''clear'')', ...
            'TooltipString','Clear the Data Anomalies field', ...
            'Tag','cmdClear');
         
         h_editAnom = uicontrol(...
            'Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',9, ...
            'HorizontalAlignment','left', ...
            'Position',[15 50 470 180], ...
            'Min',1, ...
            'Max',3, ...
            'String',anom, ...
            'Tag','editAnom');
         
      else
         h_editAnom = [];
      end
      
      h_cmdCancel = uicontrol(...
         'Parent',h_dlg, ...
         'FontSize',9, ...
         'Position',[10 10 90 25], ...
         'String','Cancel', ...
         'Callback','ui_flagdefs(''cancel'')', ...
         'TooltipString','Close the dialog without updating the data structure', ...
         'Tag','cmdCancel');
      
      h_cmdEval = uicontrol(...
         'Parent',h_dlg, ...
         'FontSize',9, ...
         'Position',[400 10 90 25], ...
         'String','Accept', ...
         'Callback','ui_flagdefs(''eval'')', ...
         'TooltipString','Accept changes and update the data set', ...
         'Tag','cmdEval');
      
      uih = struct( ...
         'meta',{meta}, ...
         'flagdefs',{flagdefs}, ...
         'h_cb',h_cb, ...
         'cb',cb, ...
         'listFlags',h_listFlags, ...
         'cmdEval',h_cmdEval, ...
         'cmdCancel',h_cmdCancel, ...
         'editFlagDef',h_editFlagDef, ...
         'editFlagCode',h_editFlagCode, ...
         'editAnom',h_editAnom, ...
         'cmdAdd',h_cmdAdd, ...
         'cmdDelete',h_cmdDelete, ...
         'cmdMoveFirst',h_cmdMoveFirst, ...
         'cmdMoveDown',h_cmdMoveDown, ...
         'cmdMoveUp',h_cmdMoveUp, ...
         'cmdMoveLast',h_cmdMoveLast);
      
      set(h_dlg,'UserData',uih,'Visible','on')
      
      ui_flagdefs('select')
      
      %display truncation warning
      if ~isempty(errmsg)
         messagebox('init',errmsg,'','Warning',[0.95 0.95 0.95],0)
      end
      
   end
   
elseif strcmp(get(gcf,'Tag'),'dlgFlagDefs')
   
   h_dlg = gcf;
   uih = get(h_dlg,'UserData');
   flaglist = get(uih.listFlags,'String');
   Isel = get(uih.listFlags,'Value');
   
   switch op
      
      case 'cancel'
         
         delete(h_dlg)
         drawnow
         ui_aboutgce('reopen')  %check for last window
         
      case 'eval'
         
         %get flag definitions and anomalies from metadata
         meta = uih.meta;
         flags0 = lookupmeta(meta,'Data','Codes');
         anom0 = lookupmeta(meta,'Data','Anomalies');
         
         %format flaglist for string comparison
         flags = cell2commas(flaglist);
         
         %get edited anomalies
         if ~isempty(uih.editAnom)
            anom = deblank(get(uih.editAnom,'String'));
         else
            anom = anom0;  %use metadata anomalies if field disabled
         end
         
         %convert multi-row anomalies into single character array
         if size(anom,1) > 1
            str = concatcellcols(cellstr(anom)',' ');
            anom = str{:};
         end
         
         %get parent figure of callback handle
         h_fig = parent_figure(uih.h_cb);
         
         %shut down dialog
         delete(h_dlg)
         drawnow
         
         %check for changes, execute callback if needed
         if strcmp(flags0,flags) ~= 1 || strcmp(anom0,anom) ~= 1
            
            try
               if ~isempty(h_fig)
                  figure(h_fig)
                  set(uih.h_cb,'UserData',[{flags},{anom}])
                  eval(uih.cb)
               else
                  messagebox('init','Original editor window could not be opened - update cancelled', ...
                     [],'Error',[.9 .9 .9])
               end
            catch
               messagebox('init','Errors occurred returning revisions to the editor - update cancelled', ...
                  [],'Error',[.9 .9 .9])
            end
            
         end
         
      case 'select'  %populate definition fields on flag selection
         
         set(uih.editFlagCode,'String',uih.flagdefs{Isel,1})
         set(uih.editFlagDef,'String',uih.flagdefs{Isel,2})
         drawnow
         
      case 'update'  %update master definition list
         
         flagcode = deblank(get(uih.editFlagCode,'String'));
         flagdef = deblank(get(uih.editFlagDef,'String'));
         
         if ~isempty(flagcode) && ~isempty(flagdef)
            uih.flagdefs{Isel,1} = flagcode(1);
            uih.flagdefs{Isel,2} = flagdef;
            str = get(uih.listFlags,'String');
            str{Isel} = [flagcode(1),' = ',flagdef];
            set(h_dlg,'UserData',uih)
            set(uih.listFlags,'String',str)
            drawnow
         else
            messagebox('init', ...
               'Flag codes and definitions cannot be empty strings', ...
               [],'Error',[.9 .9 .9])
         end
         
      case 'add'  %add a new definition
         
         flaglist = [flaglist ; {''}];
         uih.flagdefs = [uih.flagdefs ; {''},{''}];
         set(h_dlg,'UserData',uih)
         set(uih.listFlags,'String',flaglist,'Value',length(flaglist))
         set(uih.editFlagCode,'String','')
         set(uih.editFlagDef,'String','')
         
      case 'delete'  %delete a definition in the list
         
         if length(flaglist) > 1
            Iall = (1:length(flaglist))';
            Ilist = Iall(Iall~=Isel);
            uih.flagdefs = uih.flagdefs(Ilist,:);
            set(uih.listFlags,'String',flaglist(Ilist),'Value',max(1,Isel-1))
         else
            set(uih.listFlags,'String',{''},'Value',1)
            uih.flagdefs = [{''},{''}];
         end
         set(h_dlg,'UserData',uih)
         
         ui_flagdefs('select')
         
      case 'movefirst'  %move definition to the top
         
         if Isel > 1 && length(flaglist) > 1
            Iall = (1:length(flaglist))';
            Ilist = [Isel;Iall(Iall~=Isel)];
            flaglist = flaglist(Ilist);
            uih.flagdefs = uih.flagdefs(Ilist,:);
            set(h_dlg,'UserData',uih)
            set(uih.listFlags,'String',flaglist,'Value',1)
         end
         
      case 'movedown'  %move definition down the list
         
         if Isel < length(flaglist) && length(flaglist) > 1
            Iall = (1:length(flaglist))';
            Ilist = [Iall(Iall<Isel) ; Isel+1 ; Isel ; Iall(Iall>Isel+1)];
            flaglist = flaglist(Ilist);
            uih.flagdefs = uih.flagdefs(Ilist,:);
            set(h_dlg,'UserData',uih)
            set(uih.listFlags,'String',flaglist,'Value',Isel+1)
         end
         
      case 'moveup'  %move definition up in the list
         
         if Isel > 1 && length(flaglist) > 1
            Iall = (1:length(flaglist))';
            Ilist = [Iall(Iall<Isel-1) ; Isel ; Isel-1 ; Iall(Iall>Isel)];
            flaglist = flaglist(Ilist);
            uih.flagdefs = uih.flagdefs(Ilist,:);
            set(h_dlg,'UserData',uih)
            set(uih.listFlags,'String',flaglist,'Value',Isel-1)
         end
         
      case 'movelast'  %move definition to the bottom of the list
         
         if Isel < length(flaglist) && length(flaglist) > 1
            Iall = (1:length(flaglist))';
            Ilist = [Iall(Iall~=Isel);Isel];
            flaglist = flaglist(Ilist);
            uih.flagdefs = uih.flagdefs(Ilist,:);
            set(h_dlg,'UserData',uih)
            set(uih.listFlags,'String',flaglist,'Value',length(flaglist))
         end
         
      case 'clear' %clear the anomalie field
         
         set(uih.editAnom,'String','')
         drawnow
         
   end
   
end
