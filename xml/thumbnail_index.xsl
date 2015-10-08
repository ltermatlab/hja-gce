<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
   
   <xsl:import href="http://gce-lter.marsci.uga.edu/public/xsl/toolbox/dashboard_webpage.xsl" />
   <xsl:output method="html" omit-xml-declaration="yes" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />
   
   <!-- call main template to generate page layout and scaffolding, which calls topnav and body templates at appropriate points in doc -->
   <xsl:template match="/">
      <xsl:call-template name="main">
         <xsl:with-param name="url_css">http://gce-lter.marsci.uga.edu/public/xsl/toolbox/thumbnail_index.css</xsl:with-param>
       <xsl:with-param name="url_js"></xsl:with-param>
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
       <xsl:for-each select="images/image">
          <div class="photo">
             <xsl:element name="a">
                <xsl:attribute name="href"><xsl:value-of select="original/filename"/></xsl:attribute>
                <xsl:attribute name="title">view full size image</xsl:attribute>
                <xsl:element name="img">
                   <xsl:attribute name="src"><xsl:value-of select="thumbnail/filename"/></xsl:attribute>
                   <xsl:attribute name="alt"><xsl:value-of select="original/filename"/></xsl:attribute>
                   <xsl:attribute name="border">none</xsl:attribute>
                   <xsl:attribute name="height"><xsl:value-of select="thumbnail/height"/></xsl:attribute>
                   <xsl:attribute name="width"><xsl:value-of select="thumbnail/width"/></xsl:attribute>
                </xsl:element>
             </xsl:element>
             <ul>
                <li>Filename: <xsl:value-of select="original/filename"/></li>
                <li>Date Taken: <xsl:value-of select="original/date_taken"/></li>
                <li>Dimensions: <xsl:value-of select="original/width"/>x<xsl:value-of select="original/height"/></li>
                <li>Camera: <xsl:value-of select="original/camera_make"/>&#160;<xsl:value-of select="original/camera_model"/></li>
                <li>Settings: <xsl:value-of select="original/focal_length"/>mm,&#160;ISO&#160;<xsl:value-of select="original/iso"/></li>
             </ul>
          </div>
       </xsl:for-each>
       <p class="date-generated">Date indexed: <xsl:value-of select="/root/date_generated"/></p>
    </xsl:for-each>
        
</xsl:template>

<xsl:template name="replace">
    <xsl:param name="text" />
    <xsl:param name="replace" />
    <xsl:param name="by" />
    <xsl:choose>
      <xsl:when test="contains($text, $replace)">
        <xsl:value-of select="substring-before($text,$replace)" />
        <xsl:value-of select="$by" />
        <xsl:call-template name="replace">
          <xsl:with-param name="text"
          select="substring-after($text,$replace)" />
          <xsl:with-param name="replace" select="$replace" />
          <xsl:with-param name="by" select="$by" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
