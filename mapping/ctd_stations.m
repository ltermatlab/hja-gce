function ctd_stations(op)
%Dialog for plotting nominal LMER and GCE-LTER ctd station labels on a map,
%based on station data stored in 'ctd_stations.mat'
%
%syntax: ctd_stations
%
%
%(c)2004-2010 by Wade Sheldon
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
%Department of Marine Sciences
%University of Georgia
%Athens, Georgia  30602-3636
%sheldon@uga.edu
%
%last modified: 16-Sep-2010

if nargin == 0
   op = 'init';
end

if strcmp(op,'init')

   h_map = gcf;
   h_menu = findobj(h_map,'tag','ctd_stations');
   h_dlg = findobj('Tag','dlgCTDStations');
   if ~isempty(h_dlg)
      delete(h_dlg)
   end

   if ~isempty(h_menu) & exist('ctd_stations.mat','file') == 2

      v = load('ctd_stations.mat');
      transects = v.transects;
      river = {transects.river};
      default = {transects.default}';
      default = cat(1,default{:});
      ud = get(h_menu,'UserData');

      ht = findobj(gca,'Tag','ctd_station');
      if ~isempty(ht)
         clr = get(ht(1),'Color');
         fontsize = get(ht(1),'FontSize');
         fontweight = get(ht(1),'FontWeight');
         fontangle = get(ht(1),'FontAngle');
         fontname = get(ht(1),'FontName');
      else
         clr = [0 0 .8];
         fontsize = 10;
         fontweight = 'bold';
         fontangle = 'normal';
         fontname = 'Helvetica';
      end

      if ~isempty(ud)
         init = ud.init;
         if isempty(init)
            init = default;
         end
         rivermat = ud.rivermat;
         if isempty(rivermat)
            rivermat = zeros(length(river),1);
         end
      else
         init = default;
         rivermat = zeros(length(river),1);
      end

      %set screen resolution constant (maximum 800x600)
      res = get(0,'screensize');
      ht = 125 + 31.*length(river);

      h_dlg = figure( ...
         'Visible','off', ...
         'Units','pixels', ...
         'Position',[max(10,(res(3)-450).*0.5) max(30,(res(4)-ht).*0.5) 450 ht], ...
         'Name','Plot CTD Station Markers', ...
         'Tag','dlgCTDStations', ...
         'Color',[.95 .95 .95], ...
         'Menubar','none', ...
         'Resize','off', ...
         'NumberTitle','off', ...
         'keypressfcn','figure(gcf)', ...
         'DefaultUicontrolUnits','pixels');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Fontsize',11, ...
         'Fontweight','bold', ...
         'Position',[125 ht-28 65 21], ...
         'ForegroundColor',[0 0 .8], ...
         'BackgroundColor',[.95 .95 .95], ...
         'HorizontalAlignment','center', ...
         'String','Start');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Fontsize',12, ...
         'Fontweight','bold', ...
         'Position',[200 ht-28 65 21], ...
         'ForegroundColor',[0 0 .8], ...
         'BackgroundColor',[.95 .95 .95], ...
         'HorizontalAlignment','center', ...
         'String','End');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Fontsize',12, ...
         'Fontweight','bold', ...
         'Position',[270 ht-28 65 21], ...
         'ForegroundColor',[0 0 .8], ...
         'BackgroundColor',[.95 .95 .95], ...
         'HorizontalAlignment','center', ...
         'String','Interval');

      for n = 1:size(init,1)

         bot = (30*length(river)+75)-30.*(n-1);

         uicontrol(h_dlg, ...
            'Style','text', ...
            'Fontsize',10, ...
            'Position',[20 bot 105 21], ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',[.95 .95 .95], ...
            'HorizontalAlignment','left', ...
            'String',river{n});

         uicontrol(h_dlg, ...
            'Style','edit', ...
            'Fontsize',10, ...
            'HorizontalAlignment','left', ...
            'Position',[125 bot 65 21], ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',[1 1 1], ...
            'String',num2str(init(n,1)), ...
            'Tag',['min',int2str(n)]);

         uicontrol(h_dlg, ...
            'Style','edit', ...
            'Fontsize',10, ...
            'HorizontalAlignment','left', ...
            'Position',[200 bot 65 21], ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',[1 1 1], ...
            'String',num2str(init(n,2)), ...
            'Tag',['max',int2str(n)]);

         uicontrol(h_dlg, ...
            'Style','edit', ...
            'Fontsize',10, ...
            'HorizontalAlignment','left', ...
            'Position',[275 bot 65 21], ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',[1 1 1], ...
            'String',num2str(init(n,3)), ...
            'Tag',['int',int2str(n)]);

         uicontrol(h_dlg, ...
            'Style','checkbox', ...
            'Fontsize',10, ...
            'Position',[350 bot 100 21], ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',[.95 .95 .95], ...
            'Value',rivermat(n), ...
            'String','Include', ...
            'Tag',['check',int2str(n)]);

      end

      h_font = uicontrol(h_dlg, ...
         'Style','text', ...
         'FontName',fontname, ...
         'Fontsize',fontsize, ...
         'Fontweight',fontweight, ...
         'Fontangle',fontangle, ...
         'ForegroundColor',clr, ...
         'BackgroundColor',[1 1 1], ...
         'Position',[220 70 160 25], ...
         'String','font sample', ...
         'Tag','font');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[60 70 70 25], ...
         'String','Font Style', ...
         'Callback','uisetfont(findobj(gcf,''tag'',''font''));');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[140 70 70 25], ...
         'String','Font Color', ...
         'Callback','uisetcolor(findobj(gcf,''tag'',''font''));');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Fontsize',12, ...
         'Position',[0 0 70 25], ...
         'String','Cancel', ...
         'Callback','ctd_stations(''cancel'')');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Fontsize',12, ...
         'Position',[190 0 70 25], ...
         'String','Defaults', ...
         'Tag','cstat_rst', ...
         'UserData',0, ...
         'Callback','ctd_stations(''reset'')');

      uicontrol(h_dlg, ...
         'Fontsize',12, ...
         'Style','pushbutton', ...
         'Position',[380 0 70 25], ...
         'String','Accept', ...
         'Callback','ctd_stations(''eval'')');

      uicontrol(h_dlg, ...
         'Fontsize',10, ...
         'Style','text', ...
         'Position',[5 35 440 21], ...
         'ForegroundColor','k', ...
         'BackgroundColor',[0 .8 .8], ...
         'String','Press ''Defaults'' to view maximum station ranges', ...
         'Tag','cstatmsg');

      uih = struct('rivermat',[],'init',[],'default',[],'transects',[],'ud',[],'h_map',h_map,'h_mapmenu',h_menu);
      uih.rivermat = rivermat;
      uih.init = init;
      uih.default = default;
      uih.transects = transects;
      set(h_dlg,'Visible','on','UserData',uih)
      drawnow

   end

elseif strcmp(op,'eval')

   h = findobj('Tag','dlgCTDStations');
   uih = get(h(1),'UserData');
   h_map = uih.h_map;
   h_message = findobj(h,'Tag','cstatmsg');
   h_reset = findobj(h,'Tag','cstat_rst');
   resetflag = get(h_reset,'UserData');
   transects = uih.transects;

   initvals = uih.init;
   cust_stat = [NaN NaN NaN];
   cust_statlbl = ' ';
   valmatrix = initvals;
   rivmatrix = uih.rivermat;
   initvalmatrix = [uih.default];

   for n = 1:length(transects)

      h_check = findobj(h,'Tag',['check',int2str(n)]);
      rivmatrix(n) = get(h_check,'Value');

      h_min = findobj(h,'Tag',['min',int2str(n)]);
      axmin = str2num(get(h_min,'String'));

      h_max = findobj(h,'Tag',['max',int2str(n)]);
      axmax = str2num(get(h_max,'String'));

      h_int = findobj(h,'Tag',['int',int2str(n)]);
      int = str2num(get(h_int,'String'));

      valmatrix(n,1:3) = [axmin axmax int];

   end

   I_badstart = find((valmatrix(:,1)-initvalmatrix(:,1))<0 |  ...
      (valmatrix(:,1)-initvalmatrix(:,2))>0 | (valmatrix(:,1)-valmatrix(:,2))>0);
   if ~isempty(I_badstart)
      valmatrix(I_badstart,1) = initvalmatrix(I_badstart,1);
   end

   I_badend = find((valmatrix(:,2)-initvalmatrix(:,2))>0 |  ...
      (valmatrix(:,2)-initvalmatrix(:,1))<0 | (valmatrix(:,2)-valmatrix(:,1))<0);
   if ~isempty(I_badend)
      valmatrix(I_badend,2) = initvalmatrix(I_badend,2);
   end

   I_badint = find((valmatrix(:,3)-(valmatrix(:,2)-valmatrix(:,1)))>0 | ...
      valmatrix(:,3)<0.05);
   if ~isempty(I_badint)
      valmatrix(I_badint,3) = initvalmatrix(I_badint,3);
   end

   if ~isempty(I_badstart) | ~isempty(I_badend) | ~isempty(I_badint)

      for n = 1:6
         h_min = findobj(h,'Tag',['min',int2str(n)]);
         set(h_min,'String',num2str(valmatrix(n,1)))
         h_max = findobj(h,'Tag',['max',int2str(n)]);
         set(h_max,'String',num2str(valmatrix(n,2)))
         h_int = findobj(h,'Tag',['int',int2str(n)]);
         set(h_int,'String',num2str(valmatrix(n,3)))
      end

      set(h_message, ...
         'String','Out of range values reset!', ...
         'BackgroundColor',[.8 0 0], ...
         'ForegroundColor','w')

      set(h_reset,'UserData',0)
      refresh(h)

   else

      h_font = findobj(h,'Tag','font');
      fontsize = get(h_font,'FontSize');
      fontweight = get(h_font,'FontWeight');
      fontangle = get(h_font,'FontAngle');
      fontname = get(h_font,'FontName');
      clr = get(h_font,'ForegroundColor');

      close(h)
      figure(h_map)

      for n = 1:length(transects)
         if rivmatrix(n) == 1
            [stat,statlbl] = sub_findstat(transects(n).transect, ...
               valmatrix(n,1),valmatrix(n,2),valmatrix(n,3));
            cust_stat = [cust_stat ; stat];
            cust_statlbl = char(cust_statlbl,statlbl);
         end
      end

      ud = uih.ud;
      ud.init = valmatrix;
      ud.rivermat = rivmatrix;
      set(uih.h_mapmenu,'UserData',ud)

      ht = findobj(gca,'Tag','ctd_station');
      if ~isempty(ht)
         delete(ht)
      end

      if size(cust_stat,1) > 1
         hold on;
         ht = [];
         for n = 1:size(cust_stat,1)
            ht0 = text(cust_stat(n,1),cust_stat(n,2),deblank(cust_statlbl(n,:)));
            ht = [ht;ht0];
         end

         set(ht, ...
            'FontName',fontname, ...
            'FontWeight',fontweight, ...
            'FontAngle',fontangle, ...
            'FontSize',fontsize, ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
            'Color',clr, ...
            'Clipping','on', ...
            'Tag','ctd_station')
      end

   end

elseif strcmp(op,'reset')

   h = findobj('Tag','dlgCTDStations');
   uih = get(h,'UserData');

   h_map = uih.h_map;
   h_reset = findobj(h,'Tag','cstat_rst');
   h_message = findobj(h,'Tag','cstatmsg');

   if ~isempty(uih.h_mapmenu)

      init = uih.default;
      rivermat = zeros(length(uih.transects),1);

      set(h_reset,'UserData',1)
      set(h_message, ...
         'String','Station ranges and selections reset to defaults', ...
         'BackgroundColor',[0 .8 .8], ...
         'ForegroundColor','k')

      for n = 1:6
         h_check = findobj(h,'Tag',['check',int2str(n)]);
         set(h_check,'Value',rivermat(n))
         h_min = findobj(h,'Tag',['min',int2str(n)]);
         set(h_min,'String',num2str(init(n,1)))
         h_max = findobj(h,'Tag',['max',int2str(n)]);
         set(h_max,'String',num2str(init(n,2)))
         h_int = findobj(h,'Tag',['int',int2str(n)]);
         set(h_int,'String',num2str(init(n,3)))
      end

      set(findobj(h,'Tag','fontsize'),'String',8)
      set(findobj(h,'Tag','fontcolor'),'ForegroundColor',[0 0 0])

      refresh(h)

   end

elseif strcmp(op,'cancel')

   h = findobj('Tag','dlgCTDStations');
   uih = get(h,'UserData');

   close(h)

   figure(uih.h_map)

end


function [S_coord,S_labels] = sub_findstat(S_ref,S_begin,S_end,S_int)
%syntax: [S_coord,S_labels] = sub_findstat(S_ref,S_begin,S_end,S_int)
%
%Function called by cst_stat.m that generates arrays of CTD station locations
%(S_coord) and labels (S_labels) for reference transect S_ref from distance
%S_begin to S_end with interval S_int (all distances in km).
%
%modified 9/7/98

N_dec = max(fix(log10(abs(round(S_begin)+1)))+1, ...
   fix(log10(abs(round(S_end)+1)))+1);
if S_begin < 0
   N_dec = N_dec+1;
end

N_prec = 0;
while S_int ~= fix(S_int * 10^N_prec)/10^N_prec
   N_prec = N_prec + 1;
end

formatstr = ['%-' int2str(N_dec+N_prec+1) '.' int2str(N_prec) 'f'];

S_coord = zeros(round((S_end-S_begin)./S_int),3);
S_labels = ' ';

Minref = floor(S_ref(1,3));
Maxref = ceil(S_ref(size(S_ref,1),3));
I_init = ones(size(S_ref,1),1);

N_step = 0;

for n = S_begin:S_int:S_end

   if n >= Minref & n <= Maxref

      N_step = N_step + 1;
      val = I_init .* n;

      [diff,I_match] = min(abs(val-S_ref(:,3)));

      if ~isempty(I_match)

         S_coord(N_step,1:3) = S_ref(I_match,1:3);
         S_labels = str2mat(S_labels,sprintf(formatstr,S_coord(N_step,3)));

      else

         S_coord(N_step,1:3) = [NaN NaN NaN];
         S_labels = str2mat(S_labels,' ');

      end

   end

end

%trim output variables
S_coord = S_coord(1:N_step,:);
S_labels = S_labels(2:N_step+1,:);
