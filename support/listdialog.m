function I_sel = listdialog(varargin)
%Customized variant of the MATLAB 'listdlg' function
%
%syntax: I_sel = listdialog(varargin)
%
%Accepts pairs of parameter names and values, as follows:
%
%Parameter           Value
%'liststring'        cell array of strings to display in list (required)
%'name'              string to use as figure title (default = '')
%'promptstring'      string to display above list box (default = 'Select an item from the list')
%'selectionmode'     'single' or 'multiple' selections (default = 'multiple')
%'initialvalue'      index array of values to highlight initially (default = 1)
%'backgroundcolor'   background color for figure window (default = [.9 .9 .9])
%'foregroundcolor'   foreground color for figure window (default = [0 0 0])
%'listsize'          figure window position in pixels ([left bottom width height])
%   (note: use 0's for left or bottom values to center the window in the respective direction)
%
%'I_sel' is an index of the selected items if the 'OK' button is pressed or [] if the 
%   'Cancel' button is pressed
%
%e.g.  I_sel = listdialog('liststring',{'item1','item2','item3'},'selectionmode','multiple')
%
%by Wade Sheldon, UGA Dept. of Marine Sciences
%
%last modified: 06-Sep-2006

if exist('varargin')
   
   len = length(varargin);
   
   if len > 1  %check for non-callback operation
      
      error = 0;
      
      if len./2 - fix(len./2) == 0  %check for paired arguments
         
         I_prop = [1:2:len-1];
         I_val = [2:2:len];
         
         eval('args = cell2struct(varargin(I_val),lower(varargin(I_prop)),2);','error = 1;')
         
      else  %unpaired args
         
         error = 1;
         
      end
      
      if error == 0
         
         if isfield(args,'liststring')  %check for required List field
         
            %apply default settings for missing optional arguments
            fontsize = 10;
            
            if ~isfield(args,'name')
               args.name = 'List Dialog';
            elseif ~isstr(args.name)
               args.name = 'List Dialog';
            end
            
            if ~isfield(args,'backgroundcolor')
               args.backgroundcolor = [.9 .9 .9];
            elseif length(args.backgroundcolor) ~= 3
               args.backgroundcolor = [.9 .9 .9];
            end
            
            if ~isfield(args,'foregroundcolor')
               args.foregroundcolor = [0 0 0];
            elseif length(args.backgroundcolor) ~= 3
               args.foregroundcolor = [0 0 0];
            end
            
            if ~isfield(args,'selectionmode')
               args.selectionmode = 'multiple';
            elseif ~isstr(args.selectionmode)
               args.selectionmode = 'multiple';
            end
                        
            if strcmp(lower(args.selectionmode),'multiple')
               listrng = [1 3];
               omnisel = 'on';
        	      promptstr = 'Select items from the list';
            else
               listrng = [1 2];
               omnisel = 'off';
  	            promptstr = 'Select an item from the list';
            end
            
            if ~isfield(args,'promptstring')
               args.promptstring = promptstr;
            elseif ~isstr(args.promptstring)
               args.promptstring = promptstr;
            end
            
            if ~isfield(args,'initialvalue')
               args.initialvalue = 1;
            elseif length(args.initialvalue) > length(args.liststring)
               args.initialvalue = 1;
            end
            
            if ~isfield(args,'listsize')
               args.listsize = [0 0 260 200];
            elseif length(args.listsize) < 2
               args.listsize = [0 0 260 200];
            elseif length(args.listsize) == 2
               args.listsize = [0 0 args.listsize(:)'];
            end
            
            %get screen parameters
            res = get(0,'ScreenSize');
            
            %calculate screen positioning constants
            figpos = args.listsize;
            if figpos(1) == 0  %center horizontally
               figpos(1) = (res(3)-figpos(3))./2;
            end
            if figpos(2) == 0
               figpos(2) = (res(4)-figpos(4))./2;
            end
            if strcmp(omnisel,'on')
               listpos = [10 70 figpos(3)-20 figpos(4)-100];
            else
               listpos = [10 40 figpos(3)-20 figpos(4)-70];
            end
            
            if length(findobj) > 1
               
               h_fig = gcf;  %get handle of calling figure
               
	            %check for prior instance of dialog
   	         h_dlg = findobj('Tag','dlgListBox');
      	      if ~isempty(h_dlg)
         	      close(h_dlg)
               end
               
            else
               
               h_fig = [];
               
            end
                        
            h_dlg = figure('Name',args.name, ...
               'WindowStyle','modal', ...
               'Visible','off', ...
               'WindowStyle','normal', ...
               'Color',args.backgroundcolor, ...
               'Units','pixels', ...
               'Position',figpos, ...
               'MenuBar','none', ...
               'ToolBar','none', ...
               'NumberTitle','off', ...
               'DefaultUicontrolUnits','pixels', ...
               'KeyPressFcn','figure(gcf)', ...
               'Resize','off', ...
               'Tag','dlgListBox', ...
               'CloseRequestFcn','set(gcf,''userdata'',''cancel'')', ...
               'UserData','');
            
            uicontrol(h_dlg, ...
               'Style','frame', ...
               'BackgroundColor',args.backgroundcolor, ...
               'ForegroundColor',args.foregroundcolor, ...
               'Position',[5 35 figpos(3)-10 figpos(4)-40]);
            
            uicontrol(h_dlg, ...
               'Fontsize',fontsize, ...
               'Style','text', ...
               'BackgroundColor',args.backgroundcolor, ...
               'ForegroundColor',args.foregroundcolor, ...
               'String',args.promptstring, ...
               'Position',[10 figpos(4)-28 figpos(3)-20 18], ...
               'HorizontalAlignment','left');
            
            h_listbox = uicontrol(h_dlg, ...
               'Fontsize',fontsize, ...
               'Style','listbox', ...
               'Position',listpos, ...
               'BackgroundColor',[1 1 1], ...
               'ForegroundColor',[0 0 0], ...
               'Min',listrng(1), ...
               'Max',listrng(2), ...
               'ListBoxTop',args.initialvalue(1), ...
               'Value',args.initialvalue, ...
               'String',args.liststring, ...
               'Tag','listbox', ...
               'CallBack','listdialog(''click'')');
            
            uicontrol(h_dlg, ...
               'Position',[figpos(3)-65 5 60 25], ...
               'String','OK', ...
               'FontSize',10, ...
               'CallBack','listdialog(''ok'')');
            
            uicontrol(h_dlg, ...
               'Position',[5 5 60 25], ...
               'String','Cancel', ...
               'CallBack','listdialog(''cancel'')', ...
               'FontSize',10, ...
               'Tag','cmdCancel', ...
               'UserData',h_fig);
            
            uicontrol(h_dlg, ...
               'Visible',omnisel, ...
               'Enable',omnisel, ...
               'Position',[10 40 figpos(3)-20 25], ...
               'FontSize',10, ...
               'String','Select All', ...
               'CallBack','listdialog(''omnisel'')');
            
            set(h_dlg,'Visible','on')
            
            waitfor(h_dlg,'UserData')  %setup waitfor condition
            
            switch get(h_dlg,'UserData')
               
            case 'ok'
               
               I_sel = get(h_listbox,'Value');
               
            case 'cancel'
               
               I_sel = [];
               
            end
            
            delete(h_dlg)
            
            if ~isempty(h_fig)
               figure(h_fig)
            end
            
            drawnow
            
         else  %no list
            
            I_sel = [];
            
            errorbox('init','Required ''ListString'' argument omitted')
            
         end
                  
      else
         
         I_sel = [];
         
         errorbox('init','Invalid argument list (must be pairs of parameters, values)')
         
      end
      
   else  %handle callbacks
      
      op = varargin{1};
      
      h_dlg = findobj('Tag','dlgListBox');
      
      if strcmp(op,'cancel')
         
         set(h_dlg,'UserData','cancel')
         
      elseif strcmp(op,'ok')
                        
         set(h_dlg,'UserData','ok')
         
      elseif strcmp(op,'click')
         
         if strcmp(get(h_dlg,'SelectionType'),'open')
            set(h_dlg,'UserData','ok')
         end
         
      elseif strcmp(op,'omnisel')
         
	      h_list = findobj(h_dlg,'Tag','listbox');
         str = get(h_list,'String');
         set(h_list,'Value',[1:length(str)])
         drawnow
                  
      end
      
   end
      
end
