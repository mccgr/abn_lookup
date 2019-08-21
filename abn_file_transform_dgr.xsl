<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml"/>
    <xsl:strip-space elements="*"/>


    <xsl:template match="Transfer">  
        <xsl:copy> 
            <xsl:apply-templates select="ABR[DGR]"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="ABR">  
        <xsl:apply-templates select="DGR"/>
    </xsl:template>
    
    <xsl:template match="DGR">  
      <xsl:copy> 
        <xsl:element name = "abn">
        <xsl:value-of select="../ABN" />
        </xsl:element>
        <xsl:element name="name">
        <xsl:value-of select="NonIndividualName/NonIndividualNameText" />
        </xsl:element>
        <xsl:element name="type">
        <xsl:value-of select="NonIndividualName/@type" />
        </xsl:element>
        <xsl:element name="dgr_status_from_date">
        <xsl:value-of select="@DGRStatusFromDate" />
        </xsl:element>
      </xsl:copy>
   </xsl:template>
    
    
    
    
    
    
</xsl:stylesheet>