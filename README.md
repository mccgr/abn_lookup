# abn_lookup
Code for creating tables containing the ABN's for companies registered with the Australian Business Register on the [ABN lookup website](https://abr.business.gov.au/) 


## Main Tables

### Overview

There are three tables in the `abn_lookup` schema:

 - `abns`: This is the main table which contains identifying information on each entity with a registered ABN number.
 
 - `trading_names`: This table contains the trading names for each company with a registered ABN.
 
 - `dgr`: This table contains the names of the deductible gift recipient items for each ABN.
 
 
### Details by Table

#### `abns` 

This table has an entry for each ABN number that has ever been registered, along with the . The fields are

 - `abn`: The ABN number, written as a string.
 
 - `abn_status`: This field details whether the entity associated with the ABN is either active, for which this field is equal to the string 'ACT', or cancelled, for which the field is equal to the string 'CAN'.
 
  - `abn_status_from_date`: This is the date the ABN was registered.
  
  - `record_last_updated_date`: the date the information associated with the ABN was last updated.
  
  - `replaced`: (whether this ABN has replaced another ???)
  
  - `entity_type_ind`: this field contains the entity type as an index (as given by the ABR [here](https://abr.business.gov.au/Documentation/ReferenceData))
  
  - `entity_type_text`: this field contains the entity type written as text.
  
  - `asic_number`: the registered ACN or ARBN of the entity, if the entity is registered with ASIC.
  
  - `asic_number_type`: the type of the `asic_number` (note: so far, it seems the ABR does not really make use of this column)
 
  - `gst_status`: this field details whether the entity has registered for the GST. If so, this field is equal to the string 'ACT', otherwise it is null. 
  
  - `gst_status_from_date`: the date on which the entity was registered for the GST
  
  - `main_ent_type`: the type of main entity, if applicable (note: this column may be redundant)
 
  - `main_ent_name`: the name of the entity, if the entity is not an individual.
  
  - `main_ent_add_state`: the state of the address of the entity, if the entity is not an individual.
  
  - `main_ent_add_postcode`:  the postcode of the address of the entity, if the entity is not an individual.
 
  - `legal_ent_type`: the type of legal entity, if applicable (note: this column may be redundant)
 
  - `legal_ent_title`: the title (ie. Mr, Mrs, Dr etc...) of the entity's name, if the entity is an individual.
  
  - `legal_ent_family_name`: the surname of the entity, if the entity is an individual.
  
  - `legal_ent_given_names`: the given names of the entity, if the entity is an individual, written in order as one string.
  
  - `legal_ent_add_state`: the state of the address of the entity, if the entity is an individual.
  
  - `legal_ent_add_postcode`:  the postcode of the address of the entity, if the entity is an individual.
 
 
#### `trading_names` 
 
This table contains all the registered business names and trading names that an entity with a given ABN does business under. Each row of the table corresponds to a single instance of an `OtherEntity` node in the original bulk extract xml files. The fields are:

 - `abn`: The ABN of the entity.
 - `name`: the business name or trading name
 - `type`: the type of the name, whether a business name ('BN'), trading name ('TRD'), or something else ('OTN').
 
 
#### `dgr` 
 
This table contains all the donation gift recipient (DGR) items of an entity with a given ABN. Each row of the table corresponds to a single instance of a `DGR` node in the original bulk extract xml files. The fields are:

 - `abn`: The ABN of the entity.
 - `name`: the name of the donation gift recipient item.
 - `type`: the type of the name (seems this is always 'DGR', so probably redundant).
 - `dgr_status_from_date`: the date that the DGR item was registered.
 
 
 
 
 
 