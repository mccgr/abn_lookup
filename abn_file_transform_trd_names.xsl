<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml"/>
    <xsl:strip-space elements="*"/>


    <xsl:template match="Transfer">  
        <xsl:copy> 
            <xsl:apply-templates select="ABR[OtherEntity]"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="ABR">  
        <xsl:apply-templates select="OtherEntity"/>
    </xsl:template>
    
    <xsl:template match="OtherEntity">  
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
      </xsl:copy>
   </xsl:template>
    
    
    
    
    
    
</xsl:stylesheet>