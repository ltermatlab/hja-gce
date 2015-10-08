<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <!-- Stylesheet for transforming USGS site descriptions to tab-delimited text (Wade Sheldon, GCE-LTER, rev. 02-Jun-2010) -->
    
    <!-- set general options for encoding, specifying no indenting and stripping white-space-only text elements globally -->
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:strip-space elements="*"/>
    
    <!-- main template -->
    <xsl:template match="/">
        
        <!-- generate column headers -->
        <xsl:text>Program&#09;Station&#09;Description&#09;SiteTypeCode&#09;StateCode&#09;Latitude&#09;Longitude&#09;Datum&#09;</xsl:text>
        <xsl:text>Altitude&#09;Drainage&#09;HydrologicUnitCode&#09;Realtime&#xD;</xsl:text>
        
        <!-- loop through site elements -->
        <xsl:for-each select="usgs_nwis/site">
            
            <!-- add fields separated by tabs -->
            <xsl:text>USGS&#09;</xsl:text>
            <xsl:value-of select="site_no" /><xsl:text>&#09;</xsl:text>
            <xsl:value-of select="station_nm" /><xsl:text>&#09;</xsl:text>
            <xsl:value-of select="site_tp_cd" /><xsl:text>&#09;</xsl:text>
            <xsl:value-of select="state_cd" /><xsl:text>&#09;</xsl:text>
            <xsl:value-of select="dec_lat_va" /><xsl:text>&#09;</xsl:text>
            <xsl:value-of select="dec_long_va" /><xsl:text>&#09;</xsl:text>
            <xsl:value-of select="dec_lat_long_datum_cd" /><xsl:text>&#09;</xsl:text>
            <xsl:value-of select="alt_va" /><xsl:text>&#09;</xsl:text>
            <xsl:value-of select="drain_area_va"/><xsl:text>&#09;</xsl:text>
            <xsl:value-of select="huc_cd" /><xsl:text>&#09;</xsl:text>
            <xsl:value-of select="rt_bol" /><xsl:text>&#xD;</xsl:text>
            
        </xsl:for-each>
        
    </xsl:template>
    
</xsl:stylesheet>