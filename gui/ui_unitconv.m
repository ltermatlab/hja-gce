function ui_unitconv(op,s,col,h_save,cb)
%Unit conversion dialog called by 'ui_editor' (requires data file ui_editor.mat)
%
%syntax: ui_unitconv(op,s,col)
%
%input:
%  op = operation ('init' to initialize dialog)
%  s = data structure
%  col = data column to convert
%
%output:
%  none
%
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
%last modified: 02-Jun-2013

if nargin == 0
   op = 'init';
end

if strcmp(op,'init')

   %check for prior instance
   if length(findobj) > 1
      h_dlg = findobj('Tag','dlgUnitConversions');
   else
      h_dlg = [];
   end

   %delete any prior instances that reference other columns
   if ~isempty(h_dlg)
      delete(h_dlg)
      drawnow
   end

   if nargin >= 3

      if gce_valid(s,'data') == 1 && exist('ui_unitconv.mat','file') == 2

         %get data type of column
         coltype = get_type(s,'datatype',col);

         %check for unsupported attributes based on type, units
         if ~strcmp(coltype,'s') && ~isempty(s.units{col}) && ~strcmp(s.units{col},'none') && ~strcmp(s.units{col},'unspecified')

            %supply defaults for omitted arguments
            if exist('h_save','var') ~= 1
               h_save = [];
            end

            if exist('cb','var') ~= 1
               cb = '';
            end

            %load unit conversions database
            try
               v = load('ui_unitconv.mat');
               if isfield(v,'conversions')
                  conversions = v.conversions;
               end
            catch
               conversions = [];
            end

            if ~isempty(conversions)

               %look up predefined conversions for current column units
               I = find(strcmp({conversions.units1},s.units{col}));

               if ~isempty(I)

                  %check for multiplier or equation mode
                  units2str = conversions(I(1)).units2;
                  if ~isempty(conversions(I(1)).multiplier)
                     multstr = sprintf(conversions(I(1)).formatstring,conversions(I(1)).multiplier);
                     multvis = 'on';
                     equatvis = 'off';
                     equatstr = '';
                  else
                     multstr = '';
                     multvis = 'off';
                     equatstr = conversions(I(1)).equation;
                     equatvis = 'on';
                  end

                  %generate conversion popupmenu options
                  convstr = cell(length(I)+1,1);
                  convstr{1} = '<define new conversion>';
                  for n = 1:length(I)
                     convstr{n+1} = [conversions(I(n)).units1,' --> ',conversions(I(n)).units2];
                  end
                  conval = 2;  %select first matched conversion
                  convstr = char(convstr);
                  convis = 'on';
                  Iconv = I;

               else  %no predefined conversions

                  %init empty popupmenu
                  convis = 'off';
                  conval = 1;
                  units2str = '';
                  multstr = '';
                  multvis = 'on';
                  equatstr = '';
                  equatvis = 'on';
                  convstr = '<no matching conversions>';
                  Iconv = [];

               end

               %get screen resolution and define background color
               res = get(0,'ScreenSize');
               bgcolor = [0.95 0.95 0.95];

               %generate dialog figure
               h_dlg = figure('Name','Unit Conversions', ...
                  'Visible','off', ...
                  'Units','pixels', ...
                  'Position',[max(0,0.5.*(res(3)-600)) max(50,0.5.*(res(4)-340)) 600 340], ...
                  'Color',bgcolor, ...
                  'KeyPressFcn','figure(gcf)', ...
                  'MenuBar','none', ...
                  'NumberTitle','off', ...
                  'ToolBar','none', ...
                  'Resize','off', ...
                  'Tag','dlgUnitConversions', ...
                  'DefaultuicontrolUnits','pixels');

               if mlversion >= 7
                  set(h_dlg,'WindowStyle','normal')
                  set(h_dlg,'DockControls','off')
               end

               uicontrol('Parent',h_dlg, ...
                  'Style','text', ...
                  'Position',[15 297 165 18], ...
                  'BackgroundColor',bgcolor, ...
                  'FontSize',10, ...
                  'FontWeight','bold', ...
                  'String','Standard Conversions', ...
                  'Tag','StaticText1');

               h_popStdConv = uicontrol('Parent',h_dlg, ...
                  'Style','popupmenu', ...
                  'Enable',convis, ...
                  'Position',[180 295 415 24], ...
                  'BackgroundColor',[1 1 1], ...
                  'FontSize',10, ...
                  'String',convstr, ...
                  'Tag','popStdConv', ...
                  'Callback','ui_unitconv(''standard'')', ...
                  'Value',conval);

               uicontrol('Parent',h_dlg, ...
                  'Style','text', ...
                  'Position',[5 283 590 2], ...
                  'BackgroundColor',[0.8 0.8 0.8], ...
                  'Tag','txtSep');

               uicontrol('Parent',h_dlg, ...
                  'Style','text', ...
                  'Position',[60 246 120 18], ...
                  'BackgroundColor',bgcolor, ...
                  'FontSize',10, ...
                  'FontWeight','bold', ...
                  'String','Original Units', ...
                  'Tag','StaticText1');

               uicontrol('Parent',h_dlg, ...
                  'Style','text', ...
                  'Position',[60 212 120 18], ...
                  'BackgroundColor',bgcolor, ...
                  'FontSize',10, ...
                  'FontWeight','bold', ...
                  'String','Converted Units', ...
                  'Tag','StaticText1');

               h_lblMult = uicontrol('Parent',h_dlg, ...
                  'Style','text', ...
                  'Position',[60 177 120 18], ...
                  'BackgroundColor',bgcolor, ...
                  'FontSize',10, ...
                  'FontWeight','bold', ...
                  'String','Multiplier', ...
                  'Tag','StaticText1');

               h_lblEquat = uicontrol('Parent',h_dlg, ...
                  'Style','text', ...
                  'Position',[60 147 120 18], ...
                  'BackgroundColor',bgcolor, ...
                  'FontSize',10, ...
                  'FontWeight','bold', ...
                  'String','Equation*', ...
                  'Tag','lblEquat');

               h_editCurrent = uicontrol('Parent',h_dlg, ...
                  'Style','edit', ...
                  'Position',[180 241 360 24], ...
                  'BackgroundColor',[1 1 1], ...
                  'Enable','inactive', ...
                  'FontSize',10, ...
                  'HorizontalAlignment','left', ...
                  'String',s.units{col}, ...
                  'Tag','editCurrent');

               h_editNew = uicontrol('Parent',h_dlg, ...
                  'Style','edit', ...
                  'Position',[180 208 360 24], ...
                  'BackgroundColor',[1 1 1], ...
                  'FontSize',10, ...
                  'HorizontalAlignment','left', ...
                  'String',units2str, ...
                  'Tag','editNew');

               h_editMult = uicontrol('Parent',h_dlg, ...
                  'Style','edit', ...
                  'Position',[180 175 360 24], ...
                  'BackgroundColor',[1 1 1], ...
                  'FontSize',10, ...
                  'HorizontalAlignment','left', ...
                  'String',multstr, ...
                  'Callback','ui_unitconv(''mult'')', ...
                  'Enable',multvis, ...
                  'UserData',multstr, ...
                  'Tag','editMult');

               h_editEquat = uicontrol('Parent',h_dlg, ...
                  'Style','edit', ...
                  'Position',[180 145 360 24], ...
                  'BackgroundColor',[1 1 1], ...
                  'FontSize',10, ...
                  'HorizontalAlignment','left', ...
                  'String',equatstr, ...
                  'Callback','ui_unitconv(''equation'')', ...
                  'Enable',equatvis, ...
                  'UserData',equatstr, ...
                  'Tag','editEquat');

               h_lblHelp = uicontrol('Parent',h_dlg, ...
                  'Style','text', ...
                  'Position',[10 120 580 18], ...
                  'ForegroundColor',[0 0 .8], ...
                  'BackgroundColor',bgcolor, ...
                  'FontSize',10, ...
                  'String','* use Original Units or x in equations, e.g. ''°F*1.8+32'' or ''x*1.8+32''', ...
                  'Tag','StaticText1');

               uicontrol('Parent',h_dlg, ...
                  'Style','text', ...
                  'Position',[5 110 590 2], ...
                  'BackgroundColor',[0.8 0.8 0.8], ...
                  'Tag','txtSep');

               uicontrol('Parent',h_dlg, ...
                  'Style','text', ...
                  'Position',[80 75 100 20], ...
                  'ForegroundColor',[0 0 0], ...
                  'BackgroundColor',bgcolor, ...
                  'FontSize',10, ...
                  'FontWeight','bold', ...
                  'String','Options:', ...
                  'Tag','StaticText1');

               h_chkNewCol = uicontrol('Parent',h_dlg, ...
                  'Style','checkbox', ...
                  'Position',[185 75 280 20], ...
                  'BackgroundColor',bgcolor, ...
                  'FontSize',10, ...
                  'Value',0, ...
                  'String','Save converted values as a new column', ...
                  'Tag','chkNewCol');

               h_chkSave = uicontrol('Parent',h_dlg, ...
                  'Style','checkbox', ...
                  'Position',[185 50 280 20], ...
                  'BackgroundColor',bgcolor, ...
                  'FontSize',10, ...
                  'Value',0, ...
                  'String','Save this conversion for future use', ...
                  'Tag','chkSave');

               h_cmdCancel = uicontrol('Parent',h_dlg, ...
                  'Position',[5 10 65 25], ...
                  'Callback','ui_unitconv(''cancel'')', ...
                  'String','Cancel', ...
                  'Tag','cmdCancel', ...
                  'TooltipString','Cancel the unit conversion and close the dialog');

               h_cmdEval = uicontrol('Parent',h_dlg, ...
                  'Position',[530 10 65 25], ...
                  'Callback','ui_unitconv(''eval'')', ...
                  'String','Proceed', ...
                  'Tag','cmdEval', ...
                  'TooltipString','Perform the unit conversion and update the data structure');

               %generate structure to cache handles and state data
               uih = struct( ...
                  's',s, ...
                  'col',col, ...
                  'h_save',h_save, ...
                  'cb',cb, ...
                  'conversions',conversions, ...
                  'Iconv',Iconv, ...
                  'popStdConv',h_popStdConv, ...
                  'editCurrent',h_editCurrent, ...
                  'lblMult',h_lblMult, ...
                  'lblEquat',h_lblEquat, ...
                  'lblHelp',h_lblHelp, ...
                  'editNew',h_editNew, ...
                  'editMult',h_editMult, ...
                  'editEquat',h_editEquat, ...
                  'chkNewCol',h_chkNewCol, ...
                  'chkSave',h_chkSave, ...
                  'cmdCancel',h_cmdCancel, ...
                  'cmdEval',h_cmdEval);

               set(h_dlg,'UserData',uih,'Visible','on')

               %call subroutine to set initial button states
               ui_unitconv('buttons')

            else  %invalid conversions.mat
               messagebox('init','The units conversion database ''ui_unitconv.mat'' is invalid', ...
                  '','Error',[.95 .95 .95]);
            end

         else  %invalid column type or units1
            if strcmp(coltype,'s')
               errstr = 'Unit conversions cannot be performed on string columns';
            else
               errstr = 'Conversions cannot be performed on columns without valid units';
            end
            messagebox('init',errstr,'','Error',[.95 .95 .95])
         end

      else  %invalid data

         if exist('ui_unitconv.mat','file') == 2
            errstr = 'Invalid GCE Data Structure -- unable to perform conversions';
         else
            errstr = 'The unit conversions data file ''ui_unitconv.mat'' is missing';
         end
         messagebox('init',errstr,'','Error',[.95 .95 .95])

      end

   else

      errstr = 'Insufficient arguments for the function';
      messagebox('init',errstr,'','Error',[.95 .95 .95])

   end

else

   h_dlg = findobj('tag','dlgUnitConversions');

   if ~isempty(h_dlg)

      uih = get(h_dlg,'UserData');

      switch op

         case 'cancel'  %close dialog

            delete(h_dlg)

            if ~isempty(uih.h_save)
               h_fig = parent_figure(uih.h_save);
               if ~isempty(h_fig)
                  figure(h_fig)
                  drawnow
               else
                  ui_aboutgce('reopen')  %check for last window
               end
            else
               ui_aboutgce('reopen')  %check for last window
            end

         case 'eval'  %evaluate input and perform conversion

            %get form entries
            units2 = deblank(get(uih.editNew,'String'));
            multstr = deblank(get(uih.editMult,'String'));
            if isempty(multstr)
               eq = get(uih.editEquat,'UserData');
               newmult = [];
            else
               newmult = str2double(multstr);
            end

            %check for entries
            if ~isempty(units2) && (~isempty(newmult) || ~isempty(eq))

               units1 = deblank(get(uih.editCurrent,'String'));

               %calculate format mask for multiplier
               if ~isempty(newmult)
                  eq = '';
                  Idot = strfind(multstr,'.');
                  Ie = strfind(lower(multstr),'e');
                  if ~isempty(Idot)
                     if ~isempty(Ie)
                        fstr = ['%0.',int2str(Ie-Idot-1),'e'];
                     else
                        fstr = ['%0.',int2str(length(multstr)-Idot),'f'];
                     end
                  elseif isempty(Ie)
                     fstr = '%0d';
                  else
                     fstr = '%0.0e';
                  end
               else
                  newmult = [];
                  fstr = [];
               end

               %save conversion to the database for future use if specified
               if get(uih.chkSave,'Value') == 1

                  %update conversions data
                  conversions = uih.conversions;
                  I = find(strcmp({conversions.units1},units1) & strcmp({conversions.units2},units2));
                  if ~isempty(I)
                     n = I(1);  %update matching
                     sortflag = 0;
                  else
                     n = length(conversions)+1;
                     sortflag = 1;
                  end
                  conversions(n).units1 = units1;
                  conversions(n).units2 = units2;
                  conversions(n).multiplier = newmult;
                  conversions(n).formatstring = fstr;
                  conversions(n).equation = eq;
                  if sortflag == 1  %resort list by units1, units2
                     [tmp,I2] = sort(lower({conversions.units2}));
                     [tmp,I1] = sort(lower({conversions(I2).units1}));
                     conversions = conversions(I2(I1));
                  end

                  %buffer english/metric mappings if file exists
                  if exist('ui_unitconv.mat','file') == 2
                     old = load('ui_unitconv.mat');
                     if isfield(old,'englishmetric')
                        englishmetric = old.englishmetric;
                     else
                        englishmetric = [];
                     end
                  end

                  %save updated unit conversions
                  pn = [gce_homepath,filesep,'settings'];
                  if ~isdir(pn)
                     pn = fileparts(which('ui_unitconv'));  %use function path as backup if userdata not present
                  end
                  save([pn,filesep,'ui_unitconv.mat'],'conversions','englishmetric')

               end

               %get cached data set and column pointer
               s = uih.s;
               col = uih.col;
               newcol = get(uih.chkNewCol,'Value');

               %call unit conversion function
               if ~isempty(newmult)
                  [s2,msg] = unit_convert(s,col,units2,newmult,newcol);
               else
                  [s2,msg] = unit_convert(s,col,units2,eq,newcol);
               end

               %check for successful conversion
               if ~isempty(s2)

                  %close dialog
                  delete(h_dlg)
                  drawnow

                  %send updated dataset to calling figure and execute callback
                  err = 0;
                  if ~isempty(uih.h_save)
                     h_fig = parent_figure(uih.h_save);
                     if ~isempty(h_fig)
                        figure(h_fig)
                        set(uih.h_save,'UserData',s2)
                        if ~isempty(uih.cb)
                           try
                              eval(uih.cb)
                           catch
                              err = 1;
                           end
                        end
                     else
                        err = 1;
                     end
                  else
                     err = 1;
                  end

                  %send to new editor instance if original not found
                  if err == 1
                     ui_editor('init',s2)
                     messagebox('init','Could not return structure to the original editor window', ...
                        '','Warning',[.9 .9 .9])
                  end

               else
                  messagebox('init', ...
                     char('Conversion could not be applied using the specified parameters', ...
                     ['(error: ',msg,')']), ...
                     [],'Error',[.9 .9 .9]);
               end

            else  %generate error messages

               if isempty(units2)
                  str = 'Units string cannot be blank - conversion cancelled';
               else
                  str = 'Invalid multiplier - conversion cancelled';
               end
               messagebox('init', ...
                  str, ...
                  '', ...
                  'Error', ...
                  [.8 .8 .8]);

            end

         case 'mult'  %validate multiplier edits

            multstr = deblank(get(uih.editMult,'String'));

            if ~isempty(multstr)

               %check for numeric multiplier
               multval = str2double(multstr);
               if isnan(multval)
                  multval = str2num(multstr);  %check for numeric expression
                  if ~isempty(multval) && length(multval) == 1
                     %reformat results of numeric expression as number with 8 digits precision
                     multstr = num2str(multval,8);
                  else
                     multval = [];                     
                  end
               end

               %check for valid, scalar numeric multiplier
               if ~isempty(multval)

                  %update editbox string and userdata with new values
                  set(uih.editMult,'String',multstr,'UserData',multstr)

                  %update uicontrols and states
                  if strcmp(get(uih.editEquat,'Enable'),'on')
                     set(uih.editEquat,'String','','Enable','off','UserData','')
                  end
                  set(uih.editMult,'UserData',multstr)  %cache undo data
   
               else
                  
                  %reset editbox and issue error popup
                  set(uih.editMult,'String',get(uih.editMult,'UserData'))
                  messagebox('init','Invalid multiplier - value reset','','Error',[0.95 0.95 0.95],0);
                  
               end

            else  %handle cleared multiplier

               set(uih.editMult,'UserData','')
               set(uih.editEquat,'Enable','on')

            end

            ui_unitconv('buttons')

         case 'equation'  %validate equation entries

            equat = deblank(get(uih.editEquat,'String'));
            units1 = deblank(get(uih.editCurrent,'String'));

            if ~isempty(equat)
               equat = strrep(equat,units1,'x');
               set(uih.editEquat,'UserData',equat)
               set(uih.editMult,'String','','UserData','','Enable','off')
            else
               set(uih.editEquat,'UserData','')
               set(uih.editMult,'Enable','on')
            end

            ui_unitconv('buttons')

         case 'buttons'  %set button states based on uicontrol entries

            if strcmp(get(uih.editMult,'Enable'),'on')
               set(uih.lblMult,'ForegroundColor',[0 0 0])
            else
               set(uih.lblMult,'ForegroundColor',[.8 .8 .8])
            end

            if strcmp(get(uih.editEquat,'Enable'),'on')
               set(uih.lblEquat,'ForegroundColor',[0 0 0])
               set(uih.lblHelp,'ForegroundColor',[0 0 .8])
            else
               set(uih.lblEquat,'ForegroundColor',[.8 .8 .8])
               set(uih.lblHelp,'ForegroundColor',[.8 .8 .8])
            end

            drawnow

         case 'standard'  %populate controls with parameters from a predefined conversion

            val = get(uih.popStdConv,'Value');
            Iconv = uih.Iconv;

            %check for a valid conversion selection
            if val > 1

               val = val - 1;  %adjust selection for top row

               mult = uih.conversions(Iconv(val)).multiplier;  %look up conversion

               %check for multiplier or equation mode
               if ~isempty(mult)
                  multstr = sprintf(uih.conversions(Iconv(val)).formatstring,mult);
                  set(uih.editMult, ...
                     'String',multstr, ...
                     'UserData',multstr, ...
                     'Enable','on')
                  set(uih.editEquat, ...
                     'String','', ...
                     'UserData','', ....
                     'Enable','off')
               else
                  eq = uih.conversions(Iconv(val)).equation;
                  set(uih.editMult, ...
                     'String','', ...
                     'UserData','', ...
                     'Enable','off')
                  set(uih.editEquat, ...
                     'String',eq, ...
                     'UserData',eq, ...
                     'Enable','on')
               end

               %update controls
               set(uih.editNew,'String',uih.conversions(Iconv(val)).units2)
               set(uih.chkSave,'Value',0)

               ui_unitconv('buttons')

            else  %reset dialog

               set(uih.editNew,'String','')
               set(uih.editEquat,'String','','Enable','on')
               set(uih.editMult,'String','','Enable','on','UserData',[])

               ui_unitconv('buttons')

            end

      end

   end

end