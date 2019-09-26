<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
          version="1.0"
          xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>

    <xsl:template match="Transfer">  
    
    
        <xsl:text>abn</xsl:text><xsl:text>&#x9;</xsl:text>
        <xsl:text>name</xsl:text><xsl:text>&#x9;</xsl:text>
        <xsl:text>type</xsl:text><xsl:text>&#x9;</xsl:text>
        <xsl:text>dgr_status_from_date</xsl:text>
        <xsl:text>&#xa;</xsl:text>
    
    
        <xsl:apply-templates select="ABR[DGR]"/>
        
        
    </xsl:template>

    <xsl:template match="ABR">
        <xsl:for-each select="DGR">
            <xsl:value-of select="concat(../ABN, '&#x9;', NonIndividualName/NonIndividualNameText, '&#x9;', NonIndividualName/@type, '&#x9;', @DGRStatusFromDate, '&#xa;')"/>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>