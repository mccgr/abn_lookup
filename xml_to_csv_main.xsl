<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
          version="1.0"
          xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>

    <xsl:template match="Transfer">  
    
    
        <xsl:text>abn</xsl:text><xsl:text>&#x9;</xsl:text>
        <xsl:text>abn_status</xsl:text><xsl:text>&#x9;</xsl:text>
        <xsl:text>abn_status_from_date</xsl:text><xsl:text>&#x9;</xsl:text>
        <xsl:text>record_last_updated_date</xsl:text><xsl:text>&#x9;</xsl:text>
        <xsl:text>replaced</xsl:text><xsl:text>&#x9;</xsl:text>             
        <xsl:text>entity_type_ind</xsl:text><xsl:text>&#x9;</xsl:text>       
        <xsl:text>entity_type_text</xsl:text><xsl:text>&#x9;</xsl:text>      
        <xsl:text>asic_number</xsl:text><xsl:text>&#x9;</xsl:text>             
        <xsl:text>asic_number_type</xsl:text><xsl:text>&#x9;</xsl:text>       
        <xsl:text>gst_status</xsl:text><xsl:text>&#x9;</xsl:text>              
        <xsl:text>gst_status_from_date</xsl:text><xsl:text>&#x9;</xsl:text>     
        <xsl:text>main_ent_type</xsl:text><xsl:text>&#x9;</xsl:text>            
        <xsl:text>main_ent_name</xsl:text><xsl:text>&#x9;</xsl:text>            
        <xsl:text>main_ent_add_state</xsl:text><xsl:text>&#x9;</xsl:text>      
        <xsl:text>main_ent_add_postcode</xsl:text><xsl:text>&#x9;</xsl:text>    
        <xsl:text>legal_ent_type</xsl:text><xsl:text>&#x9;</xsl:text>         
        <xsl:text>legal_ent_title</xsl:text><xsl:text>&#x9;</xsl:text>        
        <xsl:text>legal_ent_family_name</xsl:text><xsl:text>&#x9;</xsl:text>  
        <xsl:text>legal_ent_given_names</xsl:text><xsl:text>&#x9;</xsl:text>  
        <xsl:text>legal_ent_add_state</xsl:text><xsl:text>&#x9;</xsl:text>    
        <xsl:text>legal_ent_add_postcode</xsl:text>
        <xsl:text>&#xa;</xsl:text>
    
    
        <xsl:apply-templates select="ABR"/>
        
        
    </xsl:template>

    <xsl:template match="ABR">
    
        <xsl:value-of select="concat(ABN, '&#x9;', ABN/@status, '&#x9;', ABN/@ABNStatusFromDate, '&#x9;')"/>
        <xsl:value-of select="concat(@recordLastUpdatedDate, '&#x9;', @replaced, '&#x9;')"/> 
        <xsl:value-of select="concat(EntityType/EntityTypeInd, '&#x9;', EntityType/EntityTypeText, '&#x9;')"/>
        <xsl:value-of select="concat(ASICNumber, '&#x9;', ASICNumber/@ASICNumberType, '&#x9;')"/>
        <xsl:value-of select="concat(GST/@status, '&#x9;', GST/@GSTStatusFromDate, '&#x9;')"/>
        <xsl:value-of select="concat(MainEntity/NonIndividualName/@type, '&#x9;', MainEntity/NonIndividualName/NonIndividualNameText, '&#x9;')"/>
        <xsl:value-of select="concat(MainEntity/BusinessAddress/AddressDetails/State, '&#x9;', MainEntity/BusinessAddress/AddressDetails/Postcode, '&#x9;')"/>
        

        <xsl:value-of select="concat(LegalEntity/IndividualName/@type, '&#x9;', LegalEntity/IndividualName/NameTitle, '&#x9;', LegalEntity/IndividualName/FamilyName, '&#x9;')"/>
        <xsl:for-each select="LegalEntity/IndividualName/GivenName">
            <xsl:value-of select="." />
            <xsl:if test="position()!=last()">
                <xsl:text> </xsl:text>
            </xsl:if>
        </xsl:for-each><xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="concat(LegalEntity/BusinessAddress/AddressDetails/State, '&#x9;', LegalEntity/BusinessAddress/AddressDetails/Postcode)"/>
        <xsl:text>&#xa;</xsl:text>
        
        
    </xsl:template>

</xsl:stylesheet>