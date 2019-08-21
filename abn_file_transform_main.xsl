<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml"/>
    <xsl:strip-space elements="*"/>


    <xsl:template match="Transfer">  
        <xsl:copy> 
            <xsl:apply-templates select="ABR"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="ABR">
        <xsl:copy> 
            <xsl:element name = "record_last_updated_date">
            <xsl:value-of select="@recordLastUpdatedDate" />
            </xsl:element>
            <xsl:element name = "replaced">
            <xsl:value-of select="@replaced" />
            </xsl:element>
            <xsl:apply-templates select="ABN|EntityType|ASICNumber|GST|LegalEntity|MainEntity"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="ABN">  
      <xsl:element name="abn">
      <xsl:value-of select="." />
      </xsl:element>
      <xsl:element name="abn_status">
      <xsl:value-of select="@status" />
      </xsl:element>
      <xsl:element name="abn_status_from_date">
      <xsl:value-of select="@ABNStatusFromDate" />
      </xsl:element>
   </xsl:template>
   
   <xsl:template match="EntityType">  
      <xsl:element name="entity_type_ind">
      <xsl:value-of select="EntityTypeInd" />
      </xsl:element>
      <xsl:element name="entity_type_text">
      <xsl:value-of select="EntityTypeText" />
      </xsl:element>
   </xsl:template>
   
   <xsl:template match="GST">  
      <xsl:element name="gst_status">
      <xsl:value-of select="@status" />
      </xsl:element>
      <xsl:element name="gst_status_from_date">
      <xsl:value-of select="@GSTStatusFromDate" />
      </xsl:element>
   </xsl:template>
   
   <xsl:template match="ASICNumber">  
      <xsl:element name="asic_number">
      <xsl:value-of select="." />
      </xsl:element>
      <xsl:element name="asic_number_type">
      <xsl:value-of select="@ASICNumberType" />
      </xsl:element>
   </xsl:template>
   
   <xsl:template match="MainEntity">  
      <xsl:element name="main_ent_type">
      <xsl:value-of select="NonIndividualName/@type" />
      </xsl:element>
      <xsl:element name="main_ent_name">
      <xsl:value-of select="NonIndividualName/NonIndividualNameText" />
      </xsl:element>
      <xsl:element name="main_ent_add_state">
      <xsl:value-of select="BusinessAddress/AddressDetails/State" />
      </xsl:element>
      <xsl:element name="main_ent_add_postcode">
      <xsl:value-of select="BusinessAddress/AddressDetails/Postcode" />
      </xsl:element>
   </xsl:template>

   <xsl:template match="LegalEntity">  
      <xsl:element name="legal_ent_type">
      <xsl:value-of select="IndividualName/@type" />
      </xsl:element>
      <xsl:element name="legal_ent_title">
      <xsl:value-of select="IndividualName/NameTitle" />
      </xsl:element>
      <xsl:element name="legal_ent_given_names">
      <xsl:apply-templates select="IndividualName/GivenName"/>
      </xsl:element>
      <xsl:element name="legal_ent_family_name">
      <xsl:value-of select="IndividualName/FamilyName" />
      </xsl:element>
      <xsl:element name="legal_ent_add_state">
      <xsl:value-of select="BusinessAddress/AddressDetails/State" />
      </xsl:element>
      <xsl:element name="legal_ent_add_postcode">
      <xsl:value-of select="BusinessAddress/AddressDetails/Postcode" />
      </xsl:element>
   </xsl:template>
   
   <xsl:template match="GivenName">
    <xsl:value-of select="concat(., ' ')"/>
  </xsl:template>
   

</xsl:stylesheet>