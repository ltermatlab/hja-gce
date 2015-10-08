<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:import href="http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_webpage.xsl" />
<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="ISO-8859-1" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />

<!-- call main template to generate page layout and scaffolding, which calls topnav and body templates at appropriate points in doc -->
<xsl:template match="/">
    <xsl:call-template name="main">
        <xsl:with-param name="url_css">http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_webpage.css</xsl:with-param>
        <xsl:with-param name="url_js">http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_details.js</xsl:with-param>
    </xsl:call-template>
</xsl:template>
    
<!-- template for top navigation -->
<xsl:template name="topnav">
    <!-- generate menu buttons -->
    <xsl:for-each select="/root/navigation/item">
        <a><xsl:attribute name="href"><xsl:value-of select="url"/></xsl:attribute><xsl:value-of select="label"/></a> &gt;
    </xsl:for-each>
    <!-- add current page label, plots link  -->
    <span class="current-subpage">Dataset Details</span> |
    <a><xsl:attribute name="href"><xsl:value-of select="/root/dataset_details/url_plots"/></xsl:attribute><xsl:attribute name="class">subpage</xsl:attribute>Plots</a>
</xsl:template>

<!-- template for page contents  -->
<xsl:template name="body">
    
    <!-- xsl for index page -->
    <xsl:for-each select="/root">
        <h1><xsl:value-of select="title"/></h1>
        <xsl:for-each select="dataset_details">
            <div id="dataset-details">
                <table>
                    <tr>
                        <th class="toprow">Data Set ID:</th>
                        <td class="toprow"><xsl:value-of select="dataset_id"/></td>
                    </tr>
                    <tr>
                        <th>Originator:</th>
                        <td><xsl:value-of select="contributor"/></td>
                    </tr>
                    <tr>
                        <th>Title:</th>
                        <td><xsl:value-of select="title"/></td>
                    </tr>
                    <tr>
                        <th>Abstract:</th>
                        <td><xsl:value-of select="abstract"/></td>
                    </tr>
                    <tr>
                        <th>Key Words:</th>
                        <td>
                            <xsl:for-each select="keywords/keyword"><xsl:value-of select="."/><xsl:if test="position() != last()">, </xsl:if></xsl:for-each>
                        </td>
                    </tr>
                    <tr>
                        <th>Study Type:</th>
                        <td><xsl:value-of select="study_type"/></td>
                    </tr>
                    <tr>
                        <th>Study Period:</th>
                        <td><xsl:value-of select="study_period/date_start"/> to <xsl:value-of select="study_period/date_end"/></td>
                    </tr>
                    <tr>
                        <th>Bounding Box:</th>
                        <td>
                            West longitude:&#160;&#160;<xsl:value-of select="bounding_box/wboundlon"/><br/>
                            North latitude:&#160;&#160;<xsl:value-of select="bounding_box/nboundlat"/><br/>
                            East longitude:&#160;&#160;<xsl:value-of select="bounding_box/eboundlon"/><br/>
                            South latitude:&#160;&#160;<xsl:value-of select="bounding_box/sboundlat"/><br/>
                        </td>
                    </tr>
                    <tr>
                        <th>Site References:</th>
                        <td>
                            <xsl:for-each select="study_sites/site">
                                <xsl:choose>
                                    <xsl:when test="string-length(url) &gt; 0">
                                        <a><xsl:attribute name="href"><xsl:value-of select="url"/></xsl:attribute><xsl:value-of select="sitecode"/></a>
                                     </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="sitecode"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="string-length(sitename) &gt; 0"> - <xsl:value-of select="sitename"/></xsl:if>
                                <xsl:if test="string-length(location) &gt; 0">, <xsl:value-of select="location"/></xsl:if><br/>
                            </xsl:for-each>
                        </td>
                    </tr>
                    <tr>
                        <th>Downloads:&#160; <a href="javascript:void" onclick="openWin('http://gce-lter.marsci.uga.edu/public/data_formats.htm'); return false" title="Display help on data and metadata download formats"><img src="http://gce-lter.marsci.uga.edu/public/images/icons/green_question.gif" width="18" height="14" alt="Formats" style="border:none; margin:0" /></a></th>
                        <td><p class="entity"><strong>Data Table:</strong>&#160; <xsl:value-of select="dataset_id"/>  (Main data table, <xsl:value-of select="table_size"/> records)</p>
                            <p class="entity-sub"><strong>Access:</strong>&#160; Public</p>                            
                            <p class="entity-sub"><strong>Metadata:</strong>&#160; <a><xsl:attribute name="href"><xsl:value-of select="metadata_files/file[1]/url"/></xsl:attribute>Text (ESA FLED)</a></p>
                            <p class="entity-sub"><strong>Data Files:</strong>&#160;
                                <xsl:for-each select="data_files/file">
                                   <a><xsl:attribute name="href"><xsl:value-of select="url"/></xsl:attribute><xsl:value-of select="label"/></a>
                                   <xsl:if test="filesize!=''">
                                      <xsl:text> [</xsl:text><xsl:value-of select="filesize"/><xsl:text>]</xsl:text>
                                   </xsl:if>
                                   <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
                                </xsl:for-each>
                            </p>    
                             <p class="entity-sub"><strong>Column List:</strong></p>
                             <table class="attributes" id="tableEntity1">
                                 <tr>
                                    <th>Column</th>
                                    <th>Name</th>
                                    <th>Units</th>
                                    <th>Type</th>
                                    <th>Description&#160;<span id="Entity1" style="font-style:italic">(<a href="javascript:showDesc('Entity1')">show</a>)</span></th>
                                 </tr>
                                 <xsl:for-each select="columns/column">
                                     <tr>
                                         <td><xsl:value-of select="number"/></td>
                                         <td><xsl:value-of select="name"/></td>
                                         <td><xsl:value-of select="units"/></td>
                                         <td><xsl:value-of select="datatype"/></td>
                                         <td class="description"><xsl:value-of select="description"/></td>
                                     </tr>
                                 </xsl:for-each>
                             </table>       
                        </td>
                    </tr>
                    <tr>
                        <th>Last Modified:</th>
                        <td><xsl:value-of select="date_index"/></td>
                    </tr>
                </table>
            </div>
        </xsl:for-each>
    </xsl:for-each>
        
</xsl:template>

</xsl:stylesheet>
