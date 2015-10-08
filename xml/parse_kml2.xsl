<?xml version="1.0" encoding="UTF-8"?>

<!-- 
This stylesheet parses point and polygon coordinates from Google Earth KML files to create a
tab-delimited text file for loading into the GCE Data Toolbox for MATLAB

Placemarks in KML files will be parsed into a 3-column, tab-delimited table with fields
  Name - placemark name
  Description - placemark description
  Coordinates - array of space-delimeted latitude,longitude coordinate pairs for polygon vertices,
    with a single coordinate for Point elements

Note that placemarks that utilize the MultiGeometry element to combine polygons and points will
be parsed into 2 or more rows, with the Name and Description repeated for each polygon or point

version 1.0 (19-Sep-2014)

Copyright 2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Program

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom"
    exclude-result-prefixes="xs gx atom kml" version="1.0">
       
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
       
       <!-- add heading -->
       <xsl:text>Location&#09;Description&#09;Coordinates&#xD;&#xA;</xsl:text>

       <!-- iterate through placemarks -->
        <xsl:for-each select="//kml:Placemark">
           
           <!-- add name, description for each set of coordinates -->
           <xsl:variable name="namefield">
              <xsl:value-of select="normalize-space(kml:name)"/>
           </xsl:variable>
           <xsl:variable name="descfield">
              <xsl:value-of select="normalize-space(kml:description)"/>
           </xsl:variable>
           
           <xsl:for-each select="*//kml:coordinates">

              <xsl:call-template name="coordinates">
                 <xsl:with-param name="name"><xsl:value-of select="$namefield"/></xsl:with-param>
                 <xsl:with-param name="description"><xsl:value-of select="$descfield"/></xsl:with-param>
                 <xsl:with-param name="coord"><xsl:value-of select="normalize-space(.)"/></xsl:with-param>
              </xsl:call-template>
              
           </xsl:for-each>
            
        </xsl:for-each>       
        
    </xsl:template>
   
   <xsl:template name="coordinates">
      <xsl:param name="name"/>
      <xsl:param name="description"/>
      <xsl:param name="coord"/>
      <xsl:value-of select="$name"/><xsl:text>&#09;</xsl:text>
      <xsl:value-of select="$description"/><xsl:text>&#09;</xsl:text>
      <xsl:value-of select="$coord"/><xsl:text>&#xD;&#xA;</xsl:text>
   </xsl:template>
    
</xsl:stylesheet>