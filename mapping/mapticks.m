function mapticks(op,style,rotate,h_ax)
%Formats plot tickmarks in decimal degrees format with degree symbols or degrees and minutes format
%
%syntax:  mapticks(op,style,rotate,h_ax)
%
%input:
%  op = option (default = 'on')
%     'on' = display formatted ticks
%     'off' = display unformatted ticks
%  style = tick style (default = 'degmin')
%     'degmin' = degrees, minutes
%     'decdeg' = decimal degrees
%     'none' = unformatted
%  rotate = y-tick rotation option (default = 'yes')
%     'yes' = rotate y-ticks 90 degrees, flush to axis
%     'no' = do no rotate y-ticks
%  h_ax = axes handle to modify (default = gca)
%
%output:
%  none
%
%last modified: 06-May-2005

%get Matlab version number
mlverstr = version;
mlversion = str2num(mlverstr(1:3));

axlims = axis;
if axlims(1) >= -180 & axlims(2) <= 180 & axlims(3) >= -90 & axlims(4) <= 90  %check for latlon
   tickmode = 'deg';
   tickmodevis = 'on';
else
   tickmode = 'utm';
   tickmodevis = 'off';
end

if strcmp(tickmode,'utm')
   
   set(gca,'XTickMode','auto','XTickLabelMode','auto','YTickMode','auto','YTickLabelMode','auto')
   
else

   if exist('op') ~= 1 %default to 'on'
      op = 'on';
   end

   if exist('style') ~= 1  %use default style
      if strcmp(get(gca,'Tag'),'mapplot')
         style = get(gca,'UserData');
      else
         style = 'degmin';
      end
   end

   if exist('rotate') ~= 1  %use default y-tick rotation
      rotate = 'yes';
   end

   if exist('h_ax') ~= 1  %use default axis handle
      h_ax = gca;
   end

   %check for prior text labels, delete
   h = findobj(gca,'Tag','yticklabelstring');
   if ~isempty(h)
      delete(h)
   end

   if strcmp(op,'off')

      set(h_ax,'XTickLabelMode','auto', ...
         'YTickLabelMode','auto', ...
         'XTickMode','auto', ...
         'YTickMode','auto', ...
         'TickLength',[.01 .025])

   else

      if strcmp(style,'decdeg')

         set(h_ax,'XTickLabelMode','auto', ...
            'YTickLabelMode','auto', ...
            'XTickMode','auto', ...
            'YTickMode','auto', ...
            'TickLength',[.01 .025])

         if mlversion < 5
            xlabl = get(h_ax,'XTickLabels');
         else
            xlabl = get(h_ax,'XTickLabel');
         end

         width = size(xlabl,2) - 1;

         if width > 2
            precision = width - 3;
         else
            precision = 0;
         end

         f_string = ['%' num2str(width) '.' num2str(precision) 'f'];

         new_xlabl = zeros(1,width+1);

         for n = 1:size(xlabl,1)

            new_xlabl(n,:) = [sprintf(f_string,abs(str2num(xlabl(n,:)))) setstr(176)];

         end

         if mlversion < 5
            ylabl = get(h_ax,'YTickLabels');
         else
            ylabl = get(h_ax,'YTickLabel');
         end

         width = size(ylabl,2);

         if width > 2
            precision = width - 3;
         else
            precision = 0;
         end

         f_string = ['%' num2str(width) '.' num2str(precision) 'f'];

         new_ylabl = zeros(1,width+1);

         for n = 1:size(ylabl,1)

            new_ylabl(n,:) = [sprintf(f_string,abs(str2num(ylabl(n,:)))) setstr(176)];

         end

         if mlversion < 5
            set(h_ax,'XTickLabels',new_xlabl)
            set(h_ax,'YTickLabels',new_ylabl)
         else
            set(h_ax,'XTickLabel',char(new_xlabl))
            set(h_ax,'YTickLabel',char(new_ylabl))
         end

         if strcmp(rotate,'yes')
            rotateyticks
         end

      elseif strcmp(style,'degmin')  %degrees, minutes format

         curaxis = axis;

         longdiff = (curaxis(2) - curaxis(1)) * 60;
         latdiff = (curaxis(4) - curaxis(3)) * 60;
         maxdiff = max(longdiff,latdiff);

         factor = 1/10^floor(log10(maxdiff/6));
         mins = round(maxdiff/6*factor)/factor;
         prec = max(log10(factor),0);

         tickvals = [mins,prec,mins,prec];

         maplabels(tickvals(1),tickvals(2),tickvals(3),tickvals(4),h_ax)

         set(gca,'TickLength',[.01 .025])

         if strcmp(rotate,'yes')
            rotateyticks
         end

      elseif strcmp(style,'none')  %default format

         set(h_ax,'XTickLabelMode','auto', ...
            'YTickLabelMode','auto', ...
            'XTickMode','auto', ...
            'YTickMode','auto', ...
            'TickLength',[.01 .025])

      else  %ticks off

         set(h_ax,'XTick',[], ...
            'YTick',[], ...
            'ZTick',[], ...
            'XTickLabel','', ...
            'YTickLabel','', ...
            'ZTickLabel','', ...
            'TickLength',[0 0])

      end

   end

end


%subfunction declaration
function maplabels(nminlong,ndiglong,nminlat,ndiglat,h_ax);

%   maplabels  Puts degrees and minutes on map axes instead of decimal degrees
%
%   Usage: maplabels(nnminlong,ndiglong,nminlat,ndiglat);
%
%   Inputs:
%          nminlon  = minutes of spacing between longitude labels
%          ndiglong = number of decimal places for longitude minute label
%
%          nminlon  = minutes of spacing between latitude labels
%          ndiglong = number of decimal places for latitude minute label
%
% Example:  maplabels(15,1,20,0);
%               labels lon every 15 minutes with 1 decimal place (eg 70 40.1')
%           and labels lat every 20 minutes with no decimal place (eg 42 20')
%
% Version 1.0 Rocky Geyer  (rgeyer@whoi.edu)
% Version 1.1 J. List (6/5/95) had apparent bug with
%  ndigit being set to 0: routine degmins blows up.
%  Fixed by adding arguments specifying number of decimal
%  digits (can vary from 0 to 2)
%
% Version 1.2 W. Sheldon (2/29/2000) updated for Matlab 5.x changes

if ~exist('h_ax')
   h_ax = gca;
end

%get Matlab version number
mlverstr = version;
mlversion = str2num(mlverstr(1:3));

nfaclong=60/nminlong;
nfaclat=60/nminlat;

if nminlong>0;

   xlim=get(h_ax,'xlim');
   xlim(1)=floor(xlim(1)*nfaclong)/nfaclong;
   xtick=xlim(1):1/nfaclong:xlim(2);
   set(h_ax,'xtick',xtick)

   % modified 6/5/95 J.List:

   xticklab=degmins(-xtick,ndiglong);

   if mlversion < 5
      set(h_ax,'xticklabels',xticklab)
   else
      set(h_ax,'xticklabel',xticklab)
   end

end

if nminlat>0;

   ylim=get(h_ax,'ylim');
   ylim(1)=floor(ylim(1)*nfaclat)/nfaclat;
   ytick=ylim(1):1/nfaclat:ylim(2);
   set(h_ax,'ytick',ytick)

   % modified 6/5/95 J.List:

   yticklab=degmins(-ytick,ndiglat);

   if mlversion < 5
      set(h_ax,'yticklabels',yticklab)
   else
      set(h_ax,'yticklabel',yticklab)
   end

end
