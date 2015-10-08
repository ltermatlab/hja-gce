<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:import href="http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_webpage.xsl" />
<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="ISO-8859-1" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />

<!-- call main template to generate page layout and scaffolding, which calls topnav and body templates at appropriate points in doc -->
<xsl:template match="/">
    <xsl:call-template name="main">
        <xsl:with-param name="url_css">http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_webpage.css</xsl:with-param>
    </xsl:call-template>
</xsl:template>
    
<!-- template for top navigation -->
<xsl:template name="topnav">
    <!-- generate menu buttons -->
    <xsl:for-each select="/root/navigation/item">
        <a><xsl:attribute name="href"><xsl:value-of select="url"/></xsl:attribute><xsl:value-of select="label"/></a> &gt;
    </xsl:for-each>
    <!-- add current page label and link to plots as sub-page link -->
    <a><xsl:attribute name="href"><xsl:value-of select="/root/url_data"/></xsl:attribute><xsl:attribute name="class">subpage</xsl:attribute>Dataset Details</a> | 
    <xsl:choose>
        <xsl:when test="/root/parameter = 'all'">
            <span class="current-subpage">Plots</span>
            <xsl:text> &gt; </xsl:text>
            <xsl:for-each select="/root/indiv_plots/item">
                <a><xsl:attribute name="href"><xsl:value-of select="url"/></xsl:attribute><xsl:attribute name="class">subpage</xsl:attribute><xsl:value-of select="label"/></a>
                <xsl:if test="position() != last()"> | </xsl:if>
            </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <a><xsl:attribute name="href"><xsl:value-of select="/root/url_plotindex"/></xsl:attribute><xsl:attribute name="class">subpage</xsl:attribute>Plots</a>
            <xsl:text> &gt; </xsl:text>
            <span class="current-subpage"><xsl:value-of select="/root/parameter"/></span>
        </xsl:otherwise>
    </xsl:choose>
 </xsl:template>

<!-- template for page contents  -->
<xsl:template name="body">
    
    <!-- xsl for plot index page -->
    <h1><xsl:value-of select="/root/title"/></h1>
    <xsl:for-each select="/root/plots/table">
        <div id="plot_table">
            <table>
                <xsl:for-each select="row">
                    <xsl:if test="string-length(title) &gt; 0">
                        <tr>
                            <th><xsl:attribute name="colspan"><xsl:value-of select="count(column)"/></xsl:attribute><xsl:value-of select="title"/></th>
                        </tr>
                    </xsl:if>
                    <tr>
                        <xsl:for-each select="column">
                            <td class="label"><xsl:attribute name="style">width:<xsl:value-of select="width"/></xsl:attribute><xsl:value-of select="label"/></td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <xsl:for-each select="column">
                            <td><xsl:attribute name="style">width:<xsl:value-of select="width"/></xsl:attribute>
                                <xsl:if test="string-length(url_image) &gt; 0">
                                    <a><xsl:attribute name="href"><xsl:value-of select="url_image"/></xsl:attribute><xsl:attribute name="title">Click to view full plot</xsl:attribute>
                                        <img><xsl:attribute name="src"><xsl:value-of select="url_thumbnail"/></xsl:attribute><xsl:attribute name="alt">Plot link</xsl:attribute></img>
                                    </a>
                                </xsl:if>
                            </td>
                        </xsl:for-each>
                    </tr>
                </xsl:for-each>
            </table>
        </div>
    </xsl:for-each>
    <p class="date-generated">Date generated: <xsl:value-of select="/root/date_generated"/></p>
    
</xsl:template>

</xsl:stylesheet>
