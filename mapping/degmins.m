function degstring = degmins(degrees,ndigit)
%Creates a degrees and minutes label for use in labeling map axes
%
%syntax: degstring = degmins(degrees,ndigit)
%
%input:
%  degrees = decimal degrees
%  ndigit = number of decimal places for minutes
%
%output:
%  degstring = formatted label string
%
%Note: Source code obtained from http://woodshole.er.usgs.gov/operations/sea-mat/
%  Version 1.0 Rocky Geyer (rgeyer@whoi.edu)
%  Version 1.1 J.List (jlist@usgs.gov)
%     fixed bug
%  Version 1.2 W. Sheldon (sheldon@uga.edu) fixed
%     problems with rounding errors, standardized format spacing
%
%last modified 12-Sep-2010

%Original documentation heading:
%
% Usage:  degstring=degmins(degrees,ndigit);
%
%    Inputs:  degrees = decimal degrees
%             ndigit  = number of decimal places for minutes
%
%    Outputs: degstring = string containing label
% Version 1.0 Rocky Geyer (rgeyer@whoi.edu)
% Version 1.1 J.List (jlist@usgs.gov)
%             fixed bug

degrees=degrees(:);

for i=1:length(degrees);

   if degrees(i)<0
     degrees(i)=-degrees(i);
   end

   deg(i,1)=floor(degrees(i));
   deg(i,2)=(degrees(i)-deg(i,1))*60;

   if ndigit==0;
     degstring(i,:)=sprintf('%3d%s%02d%s',deg(i,1),...
                    setstr(176),round(deg(i,2)),'''');
   else
     format_str = ['%3d%s%0' num2str(ndigit+3) '.' num2str(ndigit) 'f%s'];
     degstring(i,:)=sprintf(format_str,deg(i,1),...
                    setstr(176),round(deg(i,2)*10^ndigit)/10^ndigit,'''');
   end
   
end
