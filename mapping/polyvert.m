function polyvert(op,initvals,callback,h_figure,h_report)
%Polygon numerical vertices dialog called by 'createpoly'
%
%syntax:  polyvert(op,initvals,callback,h_figure,h_report)
%
%input:
%  op = operation (default = 'init')
%
%output:
%  none
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
%last modified: 08-May-2003

cancel = 0;

if nargin > 0

   if strcmp(op,'init')

      if nargin == 5

         %clear prior instances of dialog
         h_dlg = findobj('Tag','polyvertdlg');
         if ~isempty(h_dlg)
            close(h_dlg)
         end

         h_integrate = gcf;

         screen = get(0,'ScreenSize');

      	polygon = initvals{1,4};
         polyrows = size(polygon,1);

         switch initvals{1,2}
         case 'polygon'
            style = 'polygon';
            promptstr = 'Enter Coordinates for the Polygon Vertices';
            numrows = 10;
            rowlbls = cellstr(int2str([1:10]'));
            if polyrows < 100
               polygon = [polygon ; ones(100-polyrows,1)*[NaN NaN]];
            else
               polygon = polygon(1:100,:);
            end
   	      polyrows = 100;
         case 'circle'
            style = 'circle';
            promptstr = 'Enter Coordinates to Define the Circle';
            numrows = 2;
            rowlbls = [{'Center'};{'Perimeter'}];
         case 'rectangle'
            style = 'rectangle';
            promptstr = 'Enter Coordinates for the Rectangle Corners';
            numrows = 4;
            rowlbls = [{'Corner 1'};{'Corner 2'};{'Corner 3'};{'Corner 4'}];
         otherwise
            style = 'freeform';
            promptstr = 'Enter Coordinates for the Polygon Vertices';
            numrows = 10;
            rowlbls = cellstr(int2str([1:10]'));
            if polyrows < 100
               polygon = [polygon ; ones(100-polyrows,1)*[NaN NaN]];
            else
               polygon = polygon(1:100,:);
            end
   	      polyrows = 100;
         end

         figheight = min(screen(4)+75,24*(numrows+4));
         figwidth = 260;

         bgcolor = [.95 .95 .95];

         h_dlg = figure( ...
            'Visible','off', ...
            'Color',bgcolor, ...
            'NumberTitle','off', ...
            'MenuBar','none', ...
            'Resize','off', ...
            'Name','Polygon Vertices', ...
            'Units','pixels', ...
            'Position',[screen(3)-(figwidth+5) min(330,screen(4)-figheight-30) ...
               figwidth figheight], ...
            'DefaultUiControlUnits','pixels', ...
            'Tag','polyvertdlg', ...
            'UserData',[{style} {initvals} {h_integrate} {callback} {h_figure} {h_report}]);

         uicontrol(h_dlg, ...
            'Style','text', ...
            'Position',[0 figheight-30 figwidth 20], ...
            'String',promptstr, ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','bold', ...
            'HorizontalAlignment','center', ...
            'ForegroundColor',[0 0 0]);

         h_coord = uicontrol(h_dlg, ...
            'Style','text', ...
            'Position',[0 figheight-60 figwidth./3.5 20], ...
            'String','Coordinate', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',bgcolor, ...
            'HorizontalAlignment','center', ...
            'ForegroundColor',[0 0 0], ...
            'Tag','edithandles', ...
            'UserData',[]);

          uicontrol(h_dlg, ...
            'Style','text', ...
            'Position',[figwidth./3.5 figheight-60 figwidth./3.5 20], ...
            'String','X value', ...
            'HorizontalAlignment','center', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',bgcolor);

         uicontrol(h_dlg, ...
            'Style','text', ...
            'Position',[figwidth./1.75 figheight-60 figwidth./3.5 20], ...
            'String','Y value', ...
            'HorizontalAlignment','center', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',bgcolor);

         uicontrol(h_dlg, ...
            'Style','pushbutton', ...
            'Position',[0 0 60 25], ...
            'String','Cancel', ...
            'Callback','polyvert(''cancel'')');

         uicontrol(h_dlg, ...
            'Style','pushbutton', ...
            'Position',[figwidth-60 0 60 25], ...
            'String','Proceed', ...
            'Tag','cmdProceed', ...
            'UserData',[], ...
            'Callback','polyvert(''eval'')');

         h_edit = cell(numrows,3);

         for n = 1:numrows

            rowpos = figheight - 60 - (n * 24);

            exstr = '';
            emstr = '';

            if n <= polyrows & ~isnan(polygon(n,1))
  	            exstr = sprintf('%0.7g',polygon(n,1));
               emstr = sprintf('%0.7g',polygon(n,2));
            end

	         h_row = uicontrol(h_dlg, ...
   	         'Style','text', ...
      	      'Position',[0 rowpos figwidth./3.5 18], ...
         	   'String',char(rowlbls{n,1}), ...
            	'HorizontalAlignment','center', ...
	            'ForegroundColor',[0 0 0], ...
               'BackgroundColor',bgcolor, ...
               'Tag',['rowlbl' int2str(n)]);

	         h_ex = uicontrol(h_dlg, ...
   	         'Style','edit', ...
      	      'Position',[figwidth./3.5+3 rowpos figwidth./3.5-6 20], ...
         	   'String',exstr, ...
            	'HorizontalAlignment','left', ...
               'ForegroundColor',[0 0 0], ...
               'BackgroundColor',[1 1 1], ...
               'Tag',['ex_row' int2str(n)]);

	         h_em = uicontrol(h_dlg, ...
   	         'Style','edit', ...
      	      'Position',[figwidth./1.75+3 rowpos figwidth./3.5-6 20], ...
         	   'String',emstr, ...
            	'HorizontalAlignment','left', ...
               'ForegroundColor',[0 0 0], ...
               'BackgroundColor',[1 1 1], ...
               'Tag',['em_row' int2str(n)]);

            h_edit{n,1} = h_row;
            h_edit{n,2} = h_ex;
            h_edit{n,3} = h_em;

         end

         set(h_coord,'UserData',h_edit)

         if numrows == 10
            slidervis = 'on';
         else
            slidervis = 'off';
         end

         uicontrol(h_dlg, ...
            'Style','Slider', ...
            'Visible',slidervis, ...
            'Position',[figwidth.*0.89 35 figwidth.*0.07 figheight-90], ...
            'Min',1, ...
            'Max',91, ...
            'SliderStep',[1/90 10/90], ...
            'Value',91, ...
            'BackgroundColor',[.75 .75 .75], ...
            'Tag','slider', ...
            'UserData',[{polygon} {[1 10]}], ...
            'Callback','polyvert(''slider'')');

         set(h_dlg,'Visible','on')

      end

   else

      %get dialog handle and stored polygon data
      h_dlg = findobj('Tag','polyvertdlg');
      storeddata = get(h_dlg(1),'UserData');

      %parse stored data
      style = storeddata{1};
      initvals = storeddata{2};
      polyname = initvals{1,1};
      h_integrate = storeddata{3};
      callback = storeddata{4};
      h_figure = storeddata{5};
      h_report = storeddata{6};

      %get slider info
      h_slider = findobj(h_dlg,'Tag','slider');
      sliderval = get(h_slider,'Value');
      sliderdata = get(h_slider,'UserData');
      sliderpos = get(h_slider,'Max')-sliderval+1;

      %get row handles
      h_handles = findobj(h_dlg,'Tag','edithandles');
      h_edit = get(h_handles,'UserData');

      if strcmp(op,'cancel')

         close(h_dlg)
         figure(h_integrate)

      elseif strcmp(op,'slider')

         newpos = [sliderpos sliderpos+9];
         oldpos = sliderdata{2};

         if sum(newpos == oldpos) < 2  %check for new position

            polygon = sliderdata{1};
            polyfrag = zeros(10,2);

            for n = 1:10

               ex_val = str2num(get(h_edit{n,2},'String'));
               em_val = str2num(get(h_edit{n,3},'String'));

             	if ~isempty(ex_val) & ~isempty(em_val)
            		polyfrag(n,1:2) = [ex_val em_val];
	            else
   	            polyfrag(n,1:2) = [NaN NaN];
      	      end

            end

            polygon(oldpos(1):oldpos(2),:) = polyfrag;  %update polygon

            for n = 1:10

               rownum = newpos(1)+n-1;

               exstr = '';
               emstr = '';

               if rownum <= 100 & ~isnan(polygon(rownum,1))
   		         exstr = sprintf('%0.7g',polygon(rownum,1));
      		      emstr = sprintf('%0.7g',polygon(rownum,2));
               end

               set(h_edit{n,1},'String',int2str(rownum))
   	         set(h_edit{n,2},'String',exstr)
      	      set(h_edit{n,3},'String',emstr)

            end

	         drawnow

            set(h_slider,'UserData',[{polygon} {newpos}])  %update stored values

         end

      elseif strcmp(op,'eval')

         switch style
         case 'circle'
            numrows = 2;
            polystyle = 2;
         case 'rectangle'
            numrows = 4;
            polystyle = 3;
         otherwise  %free-form polygon
            numrows = 10;
            polystyle = 1;
         end

         newpolygon = zeros(numrows,2);

         for n = 1:numrows

            ex_val = str2num(get(h_edit{n,2},'String'));
            em_val = str2num(get(h_edit{n,3},'String'));

            if ~isempty(ex_val) & ~isempty(em_val)
               newpolygon(n,1:2) = [ex_val em_val];
            else
               newpolygon(n,1:2) = [NaN NaN];
            end

         end

         close(h_dlg)

         figure(h_integrate)

         drawnow

         abort = 0;

         switch style

         case 'rectangle'
            polygon = newpolygon;
            if length(find(isnan(polygon))) == 0  %check for nulls
               xmin = min(polygon(:,1));
               xmax = max(polygon(:,1));
               ymin = min(polygon(:,2));
               ymax = max(polygon(:,2));
	            xdata = [xmin ; xmin ; xmax ; xmax ; xmin];
               ydata = [ymin ; ymax ; ymax ; ymin ; ymin];
            else
               abort = 1;
            end

         case 'circle'
            polygon = newpolygon;
            if length(find(isnan(polygon))) == 0  %check for nulls
               [xdata,ydata] = circle(polygon(1,1),polygon(1,2), ...
                  radcalc(polygon(:,1),polygon(:,2)),40);
            else
               abort = 1;
            end

         case 'polygon'  %polygon

            polygon = sliderdata{1};  %get stored polygon
            rownums = sliderdata{2};  %get scroll position
            polygon(rownums(1):rownums(2),:) = newpolygon; %update polygon

            if length(find(~isnan(polygon(:,1)))) >= 3
               polygon = polygon(find(~isnan(polygon(:,1))),:);
               xdata = [polygon(:,1) ; polygon(1,1)];
               ydata = [polygon(:,2) ; polygon(1,2)];
            else
               abort = 1;
            end

         otherwise  %freeform

            polygon = sliderdata{1};  %get stored polygon
            rownums = sliderdata{2};  %get scroll position
            polygon(rownums(1):rownums(2),:) = newpolygon; %update polygon

            if length(find(~isnan(polygon(:,1)))) >= 1
               polygon = polygon(find(~isnan(polygon(:,1))),:);
               xdata = [polygon(:,1)];
               ydata = [polygon(:,2)];
            else
               abort = 1;
            end

         end

         if abort == 0
           	polydate = datestr(now,0);
            polydata = [{polyname} {style} {polydate} {[xdata ydata]}];
            if ~isempty(h_figure)
               figure(h_figure)
            end
 	         set(h_report,'UserData',polydata)
            if ~isempty(callback)
        	      eval(callback)
            end
        	else
              errorbox('init',['Invalid vertex coordinates - ''' ...
                    polyname ''' not created'])
         end

      end

   end

end