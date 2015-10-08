<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:import href="http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_webpage.xsl" />
<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />

<!-- call main template to generate page layout and scaffolding, which calls topnav and body templates at appropriate points in doc -->
<xsl:template match="/">
    <xsl:call-template name="main">
        <xsl:with-param name="url_css">http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_webpage.css</xsl:with-param>
    </xsl:call-template>
</xsl:template>
    
<!-- template for top navigation -->
<xsl:template name="topnav">
    <xsl:for-each select="/root/navigation/item">
        <xsl:variable name="url"><xsl:value-of select="url"/></xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length(normalize-space($url)) &gt; 0">
                <!-- generate standard menu button link -->
                <a><xsl:attribute name="href"><xsl:value-of select="$url"/></xsl:attribute><xsl:value-of select="label"/></a> &gt;
            </xsl:when>
            <xsl:otherwise>
                <!-- generate current page label without link when url empty -->
                <span>
                    <xsl:attribute name="class"><xsl:text>current-page</xsl:text></xsl:attribute>
                    <xsl:value-of select="label"/>
                </span>                
            </xsl:otherwise>
        </xsl:choose>
     </xsl:for-each>
</xsl:template>

<!-- template for page contents  -->
<xsl:template name="body">
    
    <!-- xsl for index page -->
    <xsl:for-each select="/root">
        <h1><xsl:value-of select="title"/></h1>
        <div id="available-files">
        <table>
            <tr>
                <th>Data Set</th>
                <th>Interval</th>
                <th>Period</th>
                <th>Links</th>
                <th>File Downloads</th>
            </tr>
            <xsl:for-each select="dataset_summary">
                <tr>
                    <td class="title"><a><xsl:attribute name="href"><xsl:value-of select="url_details"/></xsl:attribute><xsl:value-of select="dataset_id"/></a><xsl:text>:</xsl:text><br/>
					   <xsl:value-of select="dataset_title"/></td>
                    <td><xsl:value-of select="study_period/interval"/></td>
                    <td><xsl:value-of select="study_period/date_start"/><xsl:text> - </xsl:text><xsl:value-of select="study_period/date_end"/></td>
                    <td class="links"><a><xsl:attribute name="href"><xsl:value-of select="url_details"/></xsl:attribute>View Details</a><br/>
                       <a><xsl:attribute name="href"><xsl:value-of select="url_plots"/></xsl:attribute>View Plots</a></td>
                    <td class="files">
                    <xsl:for-each select="files/file">
                        <a><xsl:attribute name="href"><xsl:value-of select="url"/></xsl:attribute><xsl:value-of select="label"/></a><br /><xsl:text>&#10;</xsl:text>
                    </xsl:for-each>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
        </div>
        <p class="date-generated">Date indexed: <xsl:value-of select="/root/dataset_summary[1]/date_index"/></p>
    </xsl:for-each>
        
</xsl:template>

</xsl:stylesheet>
