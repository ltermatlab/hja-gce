<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    
    <xsl:template name="main">    
        <xsl:param name="url_css"/>
        <xsl:param name="url_js"/>
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
                <!-- include page-specific CSS parameter if defined -->
                <xsl:if test="$url_css != ''">
                   <xsl:element name="link">
                       <xsl:attribute name="rel">stylesheet</xsl:attribute>
                       <xsl:attribute name="media">all</xsl:attribute>
                       <xsl:attribute name="href"><xsl:value-of select="$url_css"/></xsl:attribute>
                   </xsl:element>
                </xsl:if>
                <!-- include page-specific Javascript url paramter if defined (using comment to avoid self-closing tag) -->
                <xsl:if test="$url_js != ''">
                    <xsl:element name="script">
                      <xsl:attribute name="type">text/javascript</xsl:attribute>
                      <xsl:attribute name="src"><xsl:value-of select="$url_js"/></xsl:attribute>
                      <xsl:text>// page-specific Javascript</xsl:text>
                    </xsl:element>
                </xsl:if>
                <title>GCE Data Toolbox Harvester Webpage Demo</title>
            </head>
            <body>
                <div id="header">
                   <a href="http://gce-svn.marsci.uga.edu/trac/GCE_Toolbox/"><img src="http://gce-lter.marsci.uga.edu/public/xsl/toolbox/gce-toolbox-logo.jpg" alt="GCE Data Toolbox for MATLAB" width="580" height="110"/></a>
                </div>
                <div id="navigation">
                   <!-- execute 'topnav' template in calling xsl to generate navigation breadcrumbs -->
                   <xsl:call-template name="topnav"></xsl:call-template>
                </div>
                <div id="content">
                   <!-- execute 'body' template in calling xsl to generate main contents -->
                   <xsl:call-template name="body"></xsl:call-template>
                </div>
                <div id="footer">
                   <div style="float:left;margin:0 40px 0 0"><a href="http://www.lternet.edu/" title="LTER Network"><img src="http://gce-lter.marsci.uga.edu/public/images/lterlogo_small.gif" alt="LTER" width="51" height="60" /></a></div>
                   <div style="float:right;margin:0 0 0 30px"><a href="http://www.nsf.gov/" title="NSF"><img src="http://gce-lter.marsci.uga.edu/public/images/nsfe2.gif" alt="NSF" width="64" height="65" /></a></div>
                   <p>Development of the <a href="https://gce-svn.marsci.uga.edu/trac/GCE_Toolbox/">GCE Data Toolbox for MATLAB</a> was supported by the <a href="http://www.nsf.gov/">National Science Foundation</a> under
                     grant numbers <a href="http://www.nsf.gov/awardsearch/showAward.do?AwardNumber=9982133">OCE-9982133</a> and <a href="http://www.nsf.gov/awardsearch/showAward.do?AwardNumber=0620959">OCE-0620959</a>.
                     Any opinions, findings, conclusions, or recommendations expressed in the material are those of the author(s) and do not necessarily reflect the
                     views of the National Science Foundation.</p>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
