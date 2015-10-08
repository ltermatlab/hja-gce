function ui_aboutgce(op)
%GCE Data Toolbox startup splash screen with links to the structure editor and documentation
%
%syntax:  ui_aboutgce(op)
%
%input:
%  op = operation
%    'init' = create dialog unconditionally (default)
%    'reopen' = create dialog based on preference setting in 'gce_datatools.mat'
%
%output:
%  none
%
%
%(c)2002-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 28-Aug-2015

%check for no argument - default to 'init'
if exist('op','var') ~= 1
   op = 'init';
end

%check for 'init' or 'reopen'
if strcmp(op,'init') || strcmp(op,'reopen')

   if length(findobj) > 1
      h_dlg = findobj('tag','dlgAboutGCE');
   else
      h_dlg = [];
   end

   %check for open instance
   if ~isempty(h_dlg)

      figure(h_dlg)  %set focus to prior instance

   else  %create dialog

      %init runtime vars
      gcelogo = [];
      disclaimer = [{'Usage Agreement and Disclaimer'},{''},{'(text not available)'}];
      toolboxversion = '(not determined)';
      loadsplash = 1;

      if exist('gce_datatools.mat','file') == 2
         try
            vars = load('gce_datatools.mat','-mat');
         catch
            vars = struct('null','');
         end
         if isfield(vars,'gcelogo')
            gcelogo = vars.gcelogo;
         end
         if isfield(vars,'disclaimer')
            disclaimer = vars.disclaimer;
         end
         if isfield(vars,'toolboxversion')
            toolboxversion = vars.toolboxversion;
         end
         if isfield(vars,'loadsplash')
            loadsplash = vars.loadsplash;
         end
      end

      if strcmp(op,'init') || (strcmp(op,'reopen') && length(findobj) ==1 && loadsplash == 1)

         res = get(0,'ScreenSize');

         if ispc || isunix
            font = 'Arial';
            fontfixed = 'Courier New';
            fontsize1 = 24;
            fontsize2 = 12;
            fontsizefixed = 9;
         else  %mac
            font = 'Helvetica';
            fontfixed = 'Courier';
            fontsize1 = 20;
            fontsize2 = 11;
            fontsizefixed = 9;
         end

         h_dlg = figure('Visible','off', ...
            'Color',[1 1 1], ...
            'KeyPressFcn','figure(gcf)', ...
            'MenuBar','none', ...
            'Name','About the GCE Data Toolbox', ...
            'NumberTitle','off', ...
            'Position',[max(0,0.5.*(res(3)-504)) max(50,0.5.*(res(4)-500)) 504 500], ...
            'Tag','dlgAboutGCE', ...
            'Resize','off', ...
            'DefaultUiControlUnits','pixels', ...
            'ToolBar','none');

         if mlversion >= 7
            set(h_dlg,'WindowStyle','normal')
            set(h_dlg,'DockControls','off')
         end

         axes('Parent',h_dlg, ...
            'Units','pixels', ...
            'Color',[1 1 1], ...
            'Position',[40 250 130 130], ...
            'Tag','axesLogo', ...
            'XColor',[1 1 1], ...
            'XTickLabelMode','manual', ...
            'YColor',[1 1 1], ...
            'YTickLabelMode','manual', ...
            'ZColor',[0 0 0]);

         if ~isempty(gcelogo)
            image(gcelogo);
            axis off
            axis equal
         end

         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[10 440 485 40], ...
            'Horizontalalignment','center', ...
            'Style','text', ...
            'FontName',font, ...
            'FontWeight','bold', ...
            'FontSize',fontsize1, ...
            'ForegroundColor',[0 .5 0], ...
            'String','GCE Data Toolbox for MATLAB', ...
            'Tag','lblTitle1');

         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[30 390 445 50], ...
            'Style','text', ...
            'FontName',font, ...
            'FontWeight','bold', ...
            'FontAngle','italic', ...
            'FontSize',fontsize2, ...
            'ForegroundColor',[0 .5 0], ...
            'Min',1, ...
            'Max',5, ...
            'String',['Software for metadata-based processing, analysis, visualization and transformation of ', ...
               'environmental data'], ...
            'Tag','lblTitle2');

         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[145 365 345 22], ...
            'Style','text', ...
            'FontName',font, ...
            'FontSize',12, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 .5 0], ...
            'Min',1, ...
            'Max',5, ...
            'String',toolboxversion, ...
            'Tag','lblAuthor');

         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[190 305 275 50], ...
            'Style','text', ...
            'FontName',font, ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0], ...
            'Min',1, ...
            'Max',5, ...
            'String',['(c)2002-',datestr(now,10),' Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project'], ...
            'Tag','lblAuthor');

         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[250 210 205 105], ...
            'Style','text', ...
            'FontName',font, ...
            'FontSize',10, ...
            'ForegroundColor',[0 0 0], ...
            'HorizontalAlignment','left', ...
            'Min',1, ...
            'Max',5, ...
            'String',char('Wade M. Sheldon','Dept. of Marine Sciences','University of Georgia','Athens, GA 30602-3636', ...
            'email: sheldon@uga.edu'), ...
            'Tag','lblAuthor');

         uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Position',[5 190 95 25], ...
            'Fontsize',8, ...
            'Fontweight','bold', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',[.9 .9 .9], ...
            'String','Dataset Editor', ...
            'Callback','h=gcf; ui_editor(''init''); delete(h); clear h; drawnow', ...
            'TooltipString','Load, import or create data sets for analysis and customization');

         uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Position',[105 190 95 25], ...
            'Fontsize',8, ...
            'Fontweight','bold', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',[.9 .9 .9], ...
            'String','Search Engine', ...
            'Callback','h=gcf; ui_search_data(''init''); delete(h); clear h; drawnow', ...
            'TooltipString','Search for local or web-based data sets in GCE Data Structure format');

         uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Position',[205 190 95 25], ...
            'Fontsize',8, ...
            'Fontweight','bold', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',[.9 .9 .9], ...
            'String','Templates', ...
            'Callback','h=gcf; ui_template; delete(h); clear h; drawnow;', ...
            'TooltipString','Open the metadata template editor to view, create and revise templates');

         uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Position',[305 190 95 25], ...
            'Fontsize',8, ...
            'Fontweight','bold', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',[.9 .9 .9], ...
            'String','Documentation', ...
            'Callback','ui_viewdocs', ...
            'TooltipString','View the general documentation for the GCE Data Toolbox');

         uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Position',[405 190 95 25], ...
            'Fontsize',8, ...
            'Fontweight','bold', ...
            'ForegroundColor',[.7 0 0], ...
            'BackgroundColor',[.9 .9 .9], ...
            'String','Exit MATLAB', ...
            'Callback','close_gdt(''quit'')', ...
            'TooltipString','Close all tool windows and exit Matlab');

         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[5 30 497 150], ...
            'String',disclaimer, ...
            'FontName',fontfixed, ...
            'FontSize',fontsizefixed, ...
            'Style','listbox', ...
            'Tag','listDisclaimer', ...
            'Value',1);

         uicontrol('Parent',h_dlg, ...
            'Style','checkbox', ...
            'Position',[50 5 445 20], ...
            'FontName',font, ...
            'FontSize',10, ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',[1 1 1], ...
            'String','Automatically load startup screen if all other windows are closed', ...
            'Value',loadsplash, ...
            'Callback','ui_aboutgce(''loadsplash'')', ...
            'Tag','chkLoadSplash');

         set(h_dlg,'Visible','on')
         drawnow

      end

   end

elseif strcmp(op,'loadsplash')

   loadsplash = get(gcbo,'Value');
   fn = which('gce_datatools.mat');

   if ~isempty(fn) && ~isempty(loadsplash)
      save(fn,'loadsplash','-APPEND')
   end

end