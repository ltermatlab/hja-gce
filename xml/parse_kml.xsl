<?xml version="1.0" encoding="UTF-8"?>

<!-- 
This stylesheet parses point and polygon coordinates from Google Earth KML files to create a
tab-delimited text file for parsing using the GCE Data Toolbox for MATLAB

KML files with placemarks containing MultiGeometry elements will be parsed in a 4-column 
table with fields:
  Name - placemark name
  Description - placemark description
  Point - single latitude,longitude coordinate pair
  Polygon - array of space-delimeted latitude,longitude coordinate pairs for polygon vertices

KML files with placemarks containing single Point or Polygon elements will be parsed into a 3-column
table with fields:
  Name - placemark name
  Description - placemark description
  Coordinate - array of space-delimeted latitude,longitude coordinate pairs for polygon vertices,
    with a single coordinate for Point elements

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

<xsl:stylesheet xmlns="http://www.opengis.net/kml/2.2" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom"
    exclude-result-prefixes="xs gx atom kml" version="1.0">
       
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">

        <!-- iterate through placemarks -->
        <xsl:for-each select="//kml:Placemark">
            
            <!-- check for multigeometry with combined point and polygon elements, create 4-column table -->
            <xsl:choose>
                
                <xsl:when test="kml:MultiGeometry != ''">
                    
                    <!-- add header before first placemark -->
                    <xsl:if test="position()=1">
                        <xsl:text>Name&#09;Description&#09;Point&#09;Polygon&#xD;&#xA;</xsl:text>
                    </xsl:if>
                    
                    <!-- add name, description -->
                    <xsl:value-of select="normalize-space(kml:name)"/><xsl:text>&#09;</xsl:text>    
                    <xsl:value-of select="normalize-space(kml:description)"/><xsl:text>&#09;</xsl:text>
                    
                    <!-- add point -->
                    <xsl:value-of select="normalize-space(kml:MultiGeometry/kml:Point/kml:coordinates)"/><xsl:text>&#09;</xsl:text>
                    
                    <!-- add polygon, testing for addition subelements before coordinates -->
                    <xsl:choose>
                        <xsl:when test="kml:MultiGeometry/kml:Polygon/kml:outerBoundaryIs != ''">
                            <xsl:value-of select="normalize-space(kml:MultiGeometry/kml:Polygon/kml:outerBoundaryIs/kml:LinearRing/kml:coordinates)"/><xsl:text>&#09;</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- deal with other polygon elements -->
                            <xsl:for-each select="kml:MultiGeometry/kml:Polygon">
                                <xsl:value-of select="normalize-space(*/kml:outerBoundaryIs/kml:LinearRing/kml:coordinates)"/><xsl:text>&#09;</xsl:text>                                
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:when>
                
                <!-- simple geometry -->
                <xsl:otherwise>
                    
                    <!-- add header -->
                    <xsl:if test="position()=1">
                        <xsl:text>Name&#09;Description&#09;Coordinates&#xD;&#xA;</xsl:text>
                    </xsl:if>
                    
                    <!-- add name, description -->
                    <xsl:value-of select="normalize-space(kml:name)"/><xsl:text>&#09;</xsl:text>    
                    <xsl:value-of select="normalize-space(kml:description)"/><xsl:text>&#09;</xsl:text>
                    
                    <!-- check for polygon or point -->
                    <xsl:choose>
                        <xsl:when test="kml:Polygon != ''">
                            <xsl:value-of select="normalize-space(*/kml:outerBoundaryIs/kml:LinearRing/kml:coordinates)"/><xsl:text>&#09;</xsl:text>                            
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="normalize-space(kml:Point/kml:coordinates)"/><xsl:text>&#09;</xsl:text>                            
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:otherwise>
                
            </xsl:choose>
            
            <!-- add line terminator -->
            <xsl:text>&#xD;&#xA;</xsl:text>
            
        </xsl:for-each>
        
        
    </xsl:template>
    
</xsl:stylesheet>