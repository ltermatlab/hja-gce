function msg = viewstats(s,flagopt)
%Displays ungrouped column statistics for a GCE data structure in a scrollable text box
%
%syntax: msg = viewstats(s,flagopt)
%
%inputs:
%  s = valid GCE data or stat structure
%  flagopt = option to include/exclude flagged values
%     'I' = include (default)
%     'E' = exclude
%
%outputs:
%  msg = text of any error messages
%
%
%(c)2002-2009 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 24-Jun-2009

msg = '';

if nargin >= 1

   if exist('flagopt','var') ~= 1
      flagopt = 'I';
   elseif ~strcmp(upper(flagopt),'E')
      flagopt = 'I';
   end

   if gce_valid(s,'data')
      stats = colstats(s,flagopt);
   elseif gce_valid(s,'stats')
      stats = s;
   else
      stats = [];
   end

   if ~isempty(stats)

      numcols = length(stats.name);
      coltitles = [ {''}; ...
            {'   Variable: '}; ...
            {'      Units: '}; ...
            {'       Type: '}; ...
            {'  -----------'}; ...
            {'    Records: '}; ...
            {'    Missing: '}; ...
            {'    Flagged: '}; ...
            {'  -----------'}; ...
            {'    Minimum: '}; ...
            {'    Maximum: '}; ...
            {'      Total: '}; ...
            {'     Median: '}; ...
            {'       Mean: '}; ...
            {'    Std Dev: '}; ...
            {'  Std Error: '}];

      str = repmat(' ',15,1);

      for n = 1:numcols

         tmpcell = [stats.name(n) ; stats.units(n) ; stats.variabletype(n) ; repmat({''},10,1)];
         dtype = lower(stats.datatype{n});

         precval = stats.precision(n);
         if strcmp(dtype,'f') | strcmp(dtype,'e')
            precstr = int2str(precval);
            precstr1 = int2str(precval+1);
            precstr2 = int2str(precval+2);
         else
            precstr = '0';
            precstr1 = '0';
            precstr2 = '0';
         end

         %build format strings
         f_cnt = '%d';
         if strcmp(dtype,'e')
            f_stat = ['%0.',precstr,'e'];
            f_stat2 = ['%0.',precstr,'e'];
            f_se = ['%0.',precstr,'e'];
         else
            f_stat = ['%0.',precstr,'f'];
            f_stat2 = ['%0.',precstr1,'f'];
            f_se = ['%0.',precstr2,'f'];
         end

         tmpcell{4} = sprintf(f_cnt,stats.observations(n));
         tmpcell{5} = sprintf(f_cnt,stats.missing(n));
         tmpcell{6} = sprintf(f_cnt,stats.flagged(n));
         tmpcell{7} = sprintf(f_stat,stats.min(n));
         tmpcell{8} = sprintf(f_stat,stats.max(n));
         tmpcell{9} = sprintf(f_stat,stats.total(n));
         tmpcell{10} = sprintf(f_stat,stats.median(n));
         tmpcell{11} = sprintf(f_stat2,stats.mean(n));
         tmpcell{12} = sprintf(f_stat2,stats.stddev(n));
         tmpcell{13} = sprintf(f_stat2,stats.se(n));

         tmpstr = strjust(char(strrep(tmpcell,'NaN','--')),'right');
         spcr = repmat('-',1,size(tmpstr,2)+3);
         tmpstr = char(tmpstr(1:3,:),spcr,tmpstr(4:6,:),spcr,tmpstr(7:13,:));

         str = [str , tmpstr];

      end

      str = char('',str);

      if strcmp(upper(flagopt),'E')
         titlestr = 'Column Statistics (flagged values excluded)';
      else
         titlestr = 'Column Statistics (flagged values included)';
      end

      if exist('font','var') ~= 1
         if strcmp(computer,'PCWIN')
            font = 'Courier New';
         else
            font = 'Courier';
         end
      end

      res = get(0,'screensize');
      figsize = [min(900,res(3)-200) 280];

      h_dlg = figure('visible','off', ...
         'Color',[.95 .95 .95], ...
         'Name',titlestr, ...
         'NumberTitle','off', ...
         'Menubar','none', ...
         'Toolbar','none', ...
         'KeyPressFcn','figure(gcf)', ...
         'Units','pixels', ...
         'Position',[max(0,0.5.*(res(3)-figsize(1))) max(50,0.5.*(res(4)-figsize(2))) figsize(1) figsize(2)], ...], ...
         'ResizeFcn',['h_list_temp2=findobj(gcf,''Tag'',''listbox2''); ', ...
            'if ~isempty(h_list_temp2); ', ...
            'figpos_temp=get(gcf,''Position'');', ...
            'h_list_temp1=findobj(gcf,''Tag'',''listbox1''); ', ...
            'set(h_list_temp2,''Position'',[101 1 figpos_temp(3)-100 figpos_temp(4)-1]); ', ...
            'set(h_list_temp1,''Position'',[1 1 140 figpos_temp(4)-1]); ', ...
            'end; ', ...
            'clear h_list_temp* figpos_temp;'], ...
         'Tag','dlgViewStats');

      h_mnuFile = uimenu('Parent',h_dlg, ...
         'Label','File');

      h_mnuHelp = uimenu('Parent',h_dlg, ...
         'Label','Help');

      h_mnuExport = uimenu('Parent',h_mnuFile, ...
         'Label','Full Stats Report', ...
         'Callback','ui_statreport(''init'',get(gcbo,''UserData''))', ...
         'UserData',s);

      h_mnuClose = uimenu('Parent',h_mnuFile, ...
         'Label','Close', ...
         'Separator','on', ...
         'Callback','close(gcf)');

      h_mnuAbout = uimenu('Parent',h_mnuHelp, ...
         'Label','About the GCE Data Toolbox', ...
         'Separator','on', ...
         'Callback','ui_aboutgce');

      h_list1 = uicontrol('Parent',h_dlg, ...
         'Units','pixels', ...
         'Style','listbox', ...
         'ListboxTop',1, ...
         'FontName',font, ...
         'FontSize',9, ...
         'BackgroundColor',[1 1 1], ...
         'String',coltitles, ...
         'Position',[1 1 140 figsize(2)-1], ...
         'Min',0, ...
         'Max',2, ...
         'Value',[], ...
         'Callback','set(gcbo,''Value'',1,''ListBoxTop'',get(gcbo,''ListBoxTop'')); set(gcbo,''Value'',[])', ...
         'Tag','listbox1');

      h_list2 = uicontrol('Parent',h_dlg, ...
         'Units','pixels', ...
         'Style','listbox', ...
         'ListboxTop',1, ...
         'FontName',font, ...
         'FontSize',9, ...
         'BackgroundColor',[1 1 1], ...
         'String',str, ...
         'Position',[101 1 figsize(1)-100 figsize(2)-1], ...
         'Min',0, ...
         'Max',2, ...
         'Value',[], ...
         'Callback','set(gcbo,''Value'',1,''ListBoxTop'',get(gcbo,''ListBoxTop'')); set(gcbo,''Value'',[])', ...
         'Tag','listbox2');

      set(h_dlg,'Visible','on')
      drawnow

   else

      msg = 'invalid data or stat structure';

   end

else

   msg = 'insufficient arguments';

end
