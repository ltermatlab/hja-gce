function [data,msg] = fetch_ws1_ec_tempprof(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = 'LNDB_WS1_EC_TEMPPROF_1';
end

% qry = ['SELECT hjaws1ec_Tempprof_arch1.TmStamp'...
%     ' ,	hjaws1ec_Tempprof_arch1.RecNum'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tair_12m_Avg_a'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tair_18m_Avg_a'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tair_1m_Avg_a'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tair_23m_Avg_a'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tair_29m_Avg_a'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tair_37m_Avg_a'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tair_4m_Avg_a'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tair_7m_Avg_a'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tgasinlet_Avg_a'...
%     ' FROM 	metdat.dbo.hjaws1ec_Tempprof_arch1 '...
%     ' WHERE year(TmStamp) = 2013'...
%     ' ORDER BY TmStamp ASC '];

% qry = ['SELECT hjaws1ec_Tempprof_arch1.TmStamp'...
%     ' ,	hjaws1ec_Tempprof_arch1.RecNum'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tair_12m_Avg'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tair_18m_Avg'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tair_1m_Avg'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tair_23m_Avg'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tair_29m_Avg'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tair_37m_Avg'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tair_4m_Avg'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tair_7m_Avg'...
%     ' ,	hjaws1ec_Tempprof_arch1.Tgasinlet_Avg'...
%     ' FROM 	metdat.dbo.hjaws1ec_Tempprof_arch1 '...
%     ' WHERE year(TmStamp) = 2014'...
%     ' ORDER BY TmStamp ASC '];

% qry = ['SELECT hjaws1ec_Tempprof.TmStamp'...
%     ' ,	hjaws1ec_Tempprof.RecNum'...
%     ' ,	hjaws1ec_Tempprof.Tair_12m_Avg'...
%     ' ,	hjaws1ec_Tempprof.Tair_18m_Avg'...
%     ' ,	hjaws1ec_Tempprof.Tair_1m_Avg'...
%     ' ,	hjaws1ec_Tempprof.Tair_23m_Avg'...
%     ' ,	hjaws1ec_Tempprof.Tair_29m_Avg'...
%     ' ,	hjaws1ec_Tempprof.Tair_37m_Avg'...
%     ' ,	hjaws1ec_Tempprof.Tair_4m_Avg'...
%     ' ,	hjaws1ec_Tempprof.Tair_7m_Avg'...
%     ' ,	hjaws1ec_Tempprof.Tgasinlet_Avg'...
%     ' FROM 	metdat.dbo.hjaws1ec_Tempprof '...
%     ' WHERE year(TmStamp) = 2014'...
%     ' ORDER BY TmStamp ASC '];

qry = ['SELECT hjaws1ec_Tempprof.TmStamp'...
    ' ,	hjaws1ec_Tempprof.RecNum'...
    ' ,	hjaws1ec_Tempprof.Tair_12m_Avg'...
    ' ,	hjaws1ec_Tempprof.Tair_18m_Avg'...
    ' ,	hjaws1ec_Tempprof.Tair_1m_Avg'...
    ' ,	hjaws1ec_Tempprof.Tair_23m_Avg'...
    ' ,	hjaws1ec_Tempprof.Tair_29m_Avg'...
    ' ,	hjaws1ec_Tempprof.Tair_37m_Avg'...
    ' ,	hjaws1ec_Tempprof.Tair_4m_Avg'...
    ' ,	hjaws1ec_Tempprof.Tair_7m_Avg'...
    ' ,	hjaws1ec_Tempprof.Tgasinlet_Avg'...
    ' FROM 	metdat.dbo.hjaws1ec_Tempprof '...
    ' WHERE   TmStamp >= DATEADD(day, -21, GETDATE())'... 
    ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);


