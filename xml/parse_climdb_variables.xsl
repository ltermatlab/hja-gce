<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" encoding="UTF-8" indent="no"/>
<xsl:strip-space elements="*"/>

<!--
xslt for parsing ClimDB variable information from http://climhy.lternet.edu/ to create a CSV text file
with header fields for importing into the GCE Data Toolbox for MATLAB using 'imp_ascii.m'
by Wade Sheldon, GCE-LTER
email: sheldon@uga.edu
last edited: 30-Apr-2007
-->

<!-- add column headings -->
<xsl:template match="/">
    <xsl:text>name:Site&#09;Station&#09;Variable&#09;Date_Start&#09;Date_End&#09;Date_Latest&#xD;</xsl:text>
    <xsl:text>units:none&#09;none&#09;none&#09;YYYY-MM-DD&#09;YYYY-MM-DD&#09;YYYY-MM-DD&#xD;</xsl:text>
    <xsl:text>description:Acronym of the site contributing the data&#09;Station code&#09;Variable name&#09;Earliest date of record&#09;Latest date of record&#09;Date of last update&#xD;</xsl:text>
    <xsl:text>datatype:s&#09;s&#09;s&#09;s&#09;s&#09;s&#xD;</xsl:text>
    <xsl:text>variabletype:nominal&#09;nominal&#09;nominal&#09;datetime&#09;datetime&#09;datetime&#xD;</xsl:text>
    <xsl:text>numbertype:none&#09;none&#09;none&#09;none&#09;none&#09;none&#xD;</xsl:text>
    <xsl:text>precision:0&#09;0&#09;0&#09;0&#09;0&#09;0&#xD;</xsl:text>
    <xsl:text>Dataset_Title:Sites, Stations and Variables in ClimDB/HydroDB&#xD;</xsl:text>
    <xsl:for-each select="info/variables/variable_item">
        <xsl:text/><xsl:value-of select="code"/><xsl:text>&#09;</xsl:text><xsl:text/>
        <xsl:value-of select="name"/><xsl:text>&#09;</xsl:text><xsl:text/>
        <xsl:value-of select="variable"/><xsl:text>&#09;</xsl:text><xsl:text/>
        <xsl:value-of select="begin"/><xsl:text>&#09;</xsl:text><xsl:text/>
        <xsl:value-of select="end_date"/><xsl:text>&#09;</xsl:text><xsl:text/>
        <xsl:value-of select="last"/><xsl:text>&#xD;</xsl:text>
    </xsl:for-each>
</xsl:template>

</xsl:stylesheet>