function [data,msg] = process_toa5(fn_source,pn_source,template)
%test processing script for sample Campbell data
%
%syntax: [data,msg] = process_toa5(fn_source,pn_source,template)

%initialize output
data = [];
msg = '';

if nargin >= 2
   
   %check for no template
   if exist('template','var') ~= 1
      template = '';
   end

   %import data
   data = imp_campbell_toa5(fn_source,pn_source,template);

   %pad date gaps, removing any duplicate records
   data = pad_date_gaps(data,'Date',1,1);

   %remove and interpolate data values flagged 'I'
   cols = listdatacols(data);  %get array of data/calculation columns
   data = nullflags(data,'IQ',cols);
   data = interp_missing(data,'Date',cols,'pchip');

   %document anomalies
   data = add_anomalies(data,23,'-',1,[]);
   
   %check for an error somewhere
   if isempty(data)
      msg = 'oops - an error occurred';
   end

else
   msg = 'fn_source and pn_source are required';
end