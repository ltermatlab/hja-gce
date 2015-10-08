function newpoly(op,callback,h_figure,h_report,initvals)
%New polygon dialog called by 'surfintegrate'
%
%syntax:  newpoly(op,callback,h_figure,h_report,initvals)
%
%
%(c)2002,2003,2004 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified 29-Jun-2004

cancel = 0;

if nargin > 0

   if strcmp(op,'init')

      if nargin >= 4

         %clear prior instances of dialog
         h_dlg = findobj('Tag','newpolydialog');
         if ~isempty(h_dlg)
            close(h_dlg)
         end

         editmode = 0;
         defaultvals = [{'New Polygon'} {2} {[]} {[]}];

         if exist('initvals') == 1
         	if iscell(initvals)
               if sum(size(initvals) == [1 4]) == 2
                  editmode = 1;
               end
            end
         end

         if editmode == 0
            initvals = defaultvals;
	         figname = 'New Polygon';
            graphval = 1;
            numval = 0;
         else
	         figname = 'Edit Polygon';
            graphval = 0;
            numval = 1;
         end

         h_integrate = gcf;

         screen = get(0,'ScreenSize');

         bgcolor = [.95 .95 .95];

         h_dlg = figure( ...
            'Visible','off', ...
            'Color',bgcolor, ...
            'Name',figname, ...
            'NumberTitle','off', ...
            'MenuBar','none', ...
            'Resize','off', ...
            'Units','pixels', ...
            'Position',[screen(3)-360 330 350 120], ...
            'DefaultUiControlUnits','normal', ...
            'Tag','newpolydialog', ...
            'UserData',[{h_integrate} {callback} {h_figure} {h_report} {initvals}]);

         uicontrol(h_dlg, ...
            'Style','text', ...
            'Position',[.02 .78 .6 .13], ...
            'String','Name', ...
            'FontWeight','bold', ...
            'HorizontalAlignment','center', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',bgcolor);

         uicontrol(h_dlg, ...
            'Style','text', ...
            'Position',[.65 .78 .33 .13], ...
            'String','Style', ...
            'FontWeight','bold', ...
            'HorizontalAlignment','center', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',bgcolor);

         uicontrol(h_dlg, ...
            'Style','edit', ...
            'Position',[.02 .6 .6 .18], ...
            'String',initvals{1,1}, ...
            'HorizontalAlignment','left', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',[1 1 1], ...
            'Tag','polyname');

         uicontrol(h_dlg, ...
            'Style','popup', ...
            'Position',[.65 .6 .33 .18], ...
            'String','Freeform|Polygon|Circle|Rectangle', ...
            'Value',initvals{1,2}, ...
            'HorizontalAlignment','center', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',[1 1 1], ...
            'Tag','polystyle');

         uicontrol(h_dlg, ...
            'Style','text', ...
            'Position',[.18 .32 .15 .13], ...
            'String','Method', ...
            'FontWeight','bold', ...
            'HorizontalAlignment','center', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',bgcolor);

         if graphval == 1
            c = [0 1 0];
         else
            c = bgcolor;
         end

         uicontrol(h_dlg, ...
            'Style','togglebutton', ...
            'Position',[.33 .3 .2 .2], ...
            'String','Graphical', ...
            'Value',graphval, ...
            'HorizontalAlignment','center', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',c, ...
            'Tag','togglegraph', ...
            'Callback','newpoly(''tog_graph'')');

         if numval == 1
            c = [0 1 0];
         else
            c = bgcolor;
         end

         uicontrol(h_dlg, ...
            'Style','togglebutton', ...
            'Position',[.54 .3 .2 .2], ...
            'String','Numerical', ...
            'Value',numval, ...
            'HorizontalAlignment','center', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',c, ...
            'Tag','togglenum', ...
            'Callback','newpoly(''tog_num'')');

         uicontrol(h_dlg, ...
            'Style','pushbutton', ...
            'Position',[0 0 .2 .2], ...
            'String','Cancel', ...
            'Callback','newpoly(''cancel'')');

         uicontrol(h_dlg, ...
            'Style','pushbutton', ...
            'Position',[.8 0 .2 .2], ...
            'String','Proceed', ...
            'Tag','cmdProceed', ...
            'UserData',[], ...
            'Callback','newpoly(''eval'')');

         set(h_dlg,'Visible','on')

      else  %missing arguments

         cancel = 1;

      end

   else

      h_dlg = findobj('Tag','newpolydialog');

      h_graph = findobj(h_dlg,'Tag','togglegraph');
      h_num = findobj(h_dlg,'Tag','togglenum');

      h_style = findobj(h_dlg,'Tag','polystyle');
      polystyle = get(h_style,'Value');

      storeddata = get(h_dlg,'UserData');

      h_integrate = storeddata{1,1};
      callback = storeddata{1,2};
      h_figure = storeddata{1,3};
      h_report = storeddata{1,4};
      initvals = storeddata{1,5};

      if strcmp(op,'cancel')

         close(h_dlg)
         figure(h_integrate)

      elseif strcmp(op(1,1:3),'tog')

         h_button = findobj(h_dlg,'Tag','cmdProceed');
         coldclr = get(h_button,'BackgroundColor');
         hotclr = [0 1 0];

         if strcmp(op,'tog_graph')
            set(h_graph,'BackgroundColor',hotclr)
            set(h_num,'Value',0,'BackgroundColor',coldclr)
         elseif strcmp(op,'tog_num')
            set(h_graph,'Value',0,'BackgroundColor',coldclr)
            set(h_num,'BackgroundColor',hotclr)
			end

      elseif strcmp(op,'eval')

         h_name = findobj(h_dlg,'Tag','polyname');
         polyname = deblank(get(h_name,'String'));
         if isempty(polyname)
            polyname = 'unnamed polygon';
         end

         if get(h_graph,'Value') == 1
            method = 'graph';
         else
            method = 'num';
         end

         polygon = initvals{1,4};

         switch polystyle
         case 1,
            style = 'freeform';
            if ~isempty(polygon)
	            initpolygon = polygon(1:max(1,size(polygon,1)-1),:);
            else
               initpolygon = [];
            end
         case 2,
            style = 'polygon';
            if ~isempty(polygon)
	            initpolygon = polygon(1:max(1,size(polygon,1)-1),:);
            else
               initpolygon = [];
            end
         case 3,
            style = 'circle';
            if ~isempty(polygon)
               initpolygon = [mean([min(polygon(:,1)) max(polygon(:,1))]) ...
                  mean([min(polygon(:,2)) max(polygon(:,2))]); ...
                  max(polygon(:,1)) ...
                  mean([min(polygon(:,2)) max(polygon(:,2))])];
            else
               initpolygon = [];
            end
         otherwise
            style = 'rectangle';
            if ~isempty(polygon)
	            initpolygon = [min(polygon(:,1)) min(polygon(:,2)) ;
   	            min(polygon(:,1)) max(polygon(:,2)) ;
      	         max(polygon(:,1)) max(polygon(:,2)) ;
         	      max(polygon(:,1)) min(polygon(:,2))];
            else
               initpolygon = [];
            end
         end

         close(h_dlg)

         if strcmp(method,'graph')

            if ~strcmp(style,'polygon') & ~strcmp(style,'freeform')

               figure(h_figure)
               drawnow

               if ~isempty(initvals{1,4})  %draw current polygon if present

                  h_axes = findobj(h_figure,'Type','axes');

                  if ~isempty(h_axes)

                     if strcmp(get(h_axes(1),'Tag'),'Colorbar') ~= 1
                        h_ax = h_axes(1);
                     else
                        h_ax = h_axes(2);
                     end

                     zlim = get(h_ax,'ZLim');
                     polygon = initvals{1,4};

                     if ~isempty(polygon)

                        %clear pre-existing lines
                        h_line = findobj(h_figure,'Tag','polyline');
                        if ~isempty(h_line)
                           delete(h_line)
                        end

                        %draw original polygon
                        line('Parent',h_ax, ...
                           'XData',polygon(:,1), ...
                           'YData',polygon(:,2), ...
                           'ZData',ones(size(polygon,1),1).*(zlim(2)+eps), ...
                           'LineWidth',1, ...
                           'Color',[.8 .8 .8], ...
                           'Tag','polyline');

                     end

                  end

               end

               refresh(h_figure)

               [polygon,h_line] = lasso(style);

               delete(h_line)
               refresh(h_figure)

               figure(h_integrate)

               if ~isempty(polygon)
                  polydata = [{polyname} {style} {datestr(now,0)} {polygon}];
                  set(h_report,'UserData',polydata)
                  eval(callback)
               end

            else  %polygon, freeform -- send to edit_polygon

               edit_polygon('init',[],polyname,'',h_figure,style)

            end

         else

            polydata = [{polyname} {style} {datestr(now,0)} {initpolygon}];

            figure(h_integrate)

            drawnow

            polyvert('init',polydata,callback,h_figure,h_report);

         end

      end

   end

end
